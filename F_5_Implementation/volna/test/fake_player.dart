import 'dart:async';
import 'package:just_audio/just_audio.dart';

class FakePlayer implements AudioPlayer {
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final positions = StreamController<Duration>.broadcast(sync: true);
  final durations = StreamController<Duration?>.broadcast(sync: true);
  final indexes = StreamController<int?>.broadcast(sync: true);
  final errors = StreamController<PlayerException>.broadcast(sync: true);
  Completer<Duration?>? pendingLoad;
  bool preloaded = true, active = false, cleared = false, failLoop = false;
  int current = 0, length = 0;
  Duration lastSeek = Duration.zero;
  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Stream<Duration> get positionStream => positions.stream;
  @override
  Stream<Duration?> get durationStream => durations.stream;
  @override
  Stream<int?> get currentIndexStream => indexes.stream;
  @override
  Stream<PlayerException> get errorStream => errors.stream;
  @override
  bool get hasNext => current < length - 1;
  @override
  bool get hasPrevious => current > 0;
  @override
  Future<Duration?> setAudioSources(
    List<AudioSource> sources, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
    ShuffleOrder? shuffleOrder,
  }) async {
    length = sources.length;
    current = initialIndex ?? 0;
    preloaded = preload;
    indexes.add(current);
    return pendingLoad == null
        ? const Duration(seconds: 60)
        : pendingLoad!.future;
  }

  @override
  Future<void> play() async {
    active = true;
    states.add(PlayerState(true, ProcessingState.ready));
  }

  @override
  Future<void> pause() async {
    active = false;
    states.add(PlayerState(false, ProcessingState.ready));
  }

  @override
  Future<void> stop() async {
    active = false;
    states.add(PlayerState(false, ProcessingState.idle));
  }

  @override
  Future<void> clearAudioSources() async {
    length = 0;
    cleared = true;
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    lastSeek = position ?? Duration.zero;
    if (index != null) {
      current = index;
      indexes.add(index);
    }
    positions.add(lastSeek);
  }

  @override
  Future<void> seekToNext() => seek(Duration.zero, index: current + 1);
  @override
  Future<void> seekToPrevious() => seek(Duration.zero, index: current - 1);
  @override
  Future<void> setLoopMode(LoopMode mode) async {
    if (failLoop) throw StateError('loop');
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {}
  @override
  Future<void> shuffle() async {}
  @override
  Future<void> dispose() async {
    await states.close();
    await positions.close();
    await durations.close();
    await indexes.close();
    await errors.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
