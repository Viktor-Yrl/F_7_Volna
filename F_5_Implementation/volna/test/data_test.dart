import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/library/library_controller.dart';

class FakeMedia extends MediaLibrary {
  @override
  bool get supported => false;
}

void main() {
  test('URL accepts only direct HTTP(S) without embedded credentials', () {
    expect(parseAudioUrl(' https://example.com/song.mp3 ').host, 'example.com');
    for (final value in [
      'file:///private.mp3',
      'javascript:bad',
      'https://a:b@example.com',
      'not a link',
    ]) {
      expect(() => parseAudioUrl(value), throwsFormatException);
    }
  });
  test('Track JSON round trip and unique playlist order', () {
    const track = Track(
      id: '1',
      uri: 'file:///one.mp3',
      title: 'One',
      durationMs: 61000,
    );
    expect(Track.fromJson(track.toJson()).title, 'One');
    expect(
      SavedPlaylist(id: 'p', name: 'List', trackIds: ['b', 'a', 'b']).trackIds,
      ['b', 'a'],
    );
    expect(formatTime(const Duration(seconds: 3661)), '1:01:01');
  });
  group('Persistent library', () {
    late Directory root;
    late LibraryStore store;
    setUp(() async {
      root = await Directory.systemTemp.createTemp('music_full_test_');
      store = LibraryStore(directory: Future.value(root));
    });
    tearDown(() async {
      await store.flush();
      await root.delete(recursive: true);
    });
    test('serialized writes preserve newest snapshot', () async {
      await Future.wait(
        List.generate(10, (i) => store.write('state', {'value': i})),
      );
      expect((await store.read('state'))['value'], 9);
    });
    test('corrupt JSON preserved as backup', () async {
      await File('${root.path}/library.json').writeAsString('{broken');
      expect(await store.read('library'), isEmpty);
      expect(
        root.listSync().where((e) => e.path.contains('.corrupt-')),
        hasLength(1),
      );
    });
    test(
      'legacy files and read-only playlists survive restart unchanged',
      () async {
        final file = await File(
          '${root.path}/original.mp3',
        ).writeAsBytes([73, 68, 51]);
        final track = Track(
          id: 'import:old',
          uri: file.uri.toString(),
          title: 'Original',
        );
        final list = SavedPlaylist(
          id: 'old:list',
          name: 'Old list',
          trackIds: [track.id],
        );
        await store.write('library', {
          'tracks': [track.toJson()],
          'playlists': [list.toJson()],
        });
        final library = LibraryController(store: store, media: FakeMedia());
        await library.initialize();
        await library.toggleFavorite(track.id);
        final restored = LibraryController(store: store, media: FakeMedia());
        await restored.initialize();
        expect(restored.savedFiles.single.id, track.id);
        expect(
          restored
              .savedPlaylistTracks(restored.savedPlaylists.single)
              .single
              .id,
          track.id,
        );
        expect(restored.isFavorite(track.id), isTrue);
        expect(() => restored.savedPlaylists.clear(), throwsUnsupportedError);
        expect(
          () => restored.savedPlaylists.single.trackIds.clear(),
          throwsUnsupportedError,
        );
        expect((await store.read('library'))['playlists'], [list.toJson()]);
        expect(await file.readAsBytes(), [73, 68, 51]);
        library.dispose();
        restored.dispose();
      },
    );
    test(
      'fixed radio catalog available on first install and immutable',
      () async {
        final library = LibraryController(store: store, media: FakeMedia());
        await library.initialize();
        expect(library.stations.map((e) => e.title), [
          'Marusya FM',
          'Europa Plus',
          'BBC World Service',
          'Comedy UK',
          '181.FM Comedy Club',
        ]);
        expect(library.stations.every((e) => e.isRadio), isTrue);
        expect(library.stations.map((e) => e.id).toSet(), hasLength(5));
        expect(() => library.stations.clear(), throwsUnsupportedError);
        for (final station in library.stations) {
          expect(library.find(station.id), same(station));
        }
        await library.save();
        final restored = LibraryController(store: store, media: FakeMedia());
        await restored.initialize();
        expect(
          restored.stations.map((e) => e.id),
          library.stations.map((e) => e.id),
        );
        restored.dispose();
        library.dispose();
      },
    );
    test(
      'removing downloads preserves existing files and saved references',
      () async {
        final directory = await Directory('${root.path}/downloads').create();
        final file = await File(
          '${directory.path}/old.mp3',
        ).writeAsBytes([73, 68, 51]);
        final track = Track(
          id: 'download:old.mp3',
          uri: file.uri.toString(),
          title: 'Saved song',
          origin: 'download',
        );
        await store.write('library', {
          'tracks': [track.toJson()],
          'favorites': [track.id],
          'playlists': [
            SavedPlaylist(
              id: 'saved',
              name: 'Saved',
              trackIds: [track.id],
            ).toJson(),
          ],
          'playCounts': {track.id: 4},
        });
        final library = LibraryController(store: store, media: FakeMedia());
        await library.initialize();
        expect(library.savedFiles.single.id, track.id);
        expect(library.savedFiles.single.origin, 'download');
        expect(
          library.savedPlaylistTracks(library.savedPlaylists.single).single.id,
          track.id,
        );
        expect(library.isFavorite(track.id), isTrue);
        expect(library.playCount(track.id), 4);
        await library.save();
        expect(await file.readAsBytes(), [73, 68, 51]);
        final restored = LibraryController(store: store, media: FakeMedia());
        await restored.initialize();
        expect(restored.find(track.id)?.uri, file.uri.toString());
        library.dispose();
        restored.dispose();
      },
    );
    test(
      'upgrade hides custom stations but preserves archive and remaps known queue IDs',
      () async {
        const known = Track(
          id: 'old:marus',
          uri: 'https://marus.fm/',
          title: 'My radio',
          origin: 'radio',
        );
        const custom = Track(
          id: 'old:custom',
          uri: 'https://example.com/live',
          title: 'Custom',
          origin: 'radio',
        );
        await store.write('library', {
          'stations': [known.toJson(), custom.toJson()],
        });
        final library = LibraryController(store: store, media: FakeMedia());
        await library.initialize();
        expect(library.stations, hasLength(5));
        expect(library.find('old:custom'), isNull);
        expect(library.find('old:marus')!.id, 'radio:marusya');
        await library.save();
        expect((await store.read('library'))['stations'], [
          known.toJson(),
          custom.toJson(),
        ]);
        library.dispose();
      },
    );
  });
}
