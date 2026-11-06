import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/app_controller.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/library/library_controller.dart';
import 'package:music_player_full/player/playback_controller.dart';
import 'fake_player.dart';

class _SelectedMedia extends MediaLibrary {
  int scans = 0;
  @override
  Future<List<Track>> scanFolder(String uri) async {
    scans++;
    expect(uri, 'tree:music');
    return [const Track(id: 'folder:one', uri: 'content://one', title: 'Song')];
  }
}

void main() {
  late Directory root;
  late LibraryStore store;
  late _SelectedMedia media;
  AppController open() => AppController(
    library: LibraryController(store: store, media: media),
    playback: PlaybackController(player: FakePlayer()),
  );
  setUp(() async {
    root = await Directory.systemTemp.createTemp('volna_folders_only_');
    store = LibraryStore(directory: Future.value(root));
    media = _SelectedMedia();
  });
  tearDown(() async {
    await store.flush();
    await root.delete(recursive: true);
  });

  test('clean install has no local music until a folder is selected', () async {
    final app = open();
    await app.initialize();
    expect(app.library.folders, isEmpty);
    expect(app.library.tracks, isEmpty);
    expect(app.library.topTracks, isEmpty);
    expect(app.playback.queue, isEmpty);
    expect(media.scans, 0);
    expect(app.library.stations, hasLength(12));
    await app.dispose();
  });

  test('only folder and catalog references survive a mixed snapshot', () async {
    const id = 'folder:one';
    final original = await File(
      '${root.path}/original.mp3',
    ).writeAsBytes([73, 68, 51]);
    await store.write('library', {
      'folders': [
        {'uri': 'tree:music', 'name': 'Music'},
      ],
      'tracks': [
        {'id': 'import:old', 'uri': original.uri.toString()},
      ],
      'playlists': [
        {
          'name': 'Old mix',
          'trackIds': ['import:old'],
        },
      ],
      'retainedDeviceTracks': [
        {'id': 'media:1'},
      ],
      'stations': [
        {'id': 'old:radio'},
      ],
      'favorites': [id, 'import:old'],
      'playCounts': {id: 4, 'media:1': 11},
    });
    await store.write('playback', {
      'ids': ['import:old', id, 'media:1'],
      'currentId': id,
      'positionMs': 1234,
    });
    await store.write('settings', {'language': 'ru'});
    final app = open();
    await app.initialize();
    expect(app.library.topTracks.single.id, id);
    expect(app.library.find('old:radio'), isNull);
    expect(app.library.find('radio:marusya')?.isRadio, isTrue);
    expect(app.playback.queue.map((e) => e.id), [id]);
    expect(app.playback.position.inMilliseconds, 1234);
    expect(app.settings.languageCode, 'ru');
    await app.library.recordPlay(app.library.tracks.single);
    await app.dispose();

    final data = await store.read('library');
    expect(data.keys, unorderedEquals(['version', 'folders', 'playCounts']));
    expect(data['playCounts'], {id: 5});
    expect(await original.readAsBytes(), [73, 68, 51]);

    final restarted = open();
    await restarted.initialize();
    expect(restarted.library.folders.single.name, 'Music');
    expect(restarted.library.topTracks.single.id, id);
    expect(restarted.playback.current?.id, id);
    expect(restarted.playback.position.inMilliseconds, 1234);
    expect(restarted.playback.playing, isFalse);
    expect(restarted.settings.languageCode, 'ru');
    await restarted.dispose();
  });
}
