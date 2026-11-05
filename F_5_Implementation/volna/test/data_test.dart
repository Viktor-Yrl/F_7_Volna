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
  test('folder metadata decodes without stored track records', () {
    final track = Track.fromJson({
      'id': 'folder:1',
      'uri': 'content://one',
      'title': 'One',
    });
    expect(track.title, 'One');
    expect(track.isRadio, isFalse);
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
  });
}
