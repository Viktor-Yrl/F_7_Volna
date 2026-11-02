import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/app.dart';
import 'package:music_player_full/app_controller.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/library/library_controller.dart';
import 'package:music_player_full/player/playback_controller.dart';
import 'package:music_player_full/player/player_screen.dart';
import 'fake_player.dart';

class OfflineMedia extends MediaLibrary {
  @override
  bool get supported => false;
}

// Keep popup interaction tests independent of FakeAsync filesystem callbacks.
class MemoryLibraryStore extends LibraryStore {
  MemoryLibraryStore(Directory root) : super(directory: Future.value(root));
  final _data = <String, Map<String, dynamic>>{};
  @override
  Future<Map<String, dynamic>> read(String name) async => _data[name] ?? {};
  @override
  Future<void> write(String name, Map<String, dynamic> data) async {
    _data[name] = data;
  }
}

void main() {
  late Directory root;
  late AppController app;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('music_widget_test_');
    final store = LibraryStore(directory: Future.value(root));
    app = AppController(
      library: LibraryController(store: store, media: OfflineMedia()),
      playback: PlaybackController(player: FakePlayer()),
    );
  });
  tearDown(() async {
    await app.dispose();
    await root.delete(recursive: true);
  });
  for (final size in [
    const Size(320, 640),
    const Size(412, 915),
    const Size(1024, 768),
  ]) {
    testWidgets('home and player layout at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(app.initialize);
      await tester.pumpWidget(MusicApp(controller: app));
      await tester.pumpAndSettle();
      expect(find.text('Top 100'), findsWidgets);
      await tester.tap(find.text('Radio').last);
      await tester.pumpAndSettle();
      expect(find.text('Marusya FM'), findsOneWidget);
      expect(find.text('Europa Plus'), findsOneWidget);
      expect(find.text('BBC World Service'), findsOneWidget);
      expect(find.byTooltip('Добавить радио'), findsNothing);
      expect(find.byTooltip('Действия со станцией'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      await tester.tap(find.text('Playlists').last);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Add folder'), findsOneWidget);
      expect(find.text('Create playlist'), findsNothing);
      expect(find.text('Add files'), findsNothing);
      expect(tester.takeException(), isNull);
      await app.playback.playTracks([
        const Track(
          id: 't',
          uri: 'file:///one.mp3',
          title: 'Very long track name for layout validation',
          durationMs: 60000,
        ),
      ], autoplay: false);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Previous track'), findsOneWidget);
      await tester.tap(find.text('Top 100').last);
      await tester.pumpAndSettle();
      expect(find.text('No listening history yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: PlayerScreen(app: app),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(app.dispose);
    });
  }
  testWidgets('ranking retains favorites without playlist editing', (
    tester,
  ) async {
    await tester.runAsync(app.dispose);
    await tester.runAsync(() async {
      final store = MemoryLibraryStore(root);
      app = AppController(
        library: LibraryController(store: store, media: OfflineMedia()),
        playback: PlaybackController(player: FakePlayer()),
      );
      const track = Track(
        id: 'import:old',
        uri: 'file:///old.mp3',
        title: 'Local song',
      );
      await store.write('library', {
        'tracks': [track.toJson()],
      });
      await app.initialize();
      await app.library.recordPlay(track);
    });
    final track = app.library.savedFiles.single;
    await tester.pumpWidget(MusicApp(controller: app));
    await tester.pumpAndSettle();
    expect(find.text('Local song'), findsOneWidget);
    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pumpAndSettle();
    expect(app.library.isFavorite(track.id), isTrue);
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    expect(find.text('Add to playlist'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(app.dispose);
  });

  testWidgets('previously downloaded tracks remain accessible and playable', (
    tester,
  ) async {
    const track = Track(
      id: 'download:old',
      uri: 'file:///old.mp3',
      title: 'Previously saved song',
      origin: 'download',
    );
    await tester.runAsync(() async {
      await app.store.write('library', {
        'tracks': [track.toJson()],
      });
      await app.initialize();
    });
    await tester.pumpWidget(MusicApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Playlists').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved files'));
    await tester.pumpAndSettle();
    expect(find.text(track.title), findsOneWidget);
    await tester.tap(find.text(track.title));
    await tester.pumpAndSettle();
    expect(app.playback.current?.id, track.id);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(app.dispose);
  });

  testWidgets('player tolerates zero first frame then normal screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size.zero;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: PlayerScreen(app: app)));
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(412, 915);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
