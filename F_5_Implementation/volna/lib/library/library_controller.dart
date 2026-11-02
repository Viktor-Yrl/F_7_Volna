import 'package:flutter/foundation.dart';

import '../data/library_store.dart';
import '../data/media_library.dart';
import '../data/models.dart';
import '../data/radio_catalog.dart';
import '../l10n/ui_message.dart';

/// Owns library metadata; device files and selected folders remain external.
class LibraryController extends ChangeNotifier {
  LibraryController({required this.store, MediaLibrary? media})
    : media = media ?? MediaLibrary();
  final LibraryStore store;
  final MediaLibrary media;
  final List<Track> _savedFiles = [];
  final List<Track> _retainedDeviceTracks = [];
  final List<Track> _legacyStations = [];
  final List<SavedPlaylist> _savedPlaylists = [];
  final Set<String> _favorites = {};
  final List<MusicFolder> _folders = [];
  final List<Track> _folderTracks = [];
  // Membership is kept per selected root; overlapping roots share track IDs.
  final Map<String, List<Track>> _tracksByFolder = {};
  List<Track> tracksForFolder(String uri) =>
      List.unmodifiable(_tracksByFolder[uri] ?? const <Track>[]);
  final Map<String, int> _playCounts = {};
  List<MusicFolder> get folders => List.unmodifiable(_folders);
  int playCount(String id) => _playCounts[id] ?? 0;
  List<Track> get topTracks {
    final ranked = tracks
        .where((e) => !e.isRadio && playCount(e.id) > 0)
        .toList();
    ranked.sort((a, b) {
      final count = playCount(b.id).compareTo(playCount(a.id));
      return count != 0
          ? count
          : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return ranked.take(100).toList();
  }

  bool _disposed = false;
  bool busy = false;
  UiMessage? error;
  List<Track> get tracks => List.unmodifiable(
    {
      for (final track in [
        ..._savedFiles,
        ..._retainedDeviceTracks,
        ..._folderTracks,
      ])
        track.id: track,
    }.values,
  );
  List<Track> get savedFiles => List.unmodifiable(_savedFiles);
  List<Track> get retainedDeviceTracks =>
      List.unmodifiable(_retainedDeviceTracks);
  List<Track> get stations => RadioCatalog.stations;
  List<SavedPlaylist> get savedPlaylists => List.unmodifiable(_savedPlaylists);
  bool isFavorite(String id) => _favorites.contains(id);
  Track? find(String id) {
    for (final track in [...tracks, ...stations]) {
      if (track.id == id) return track;
    }
    for (final legacy in _legacyStations) {
      if (legacy.id == id) return RadioCatalog.replacementFor(legacy);
    }
    return null;
  }

  List<Track> savedPlaylistTracks(SavedPlaylist list) => [
    for (final id in list.trackIds)
      if (find(id) case final Track track) track,
  ];
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    error = null;
    _notify();
  }

  Future<void> initialize() async {
    // Restore user metadata before scanning currently accessible audio sources.
    busy = true;
    _notify();
    try {
      final data = await store.read('library');
      _savedFiles.addAll(
        (data['tracks'] as List? ?? []).map(
          (e) => Track.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      _legacyStations.addAll(
        (data['stations'] as List? ?? []).map(
          (e) => Track.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      _savedPlaylists.addAll(
        (data['playlists'] as List? ?? []).map(
          (e) => SavedPlaylist.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      _favorites.addAll((data['favorites'] as List? ?? []).cast<String>());
      _folders.addAll(
        (data['folders'] as List? ?? []).map(
          (e) => MusicFolder.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      _retainedDeviceTracks.addAll(
        (data['retainedDeviceTracks'] as List? ?? []).map(
          (e) => Track.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      final counts = Map<String, dynamic>.from(
        data['playCounts'] as Map? ?? {},
      );
      for (final entry in counts.entries) {
        if (entry.value is num && (entry.value as num) > 0) {
          _playCounts[entry.key] = (entry.value as num).toInt();
        }
      }
      error = store.warning;
      await _restoreLegacyReferences();
      await _refreshFolders();
    } catch (_) {
      error = const UiMessage(MessageId.libraryLoadFailed);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> _restoreLegacyReferences() async {
    // Older releases persisted device IDs, not their metadata. Resolve only IDs
    // used by a playlist, favorite, history or saved queue; never scan all music.
    final playback = await store.read('playback');
    final ids =
        <String>{
          ..._favorites,
          ..._playCounts.keys,
          for (final list in _savedPlaylists) ...list.trackIds,
          ...(playback['ids'] as List? ?? []).cast<String>(),
        }..removeWhere(
          (id) =>
              !id.startsWith('media:') ||
              _retainedDeviceTracks.any((track) => track.id == id),
        );
    if (ids.isEmpty) return;
    try {
      final restored = await media.restoreLegacyTracks(ids.toList());
      _retainedDeviceTracks.addAll(restored);
      if (restored.isNotEmpty) await save();
    } catch (_) {
      // Keep unresolved IDs in user data so access can be restored later.
    }
  }

  Future<void> scan() async {
    if (busy || !media.supported) return;
    busy = true;
    error = null;
    _notify();
    try {
      await _refreshFolders();
    } catch (_) {
      error = const UiMessage(MessageId.libraryScanFailed);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> _refreshFolders() async {
    final tracks = <String, Track>{};
    final failed = <String>[];
    _tracksByFolder.clear();
    for (final folder in _folders) {
      try {
        final found =
            {
              for (final track in await media.scanFolder(folder.uri))
                track.id: track,
            }.values.toList()..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
        _tracksByFolder[folder.uri] = found;
        for (final track in found) {
          tracks.putIfAbsent(track.id, () => track);
        }
      } catch (_) {
        failed.add(folder.name);
      }
    }
    _folderTracks
      ..clear()
      ..addAll(tracks.values);
    if (failed.isNotEmpty) {
      error = UiMessage(MessageId.foldersUnavailable, names: failed.join(', '));
    }
  }

  Future<void> addFolder() async {
    if (busy || !media.supported) return;
    busy = true;
    error = null;
    _notify();
    try {
      final folder = await media.pickFolder();
      if (folder == null) return;
      // Keep the current library intact until the new folder is readable.
      await media.scanFolder(folder.uri);
      _folders.removeWhere((e) => e.uri == folder.uri);
      _folders.add(folder);
      await _refreshFolders();
      await save();
    } catch (_) {
      error = const UiMessage(MessageId.folderOpenFailed);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> removeFolder(String uri) async {
    if (busy) return;
    busy = true;
    error = null;
    _notify();
    try {
      _folders.removeWhere((e) => e.uri == uri);
      await _refreshFolders();
      await save();
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> recordPlay(Track track) async {
    if (_disposed || track.isRadio) return;
    _playCounts.update(track.id, (value) => value + 1, ifAbsent: () => 1);
    _notify();
    await save();
  }

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.add(id)) _favorites.remove(id);
    _notify();
    await save();
  }

  Future<void> save() async {
    try {
      await store.write('library', {
        'version': 2,
        'tracks': _savedFiles.map((e) => e.toJson()).toList(),
        // Preserve legacy station data without exposing custom stations in the UI.
        'stations': _legacyStations.map((e) => e.toJson()).toList(),
        'playlists': _savedPlaylists.map((e) => e.toJson()).toList(),
        'favorites': _favorites.toList(),
        'folders': _folders.map((e) => e.toJson()).toList(),
        'retainedDeviceTracks': _retainedDeviceTracks
            .map((e) => e.toJson())
            .toList(),
        'playCounts': _playCounts,
      });
    } catch (_) {
      error = const UiMessage(MessageId.saveFailed);
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
