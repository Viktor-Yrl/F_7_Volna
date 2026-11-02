import 'dart:async';

import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models.dart';
import '../data/radio_resolver.dart';
import '../data/radio_artwork_cache.dart';
import 'listening_tracker.dart';
import '../l10n/ui_message.dart';

/// Owns the single audio engine and exposes stream-driven state to the UI.
class PlaybackController extends ChangeNotifier {
  PlaybackController({AudioPlayer? player, RadioResolver? radioResolver})
    : _player = player ?? AudioPlayer(),
      _radioResolver = radioResolver ?? RadioResolver() {
    _subscriptions.addAll([
      _player.playerStateStream.listen((state) {
        if (_disposed) return;
        playing =
            !_failed &&
            state.playing &&
            state.processingState != ProcessingState.completed;
        completed = state.processingState == ProcessingState.completed;
        buffering =
            state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        if (completed && duration > Duration.zero) position = duration;
        _listening.sample(
          current,
          position,
          duration,
          active: playing && !buffering && !busy && !_command,
        );
        _notify();
      }),
      _player.positionStream.listen((value) {
        if (!_disposed) {
          _listening.sample(
            current,
            value,
            duration,
            active: playing && !buffering && !busy && !_command,
          );
          position = value;
          _notify();
        }
      }),
      _player.durationStream.listen((value) {
        if (_disposed) return;
        duration = current?.isRadio == true
            ? Duration.zero
            : value ?? Duration(milliseconds: current?.durationMs ?? 0);
        _notify();
      }),
      _player.currentIndexStream.listen((value) {
        if (_disposed || value == null || value >= _queue.length) return;
        if (index != value) _listening.reset();
        index = value;
        _notify();
      }),
      _player.errorStream.listen((failure) {
        if (_disposed) return;
        debugPrint('Audio playback error: $failure');
        _failed = true;
        playing = false;
        error = current?.isRadio == true
            ? const UiMessage(MessageId.stationUnavailable)
            : const UiMessage(MessageId.playbackFailed);
        _notify();
      }),
    ]);
  }
  final AudioPlayer _player;
  final RadioResolver _radioResolver;
  final _artwork = RadioArtworkCache();
  void Function(Track)? onQualifiedPlay;
  late final _listening = ListeningTracker(
    (track) => onQualifiedPlay?.call(track),
  );
  final _subscriptions = <StreamSubscription<dynamic>>[];
  List<Track> _queue = [];
  List<Track> get queue => List.unmodifiable(_queue);
  int index = 0;
  Track? get current =>
      index >= 0 && index < _queue.length ? _queue[index] : null;
  bool _disposed = false, _failed = false, _command = false;
  int _generation = 0;
  bool playing = false, completed = false, buffering = false, busy = false;
  bool shuffle = false;
  LoopMode repeat = LoopMode.off;
  Duration position = Duration.zero, duration = Duration.zero;
  UiMessage? error;
  bool get canSeek =>
      current != null &&
      !current!.isRadio &&
      duration > Duration.zero &&
      !busy &&
      !_command;
  bool get hasNext => !busy && _queue.length > 1 && _player.hasNext;
  bool get hasPrevious => !busy && current != null && !current!.isRadio;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    error = null;
    _notify();
  }

  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    bool autoplay = true,
    Duration initialPosition = Duration.zero,
  }) async {
    if (_disposed || busy || tracks.isEmpty) return;
    // A later stop/load invalidates pending async work from this generation.
    final generation = ++_generation;
    busy = true;
    error = null;
    _notify();
    try {
      await _player.stop();
      if (_disposed || generation != _generation) return;
      _queue = List.of(tracks);
      _listening.reset();
      index = startIndex.clamp(0, tracks.length - 1);
      position = tracks[index].isRadio ? Duration.zero : initialPosition;
      duration = Duration(milliseconds: tracks[index].durationMs);
      completed = false;
      _notify();
      final sources = <AudioSource>[];
      // Resolve station streams and attach local artwork for system media controls.
      for (final track in tracks) {
        final uri = track.isRadio && autoplay
            ? await _radioResolver.resolve(track.uri)
            : Uri.parse(track.uri);
        final artwork = track.isRadio ? await _artwork.uriFor(track) : null;
        if (_disposed || generation != _generation) return;
        sources.add(
          AudioSource.uri(
            uri,
            tag: MediaItem(
              id: track.id,
              title: track.title,
              artist: track.artist,
              album: track.isRadio ? 'Live radio' : track.album,
              duration: track.durationMs > 0
                  ? Duration(milliseconds: track.durationMs)
                  : null,
              isLive: track.isRadio,
              artUri: artwork,
            ),
          ),
        );
      }
      await _player
          .setAudioSources(
            sources,
            initialIndex: index,
            initialPosition: position,
            preload: autoplay,
          )
          .timeout(const Duration(seconds: 30));
      if (_disposed || generation != _generation) return;
      await _player.setLoopMode(current!.isRadio ? LoopMode.off : repeat);
      if (_disposed || generation != _generation) return;
      await _player.setShuffleModeEnabled(!current!.isRadio && shuffle);
      if (_disposed || generation != _generation) return;
      if (shuffle && !current!.isRadio) await _player.shuffle();
      if (_disposed || generation != _generation) return;
      _failed = false;
      if (autoplay) unawaited(_play());
    } catch (failure) {
      if (_disposed || generation != _generation) return;
      debugPrint('Audio source load error: $failure');
      _failed = true;
      playing = false;
      error = failure is LocalizedException
          ? failure.localized
          : current?.isRadio == true
          ? const UiMessage(MessageId.stationUnavailable)
          : const UiMessage(MessageId.sourceUnavailable);
      try {
        await _player.stop();
      } catch (_) {}
    } finally {
      if (generation == _generation) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> _play() async {
    final generation = _generation;
    try {
      await _player.play();
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _failed = true;
        playing = false;
        error = current?.isRadio == true
            ? const UiMessage(MessageId.stationUnavailable)
            : const UiMessage(MessageId.playbackFailed);
        _notify();
      }
    }
  }

  Future<void> toggle() async {
    if (_disposed || current == null || busy || _command) return;
    if (_failed) {
      await playTracks(_queue, startIndex: index);
      return;
    }
    if (current!.isRadio && !playing) {
      await playTracks(_queue, startIndex: index);
      return;
    }
    _command = true;
    _notify();
    try {
      if (playing) {
        await _player.pause();
      } else {
        if (completed) {
          _listening.reset();
          await _player.seek(Duration.zero);
        }
        if (!_disposed) unawaited(_play());
      }
    } catch (_) {
      error = const UiMessage(MessageId.toggleFailed);
    } finally {
      _command = false;
      _notify();
    }
  }

  Future<void> seek(Duration value) async {
    if (!canSeek) return;
    await _safe(
      () => _player.seek(
        Duration(
          milliseconds: value.inMilliseconds.clamp(0, duration.inMilliseconds),
        ),
      ),
    );
  }

  Future<void> next() async {
    if (hasNext) {
      await _safe(_player.seekToNext);
    }
  }

  Future<void> previous() async {
    if (!hasPrevious) return;
    await _safe(
      () => _player.hasPrevious
          ? _player.seekToPrevious()
          : _player.seek(Duration.zero),
    );
  }

  Future<void> selectQueueIndex(int value) async {
    if (busy || _command || value < 0 || value >= _queue.length) return;
    final success = await _safe(
      () => _player.seek(Duration.zero, index: value),
    );
    if (!_disposed && success) unawaited(_play());
  }

  Future<void> setRepeat(LoopMode value) async {
    final success = await _safe(
      () =>
          _player.setLoopMode(current?.isRadio == true ? LoopMode.off : value),
    );
    if (success) repeat = value;
    _notify();
  }

  Future<void> setShuffle(bool value) async {
    final success = await _safe(() async {
      await _player.setShuffleModeEnabled(current?.isRadio != true && value);
      if (value) await _player.shuffle();
    });
    if (success) shuffle = value;
    _notify();
  }

  Future<void> stop({bool clearQueue = false}) async {
    if (_disposed) return;
    final generation = ++_generation;
    busy = true;
    _command = false;
    _notify();
    try {
      await _player.stop();
      if (clearQueue) await _player.clearAudioSources();
    } catch (_) {
      error = const UiMessage(MessageId.stopFailed);
    }
    if (_disposed || generation != _generation) return;
    if (clearQueue) {
      _queue = [];
      index = 0;
      position = Duration.zero;
      duration = Duration.zero;
    }
    playing = false;
    buffering = false;
    completed = false;
    busy = false;
    _notify();
  }

  Future<bool> _safe(Future<void> Function() action) async {
    // Serialize transport commands and ignore results from superseded loads.
    if (_disposed || busy || _command) return false;
    final generation = _generation;
    _command = true;
    error = null;
    _notify();
    try {
      await action();
      return !_disposed && generation == _generation;
    } catch (_) {
      if (!_disposed && generation == _generation) {
        error = const UiMessage(MessageId.playerCommandFailed);
      }
      return false;
    } finally {
      if (generation == _generation) {
        _command = false;
        _notify();
      }
    }
  }

  Map<String, dynamic> checkpoint() => {
    'ids': _queue.map((e) => e.id).toList(),
    'currentId': current?.id,
    'positionMs': current?.isRadio == true ? 0 : position.inMilliseconds,
    'repeat': repeat.name,
    'shuffle': shuffle,
  };
  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}
