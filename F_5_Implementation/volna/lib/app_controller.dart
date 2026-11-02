import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'data/library_store.dart';
import 'data/models.dart';
import 'library/library_controller.dart';
import 'player/playback_controller.dart';
import 'settings/app_settings.dart';

/// Coordinates storage, playback statistics and restoration across app screens.
class AppController {
  AppController({required this.library, required this.playback}) {
    playback.addListener(_scheduleCheckpoint);
    playback.onQualifiedPlay = (track) => unawaited(library.recordPlay(track));
  }
  final LibraryController library;
  final PlaybackController playback;
  LibraryStore get store => library.store;
  late final settings = AppSettings(store);
  Timer? _checkpointTimer;
  bool _disposed = false, _restoring = true;
  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _initialize();
  Future<void> _initialize() async {
    await settings.initialize();
    if (_disposed) return;
    await library.initialize();
    try {
      final data = await store.read('playback');
      if (_disposed) return;
      await playback.setRepeat(
        LoopMode.values.firstWhere(
          (e) => e.name == data['repeat'],
          orElse: () => LoopMode.off,
        ),
      );
      await playback.setShuffle(data['shuffle'] == true);
      final ids = (data['ids'] as List? ?? []).cast<String>();
      final tracks = <Track>[
        for (final id in ids)
          if (library.find(id) case final Track track) track,
      ];
      if (tracks.isNotEmpty && !_disposed) {
        final index = tracks.indexWhere((e) => e.id == data['currentId']);
        await playback.playTracks(
          tracks,
          startIndex: index < 0 ? 0 : index,
          autoplay: false,
          initialPosition: Duration(
            milliseconds: index < 0
                ? 0
                : ((data['positionMs'] as num?)?.toInt() ?? 0).clamp(
                    0,
                    86400000,
                  ),
          ),
        );
      }
    } catch (_) {
      // A damaged checkpoint must not prevent selecting new music.
    } finally {
      _restoring = false;
    }
  }

  void _scheduleCheckpoint() {
    // Throttle position writes instead of writing on every player stream event.
    if (_disposed || _restoring || _checkpointTimer != null) return;
    _checkpointTimer = Timer(const Duration(seconds: 10), () {
      _checkpointTimer = null;
      unawaited(savePlayback());
    });
  }

  Future<void> savePlayback() async {
    if (_disposed || _restoring) return;
    try {
      await store.write('playback', playback.checkpoint());
    } catch (_) {
      // A checkpoint write failure must not interrupt the current audio.
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    await savePlayback();
    _disposed = true;
    _checkpointTimer?.cancel();
    playback.removeListener(_scheduleCheckpoint);
    playback.onQualifiedPlay = null;
    playback.dispose();
    library.dispose();
    settings.dispose();
    await store.flush();
  }
}
