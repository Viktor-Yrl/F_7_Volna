import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/app.dart';
import 'package:music_player_full/app_controller.dart';
import 'package:music_player_full/data/library_store.dart';
import 'package:music_player_full/data/media_library.dart';
import 'package:music_player_full/library/library_controller.dart';
import 'package:music_player_full/player/playback_controller.dart';
import 'package:music_player_full/settings/app_settings.dart';
import 'package:music_player_full/l10n/app_localizations_en.dart';
import 'package:music_player_full/l10n/app_localizations_ru.dart';
import 'package:music_player_full/l10n/ui_message.dart';
import 'fake_player.dart';

class NoDeviceMedia extends MediaLibrary {
  @override
  bool get supported => false;
}

class FailingSettingsStore extends LibraryStore {
  FailingSettingsStore(Future<Directory> directory)
    : super(directory: directory);
  @override
  Future<void> write(String name, Map<String, dynamic> data) async {
    throw const FileSystemException('Read-only storage');
  }
}

void main() {
  late Directory root;
  late LibraryStore store;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('volna_language_');
    store = LibraryStore(directory: Future.value(root));
  });
  tearDown(() async => root.delete(recursive: true));

  test(
    'English default, Russian persistence, unsupported locale fallback',
    () async {
      final settings = AppSettings(store);
      await settings.initialize();
      expect(settings.languageCode, 'en');
      await settings.setLanguage('ru');
      final restored = AppSettings(store);
      await restored.initialize();
      expect(restored.languageCode, 'ru');
      await restored.setLanguage('en');
      expect((await store.read('settings'))['language'], 'en');
      await store.write('settings', {'language': 'fr'});
      await restored.initialize();
      expect(restored.languageCode, 'en');
      settings.dispose();
      restored.dispose();
    },
  );

  test(
    'failed save retains current language and reports typed error',
    () async {
      final settings = AppSettings(FailingSettingsStore(Future.value(root)));
      await settings.setLanguage('ru');
      expect(settings.languageCode, 'en');
      expect(settings.saving, false);
      expect(settings.error?.id, MessageId.settingsSaveFailed);
      settings.dispose();
    },
  );

  test(
    'counts and existing errors can be translated without changing data',
    () {
      final en = AppLocalizationsEn();
      final ru = AppLocalizationsRu();
      expect(en.trackCount(1), '1 track');
      expect(en.trackCount(5), '5 tracks');
      expect(ru.trackCount(1), '1 трек');
      expect(ru.trackCount(2), '2 трека');
      expect(ru.trackCount(5), '5 треков');
      const message = UiMessage(MessageId.sourceUnavailable);
      expect(message.localize(en), isNot(message.localize(ru)));
    },
  );

  for (final size in [
    const Size(320, 640),
    const Size(412, 915),
    const Size(1024, 768),
  ]) {
    testWidgets(
      'settings switches both languages without losing route at $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final app = AppController(
          library: LibraryController(store: store, media: NoDeviceMedia()),
          playback: PlaybackController(player: FakePlayer()),
        );
        await tester.runAsync(() async {
          await store.write('library', {
            'playlists': [
              {'id': 'old:list', 'name': 'Моя музыка', 'trackIds': <String>[]},
            ],
          });
          await app.initialize();
        });
        await tester.pumpWidget(MusicApp(controller: app));
        await tester.pumpAndSettle();
        expect(find.text('Top 100'), findsWidgets);
        await tester.tap(find.text('Settings').last);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.text('Русский'));
          await store.flush();
        });
        await tester.pumpAndSettle();
        expect(find.text('Настройки'), findsWidgets);
        expect(find.text('Язык'), findsOneWidget);
        await tester.tap(find.text('Плейлисты').last);
        await tester.pumpAndSettle();
        expect(find.text('Моя музыка'), findsOneWidget);
        await tester.tap(find.text('Настройки').last);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.text('English'));
          await store.flush();
        });
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsWidgets);
        await tester.tap(find.text('Playlists').last);
        await tester.pumpAndSettle();
        expect(find.text('Моя музыка'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(app.dispose);
      },
    );
  }
}
