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
  @override
  Future<List<Track>> scanFolder(String uri) async => [
    const Track(id: 'folder:one', uri: 'content://one', title: 'Local song'),
  ];
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
  late FakePlayer native;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('music_widget_test_');
    final store = LibraryStore(directory: Future.value(root));
    app = AppController(
      library: LibraryController(store: store, media: OfflineMedia()),
      playback: PlaybackController(player: native = FakePlayer()),
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
      expect(find.text('BBC World Service'), findsOneWidget);
      // The catalog is longer than a phone viewport; verify its entire scroll.
      for (final station in app.library.stations) {
        await tester.scrollUntilVisible(
          find.text(station.title),
          160,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();
        expect(find.text(station.title), findsOneWidget);
        expect(find.text(station.artist), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
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
      native.positions.add(const Duration(seconds: 12));
      await tester.pump();
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        .2,
      );
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
      native.positions.add(const Duration(seconds: 15));
      await tester.pump();
      expect(find.text('0:15'), findsOneWidget);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 15000);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(app.dispose);
    });
  }
  testWidgets('ranking retains play counts without favorites', (tester) async {
    await tester.runAsync(app.dispose);
    await tester.runAsync(() async {
      final store = MemoryLibraryStore(root);
      app = AppController(
        library: LibraryController(store: store, media: OfflineMedia()),
        playback: PlaybackController(player: FakePlayer()),
      );
      await store.write('library', {
        'folders': [
          {'uri': 'tree:music', 'name': 'Music'},
        ],
      });
      await app.initialize();
      await app.library.recordPlay(app.library.tracks.single);
    });
    await tester.pumpWidget(MusicApp(controller: app));
    await tester.pumpAndSettle();
    expect(find.text('Local song'), findsOneWidget);
    for (final light in [false, true]) {
      await tester.runAsync(() => app.settings.setLightTheme(light));
      await tester.pumpAndSettle();
      final count = find.text('1');
      final scheme = Theme.of(tester.element(count)).colorScheme;
      expect(tester.widget<Text>(count).style?.color, scheme.primary);
      expect(scheme.brightness, light ? Brightness.light : Brightness.dark);
    }
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.text('Add to playlist'), findsNothing);
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
