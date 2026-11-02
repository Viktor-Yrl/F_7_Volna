import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/data/radio_resolver.dart';
import 'package:music_player_full/player/playback_controller.dart';
import 'fake_player.dart';

class OfflineRadio extends RadioResolver {
  @override
  Future<Uri> resolve(String input, {int depth = 0}) async => Uri.parse(input);
}

void main() {
  const tracks = [
    Track(id: '1', uri: 'file:///1.mp3', title: 'One', durationMs: 60000),
    Track(id: '2', uri: 'file:///2.mp3', title: 'Two', durationMs: 60000),
  ];
  late FakePlayer native;
  late PlaybackController player;
  setUp(() {
    native = FakePlayer();
    player = PlaybackController(player: native, radioResolver: OfflineRadio());
  });
  tearDown(() {
    player.dispose();
  });
  test('queue, pause, seek bounds and next', () async {
    await player.playTracks(tracks);
    expect(player.playing, isTrue);
    await player.toggle();
    expect(player.playing, isFalse);
    await player.seek(const Duration(seconds: 99));
    expect(native.lastSeek.inSeconds, 60);
    await player.next();
    expect(player.current!.id, '2');
    await player.selectQueueIndex(0);
    expect(player.current!.id, '1');
  });
  test('restoration does not preload network or autoplay', () async {
    await player.playTracks(tracks, autoplay: false);
    expect(native.preloaded, isFalse);
    expect(native.active, isFalse);
  });
  test('stop invalidates pending load and clears native queue', () async {
    native.pendingLoad = Completer<Duration?>();
    final loading = player.playTracks(tracks);
    await Future<void>.delayed(Duration.zero);
    await player.stop(clearQueue: true);
    native.pendingLoad!.complete(const Duration(seconds: 60));
    await loading;
    expect(player.queue, isEmpty);
    expect(native.active, isFalse);
    expect(native.cleared, isTrue);
    expect(player.busy, isFalse);
    expect(player.error, isNull);
  });
  test('failed setting does not change repeat state', () async {
    native.failLoop = true;
    await player.setRepeat(LoopMode.all);
    expect(player.repeat, LoopMode.off);
    expect(player.error, isNotNull);
  });
  test('radio cannot seek', () async {
    await player.playTracks([
      const Track(
        id: 'r',
        uri: 'https://example.com/live',
        title: 'Radio',
        origin: 'radio',
      ),
    ]);
    expect(player.canSeek, isFalse);
  });
  test('decoder failure cannot leave a misleading playing indicator', () async {
    await player.playTracks(tracks);
    native.errors.add(PlayerException(1, 'Decoder failed', 0));
    native.states.add(PlayerState(true, ProcessingState.idle));
    expect(player.playing, isFalse);
    expect(player.error, isNotNull);
    await player.toggle();
    expect(player.playing, isTrue);
    expect(player.error, isNull);
  });
}
