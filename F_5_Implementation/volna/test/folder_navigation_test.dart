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
import 'fake_player.dart';

class SelectedFolderMedia extends MediaLibrary {
  int pickerCalls = 0;
  final scans = <String>[];
  MusicFolder? selection;
  @override
  Future<MusicFolder?> pickFolder() async {
    pickerCalls++;
    return selection;
  }

  final contents = <String, List<Track>>{
    'root-a': [const Track(id: 'a', uri: 'file:///a.mp3', title: 'Only A')],
    'root-b': [const Track(id: 'b', uri: 'file:///b.mp3', title: 'Only B')],
  };
  @override
  bool get supported => true;
  @override
  Future<void> requestNotifications() async {}
  @override
  Future<List<Track>> scanFolder(String uri) async {
    scans.add(uri);
    return contents[uri]!;
  }
}

void main() {
  late Directory root;
  late LibraryStore store;
  late SelectedFolderMedia media;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('volna_folder_navigation_');
    store = LibraryStore(directory: Future.value(root));
    media = SelectedFolderMedia();
    await store.write('library', {
      'folders': [
        const MusicFolder(uri: 'root-a', name: 'Block N1').toJson(),
        const MusicFolder(uri: 'root-b', name: 'Block N2').toJson(),
      ],
    });
  });
  tearDown(() async => root.delete(recursive: true));

  test(
    'folder membership stays separate while global tracks deduplicate',
    () async {
      media.contents['root-b'] = [
        ...media.contents['root-a']!,
        ...media.contents['root-b']!,
      ];
      final library = LibraryController(store: store, media: media);
      await library.initialize();
      expect(library.tracksForFolder('root-a').map((e) => e.id), ['a']);
      expect(library.tracksForFolder('root-b').map((e) => e.id), ['a', 'b']);
      expect(library.tracks.length, 2);
      await library.removeFolder('root-a');
      expect(library.tracksForFolder('root-a'), isEmpty);
      expect(library.tracksForFolder('root-b').length, 2);
      library.dispose();
    },
  );

  testWidgets('folder opens only its tracks and plays its own queue', (
    tester,
  ) async {
    final app = AppController(
      library: LibraryController(store: store, media: media),
      playback: PlaybackController(player: FakePlayer()),
    );
    await tester.runAsync(app.initialize);
    await tester.pumpWidget(MusicApp(controller: app));
    await tester.pumpAndSettle();
    expect(find.text('Top 100'), findsWidgets);
    expect(find.text('Music'), findsNothing);
    await tester.tap(find.text('Playlists').last);
    await tester.pumpAndSettle();
    expect(find.text('Block N1'), findsOneWidget);
    expect(find.text('Block N2'), findsOneWidget);
    expect(find.text('1 track'), findsNWidgets(2));
    await tester.tap(find.text('Block N1'));
    await tester.pumpAndSettle();
    expect(find.text('Only A'), findsOneWidget);
    expect(find.text('Only B'), findsNothing);
    await tester.tap(find.text('Only A'));
    await tester.pumpAndSettle();
    expect(app.playback.queue.map((e) => e.id), ['a']);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block N2'));
    await tester.pumpAndSettle();
    expect(find.text('Only B'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(app.dispose);
  });

  testWidgets('plus opens the folder picker directly without a source menu', (
    tester,
  ) async {
    media.selection = const MusicFolder(uri: 'root-c', name: 'New folder');
    media.contents['root-c'] = [];
    final app = AppController(
      library: LibraryController(store: store, media: media),
      playback: PlaybackController(player: FakePlayer()),
    );
    await tester.runAsync(app.initialize);
    await tester.pumpWidget(MusicApp(controller: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Playlists').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add folder'));
    // Let real JSON writes finish between fake animation frames.
    for (var attempt = 0; attempt < 500 && app.library.busy; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(app.library.busy, isFalse);
    await tester.pumpAndSettle();
    expect(media.pickerCalls, 1);
    expect(media.scans.where((uri) => uri == 'root-c'), hasLength(1));
    expect(find.text('New folder'), findsOneWidget);
    // A manual refresh bypasses the add-folder snapshot and reads every root.
    media.scans.clear();
    media.contents['root-c'] = [
      ...media.contents['root-a']!,
      ...media.contents['root-b']!,
    ];
    media.contents['root-b'] = [];
    await tester.tap(find.byTooltip('Refresh library'));
    await tester.pumpAndSettle();
    expect(media.scans, ['root-a', 'root-b', 'root-c']);
    expect(find.text('2 tracks'), findsOneWidget);
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    expect(find.text('Only A'), findsOneWidget);
    expect(find.text('Only B'), findsOneWidget);
    expect(find.text('Create playlist'), findsNothing);
    expect(find.text('Add files'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(app.dispose);
  });
}
