import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/library/library_controller.dart';

class UpgradeMedia extends MediaLibrary {
  final queries = <List<String>>[];
  bool readable = true;
  @override
  Future<List<Track>> restoreLegacyTracks(List<String> ids) async {
    queries.add(List.of(ids));
    if (!readable) return [];
    return ids
        .map(
          (id) => Track(
            id: id,
            uri: 'content://media/external/audio/media/${id.split(':').last}',
            title: id,
            origin: 'device',
          ),
        )
        .toList();
  }
}

void main() {
  late Directory root;
  late LibraryStore store;
  late UpgradeMedia media;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('volna_upgrade_');
    store = LibraryStore(directory: Future.value(root));
    media = UpgradeMedia();
    await store.write('library', {
      'version': 1,
      'folderMode': false,
      'playlists': [
        SavedPlaylist(
          id: 'p',
          name: 'My songs',
          trackIds: ['media:1', 'media:2'],
        ).toJson(),
      ],
      'favorites': ['media:1'],
      'playCounts': {'media:2': 7},
    });
    await store.write('playback', {
      'ids': ['media:3'],
      'currentId': 'media:3',
      'positionMs': 1234,
    });
    await store.write('settings', {'language': 'ru'});
  });
  tearDown(() async {
    await store.flush();
    await root.delete(recursive: true);
  });

  test(
    'upgrade resolves only referenced IDs and preserves user data',
    () async {
      final library = LibraryController(store: store, media: media);
      await library.initialize();
      expect(media.queries.single.toSet(), {'media:1', 'media:2', 'media:3'});
      expect(
        library
            .savedPlaylistTracks(library.savedPlaylists.single)
            .map((e) => e.id),
        ['media:1', 'media:2'],
      );
      expect(library.isFavorite('media:1'), isTrue);
      expect(library.topTracks.single.id, 'media:2');
      expect(library.playCount('media:2'), 7);
      expect(library.retainedDeviceTracks.length, 3);
      final snapshot = await store.read('library');
      expect(snapshot['version'], 2);
      expect(snapshot.containsKey('folderMode'), isFalse);
      expect((await store.read('playback'))['positionMs'], 1234);
      expect((await store.read('settings'))['language'], 'ru');
      library.dispose();

      final restored = LibraryController(store: store, media: media);
      await restored.initialize();
      expect(media.queries.length, 1);
      expect(restored.find('media:3'), isNotNull);
      expect(restored.savedPlaylists.single.name, 'My songs');
      restored.dispose();
    },
  );

  test(
    'missing permission preserves unresolved references for a later retry',
    () async {
      media.readable = false;
      final library = LibraryController(store: store, media: media);
      await library.initialize();
      await library.save();
      expect(library.retainedDeviceTracks, isEmpty);
      expect(library.savedPlaylists.single.trackIds, ['media:1', 'media:2']);
      expect(library.isFavorite('media:1'), isTrue);
      expect(library.playCount('media:2'), 7);
      library.dispose();
      media.readable = true;
      final restored = LibraryController(store: store, media: media);
      await restored.initialize();
      expect(restored.retainedDeviceTracks.length, 3);
      expect(restored.playCount('media:2'), 7);
      restored.dispose();
    },
  );

  test('new install never queries the device-wide media database', () async {
    await store.write('library', {});
    await store.write('playback', {});
    final library = LibraryController(store: store, media: media);
    await library.initialize();
    expect(media.queries, isEmpty);
    expect(library.folders, isEmpty);
    library.dispose();
  });
}
