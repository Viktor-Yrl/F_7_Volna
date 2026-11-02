import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'app_controller.dart';
import 'data/library_store.dart';
import 'library/library_controller.dart';
import 'player/playback_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize native media controls before creating the single audio player.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'dev.viktoryarmarkin.music_player_full.audio',
    androidNotificationChannelName: 'Music playback',
    androidNotificationOngoing: true,
  );
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  final store = LibraryStore();
  // Controllers share persistent storage but keep UI, library and audio separate.
  final app = AppController(
    library: LibraryController(store: store),
    playback: PlaybackController(),
  );
  runApp(MusicApp(controller: app));
}
