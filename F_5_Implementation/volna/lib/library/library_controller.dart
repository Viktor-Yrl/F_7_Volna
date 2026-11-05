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
  final List<MusicFolder> _folders = [];
  Set<String>? _savedRoots;
  Set<String> _queueRoots = {};
  bool _incompleteScan = false;
  bool get incompleteScan => _incompleteScan;
  Map<String, Track> _tracksById = {};
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
  List<Track> get tracks => List.unmodifiable(_tracksById.values);
  List<Track> get stations => RadioCatalog.stations;
  Track? find(String id) =>
      _tracksById[id] ??
      stations.where((station) => station.id == id).firstOrNull;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    error = null;
    _notify();
  }

  // A document URI contains the exact tree grant used to open it. Overlapping
  // roots may expose the same song through different grants.
  Future<void> updateQueueRoots(List<Track> queue) async {
    _queueRoots = {
      for (final track in queue)
        if (track.uri.startsWith('content://') &&
            track.uri.contains('/document/'))
          track.uri.substring(0, track.uri.indexOf('/document/')),
    };
    if (!busy) await _syncGrants();
  }

  Future<void> _syncGrants() async {
    final saved = _savedRoots;
    if (saved == null || _disposed) return;
    try {
      await media.keepFolderGrants({
        ...saved,
        ..._folders.map((f) => f.uri),
        ..._queueRoots,
      });
    } catch (_) {
      error = const UiMessage(MessageId.folderCleanupFailed);
      _notify();
    }
  }

  Future<void> initialize() async {
    // Restore user metadata before scanning currently accessible audio sources.
    busy = true;
    _notify();
    try {
      final data = await store.read('library');
      _folders.addAll(
        (data['folders'] as List? ?? []).map(
          (e) => MusicFolder.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      final counts = Map<String, dynamic>.from(
        data['playCounts'] as Map? ?? {},
      );
      for (final entry in counts.entries) {
        if (entry.key.startsWith('folder:') &&
            entry.value is num &&
            (entry.value as num) > 0) {
          _playCounts[entry.key] = (entry.value as num).toInt();
        }
      }
      error = store.warning;
      if (error == null) _savedRoots = _folders.map((f) => f.uri).toSet();
      await _refreshFolders();
    } catch (_) {
      _incompleteScan = true;
      error = const UiMessage(MessageId.libraryLoadFailed);
    } finally {
      busy = false;
      await _syncGrants();
      _notify();
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
      await _syncGrants();
      _notify();
    }
  }

  Future<void> _refreshFolders({
    Map<String, List<Track>> scanned = const {},
  }) async {
    final tracks = <String, Track>{};
    final failed = <String>[];
    _tracksByFolder.clear();
    for (final folder in _folders) {
      try {
        final rows = scanned[folder.uri] ?? await media.scanFolder(folder.uri);
        final found =
            {for (final track in rows) track.id: track}.values.toList()..sort(
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
    _tracksById = tracks;
    _incompleteScan = failed.isNotEmpty;
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
      final rows = await media.scanFolder(folder.uri);
      _folders.removeWhere((e) => e.uri == folder.uri);
      _folders.add(folder);
      await _refreshFolders(scanned: {folder.uri: rows});
      await save();
    } catch (_) {
      error = const UiMessage(MessageId.folderOpenFailed);
    } finally {
      busy = false;
      await _syncGrants();
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
      await _syncGrants();
      _notify();
    }
  }

  Future<void> recordPlay(Track track) async {
    if (_disposed || track.isRadio) return;
    _playCounts.update(track.id, (value) => value + 1, ifAbsent: () => 1);
    _notify();
    await save();
  }

  Future<void> save() async {
    final roots = _folders.map((f) => f.uri).toSet();
    try {
      await store.write('library', {
        'version': 3,
        'folders': _folders.map((e) => e.toJson()).toList(),
        'playCounts': _playCounts,
      });
      _savedRoots = roots;
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
