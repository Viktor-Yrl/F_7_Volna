import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/app_controller.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/library/library_controller.dart';
import 'package:music_player_full/player/playback_controller.dart';
import 'fake_player.dart';

class SlowSeekPlayer extends FakePlayer {
  final release = Completer<void>();
  @override
  Future<void> seek(Duration? position, {int? index}) async {
    await release.future;
    await super.seek(position, index: index);
  }
}

class UnavailableMedia extends MediaLibrary {
  bool online = false;
  @override
  bool get supported => true;
  @override
  Future<List<Track>> scanFolder(String uri) async {
    if (!online) throw StateError('Offline SD');
    return [const Track(id: 'folder:a', uri: 'content://sd/a', title: 'A')];
  }
}

void main() {
  test(
    'a slow seek followed by replacing the queue must not disable Pause',
    () async {
      final native = SlowSeekPlayer();
      final player = PlaybackController(player: native);
      addTearDown(player.dispose);
      const a = Track(
        id: 'folder:a',
        title: 'A',
        uri: 'file:///a.mp3',
        durationMs: 60000,
      );
      const b = Track(
        id: 'folder:b',
        title: 'B',
        uri: 'file:///b.mp3',
        durationMs: 60000,
      );
      await player.playTracks([a]);
      final seeking = player.seek(const Duration(seconds: 8));
      await player.playTracks([b]);
      native.release.complete();
      await seeking;
      expect(player.current?.id, b.id);
      expect(player.playing, isTrue);
      await player.toggle();
      expect(
        player.playing,
        isFalse,
        reason: 'Pause on the new track should work',
      );
    },
  );

  test(
    'temporary folder failure must not erase the saved queue on pause',
    () async {
      final dir = await Directory.systemTemp.createTemp('volna_audit_');
      final store = LibraryStore(directory: Future.value(dir));
      final media = UnavailableMedia();
      final app = AppController(
        library: LibraryController(store: store, media: media),
        playback: PlaybackController(player: FakePlayer()),
      );
      addTearDown(() async {
        await app.dispose();
        await dir.delete(recursive: true);
      });
      await store.write('library', {
        'folders': [
          {'uri': 'tree:sd', 'name': 'SD'},
        ],
      });
      await store.write('playback', {
        'ids': ['folder:a'],
        'currentId': 'folder:a',
        'positionMs': 8500,
      });
      await app.initialize();
      expect(app.library.error, isNotNull);
      await app.savePlayback();
      expect((await store.read('playback'))['ids'], ['folder:a']);
      expect((await store.read('playback'))['positionMs'], 8500);
      media.online = true;
      await app.library.scan();
      await Future<void>.delayed(Duration.zero);
      expect(app.playback.current?.id, 'folder:a');
      expect(app.playback.position.inMilliseconds, 8500);
      expect(app.playback.playing, isFalse);
      await app.playback.stop(clearQueue: true);
      await app.savePlayback();
      expect((await store.read('playback'))['ids'], isEmpty);
    },
  );
}
