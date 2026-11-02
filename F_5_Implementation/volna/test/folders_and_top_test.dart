import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/library/library_controller.dart';
import 'package:music_player_full/player/listening_tracker.dart';

class FolderMedia extends MediaLibrary {
  MusicFolder? selection;
  final content = <String, List<Track>>{};
  final revoked = <String>{};
  @override
  bool get supported => true;
  @override
  Future<MusicFolder?> pickFolder() async => selection;
  @override
  Future<List<Track>> scanFolder(String uri) async {
    if (revoked.contains(uri)) throw StateError('Permission revoked');
    return content[uri] ?? [];
  }
}

void main() {
  const track = Track(
    id: 'folder:1',
    uri: 'content://music/1',
    title: 'Song',
    origin: 'folder',
  );
  test(
    'listen threshold excludes clicks, seeks, pause and radio; repeat counts',
    () {
      var count = 0;
      final tracker = ListeningTracker((_) => count++);
      for (var second = 0; second <= 10; second++) {
        tracker.sample(
          track,
          Duration(seconds: second),
          const Duration(seconds: 60),
          active: true,
        );
      }
      expect(count, 0);
      tracker.sample(
        track,
        const Duration(seconds: 40),
        const Duration(seconds: 60),
        active: true,
      );
      expect(count, 0);
      tracker.sample(
        track,
        const Duration(seconds: 40),
        const Duration(seconds: 60),
        active: false,
      );
      tracker.sample(
        track,
        const Duration(seconds: 40),
        const Duration(seconds: 60),
        active: true,
      );
      for (var second = 41; second <= 60; second++) {
        tracker.sample(
          track,
          Duration(seconds: second),
          const Duration(seconds: 60),
          active: true,
        );
      }
      expect(count, 1);
      for (var second = 0; second <= 35; second++) {
        tracker.sample(
          track,
          Duration(seconds: second),
          const Duration(seconds: 60),
          active: true,
        );
      }
      expect(count, 2);
      for (var second = 0; second <= 90; second++) {
        tracker.sample(
          const Track(
            id: 'r',
            uri: 'https://example.com',
            title: 'R',
            origin: 'radio',
          ),
          Duration(seconds: second),
          Duration.zero,
          active: true,
        );
      }
      expect(count, 2);
    },
  );
  group('Folder library and top', () {
    late Directory root;
    late LibraryStore store;
    late FolderMedia media;
    late LibraryController library;
    setUp(() async {
      root = await Directory.systemTemp.createTemp('volna_folders_');
      store = LibraryStore(directory: Future.value(root));
      media = FolderMedia();
      library = LibraryController(store: store, media: media);
      await library.initialize();
    });
    tearDown(() async {
      library.dispose();
      await store.flush();
      await root.delete(recursive: true);
    });
    test(
      'selection persists, overlap deduplicates, removal never deletes original',
      () async {
        media.selection = const MusicFolder(uri: 'tree:a', name: 'A');
        media.content['tree:a'] = [track];
        await library.addFolder();
        media.selection = const MusicFolder(uri: 'tree:b', name: 'B');
        media.content['tree:b'] = [track];
        await library.addFolder();
        expect(library.tracks, hasLength(1));
        expect(library.folders, hasLength(2));
        final reloaded = LibraryController(store: store, media: media);
        await reloaded.initialize();
        expect(reloaded.folders, hasLength(2));
        expect(reloaded.tracks.single.id, track.id);
        await reloaded.removeFolder('tree:a');
        expect(reloaded.tracks, hasLength(1));
        await reloaded.removeFolder('tree:b');
        expect(reloaded.tracks, isEmpty);
        expect(reloaded.folders, isEmpty);
        expect(media.content['tree:a'], [track]);
        reloaded.dispose();
      },
    );
    test(
      'cancel and revoked permission handled without losing configuration',
      () async {
        await library.addFolder();
        expect(library.folders, isEmpty);
        media.selection = const MusicFolder(uri: 'tree:a', name: 'A');
        media.content['tree:a'] = [track];
        await library.addFolder();
        media.revoked.add('tree:a');
        await library.scan();
        expect(library.error?.names, contains('A'));
        expect(library.tracks, isEmpty);
        expect(library.folders, hasLength(1));
        expect(library.busy, isFalse);
      },
    );
    test('top capped at 100, counts persist, radios excluded', () async {
      media.selection = const MusicFolder(uri: 'tree:a', name: 'A');
      media.content['tree:a'] = List.generate(
        105,
        (i) => Track(
          id: 'f$i',
          uri: 'content://$i',
          title: 'Track $i',
          origin: 'folder',
        ),
      );
      await library.addFolder();
      for (final song in library.tracks) {
        await library.recordPlay(song);
      }
      await library.recordPlay(library.find('f104')!);
      await library.recordPlay(
        const Track(
          id: 'radio',
          uri: 'https://example.com',
          title: 'R',
          origin: 'radio',
        ),
      );
      expect(library.topTracks, hasLength(100));
      expect(library.topTracks.first.id, 'f104');
      expect(library.playCount('radio'), 0);
      final reloaded = LibraryController(store: store, media: media);
      await reloaded.initialize();
      expect(reloaded.playCount('f104'), 2);
      expect(reloaded.topTracks, hasLength(100));
      reloaded.dispose();
    });
  });
}
