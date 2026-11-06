# Volna

[Русская версия](README.ru.md)

Android music player built with Flutter. Version 1.6.0+11.
The maintained application is in `F_5_Implementation/volna`; no separate MVP
application directory is present in the current checkout.

[Download Android ARM64 preview](https://github.com/Viktor-Yrl/F_7_Volna/releases/download/v1.6.0/Volna-1.6.0-android-arm64.apk)
or view the [v1.6.0 release](https://github.com/Viktor-Yrl/F_7_Volna/releases/tag/v1.6.0).
The published APK requires Android 7.0 / API 24 or newer and an ARM64 device.

## Scope

Four main tabs: Top 100, Playlists (selected folders), Radio and Settings.
Playback controls, the full player and background audio remain available.
The former playlist editor, import/copy/hash workflow and unused form dialogs
are removed. file_picker is removed; crypto is no longer a direct dependency
(it may remain transitively required by other packages).

## Features

- Selected phone folders with persistent read access and recursive music scanning.
- Folder-style Playlists entries with track counts; each folder plays its own queue.
- Queue, play/pause, seek, previous/next, shuffle and repeat one/all.
- Top 100 based on local qualified listening: 30 seconds or half a short track.
  Radio and seeking do not count toward listening time.
- Background playback, media notification and lock-screen controls.
- Twelve built-in stations with bundled logos, English-language stations first:
  BBC World Service, Comedy UK, 181.FM Comedy Club, Capital, Heart, LBC, WBUR,
  Marusya FM, Europa Plus, Retro FM, Radio Shanson and Humor FM.
  Stream availability is broadcaster-controlled. Capital, Heart and LBC returned
  HTTP 401 in the latest check; see the radio source notes below.
- Saved queue and position without automatic playback on startup.

## Navigation and Language

Tabs: **Top 100, Playlists, Radio, Settings**. Top 100 opens first.
The **Playlists > +** button opens the system folder picker directly.
Open a selected folder to play its music, including tracks from nested folders.
Refresh using the refresh icon; remove a folder selection through its menu.
Only selected folders are listed. Manual playlists and files imported or downloaded
by previous versions are not loaded. To play a file in shared storage, select its folder.

English is the default regardless of the phone language. Switch between
English and Русский under **Settings > Language**. The choice survives restart
and does not interrupt playback. Personal metadata and folder names are not
translated. Android system permission dialogs follow the system language.

There is no music download feature. Radio is a fixed catalog and does not support manually adding stations.

## Run and Build

Install Flutter and the Android SDK, then connect an Android phone with USB
debugging enabled or start an Android emulator. The clean-clone build was
verified with Flutter 3.38.9 (Dart 3.10.8).

After downloading or cloning the repository, open a terminal at the repository
root (the folder containing this README) and run:

```powershell
cd F_5_Implementation/volna
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
flutter build apk --release --split-per-abi
```

All build paths and source paths below are relative to
`F_5_Implementation/volna`, not the repository root.

For Samsung Galaxy S10e use
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.
Release signing still uses the template debug key; configure a private
release key before store publication.
Android application ID: `dev.viktoryarmarkin.music_player_full`.

## Source Layout

```text
lib/
  main.dart               Audio service initialization
  app.dart                Theme and localization
  app_controller.dart     Coordination and playback checkpoints
  data/                   Models, JSON persistence and native media bridge
  library/                Selected folders and listening statistics
  player/                 Playback controller, full player and mini player
  settings/               Language/theme preferences and settings tab
  l10n/                   ARB translations and generated localization classes
  ui/                     Main navigation, folder views and shared track widgets
android/                  Android host, document-tree access and media service
assets/                   Cover image and station logos
test/                     Data, folder access, playback and widget tests
```

Edit translations in `lib/l10n/app_en.arb` and `app_ru.arb`, then run
`flutter gen-l10n`. Do not edit generated Dart localization classes.
Main source-code comments are in English. iOS platform files are frozen;
development and build verification currently target Android only.

## File Guide

Paths below are relative to `F_5_Implementation/volna/lib`.

### Root Files

- `main.dart` - Entry point: initializes the audio service and starts the app.
- `app.dart` - Configures the Flutter app, theme and localization.
- `app_controller.dart` - Connects the library, player and settings; coordinates startup and playback checkpoints.

### data - Data

- `models.dart` - Defines track and selected-folder data, including titles, locations and duration.
- `library_store.dart` - Reads and writes local application data as JSON files.
- `media_library.dart` - Bridges Dart and Android for folder selection, music scanning and access management.
- `radio_catalog.dart` - Bundled station names, stream URLs and logo asset paths.
- `radio_resolver.dart` - Checks stream URLs and handles redirects and playlists.
- `radio_artwork_cache.dart` - Prepares local radio artwork for the system media notification.

### l10n - Translations

- `app_en.arb` - English application text.
- `app_ru.arb` - Russian application text. ARB files contain data, not Dart code.
- `app_localizations.dart` - Shared interface for accessing translations from code.
- `app_localizations_en.dart` - Generated English translations.
- `app_localizations_ru.dart` - Generated Russian translations.
- `strings.dart` - Convenient access to translations and localized track/station labels.
- `ui_message.dart` - Defines interface messages and errors for display in the selected language.

The three `app_localizations*.dart` files are generated by `flutter gen-l10n`.
Edit translations in the ARB files, not in the generated Dart files.

### library - Music Library

- `library_controller.dart` - Adds, refreshes and removes selected folders; maintains tracks and Top 100 statistics.

### player - Playback

- `playback_controller.dart` - Controls playback, pause, seeking, the queue, repeat and shuffle.
- `listening_tracker.dart` - Tracks actual listening time and decides when a play qualifies for statistics.
- `player_screen.dart` - Full player screen and bottom mini player with playback controls.

### settings - Preferences

- `app_settings.dart` - Stores and persists the selected language and theme.
- `settings_screen.dart` - Displays the language and theme settings screen.

### ui - Screens and Shared Elements

- `home_screen.dart` - Main navigation with Top 100, Playlists, Radio and Settings tabs.
- `folder_tracks_screen.dart` - Displays tracks from a selected folder.
- `track_tile.dart` - Track rows, the error banner and the shared action for starting playback from a list.
- `track_artwork.dart` - Displays the shared local-track cover or a station logo.

## Project Documentation

The stage documents describe the current Android preview rather than the
retired single-file MVP workflow:

- [Requirements](F_1_Tasks_and_Requirements/D_1_Tasks_and_Requirements.md)
- [Minimum version scope](F_2_First_Version_MVP/D_1_First_Version_MVP.md)
- [Current interface](F_3_Interface_Design/D_1_Interface_Description.md)
- [Technical decisions](F_4_Technical_Decisions/D_1_Technical_Decisions.md)
- [Test plan](F_6_Testing_and_Quality_Assurance/D_1_Test_Plan.md), [results](F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md) and [known issues](F_6_Testing_and_Quality_Assurance/D_3_Known_Issues.md)
- [Release information](F_7_Release_and_Maintenance/D_3_Release_Info.md), [checklist](F_7_Release_and_Maintenance/D_1_Release_Checklist.md) and [changelog](F_7_Release_and_Maintenance/D_2_Changelog.md)

The latest audit passed 39 offline tests and clean analysis. Current-build
physical-phone acceptance remains unrecorded. See the results for verification
boundaries; a published preview is not a claim of Google Play readiness.

## Data and Access

Volna stores selected folder references, play counts, language and the
playback checkpoint locally. Music is read in place. Removing a folder from
Playlists never deletes its audio files. Old collections are not migrated.
Folder access is granted by the Android system picker; no device-wide music
or storage permission is requested. Notification permission is separate.

## Limitations and Verification

- Radio needs internet; availability and endpoints depend on the broadcaster.
  See [RADIO_SOURCES.md](F_5_Implementation/volna/RADIO_SOURCES.md).
- Built-in station URLs use HTTPS. Android currently permits cleartext traffic
  for playback compatibility; invalid TLS certificates are not bypassed.
- MP3 is the primary target; other codecs depend on platform decoders.
- Local tracks use a shared cover; embedded album artwork is not extracted.
- Deleted source files or revoked folder access can make saved tracks unavailable.
- No single-file import, manual playlist editing, file downloading, manual radio
  catalog editing, DRM, equalizer or cloud sync.
- iOS requires separate macOS/Xcode, signing and device verification and is not
  an active supported target.

Run `flutter test` for automated checks. Manual results and verification limits
are recorded in [QA.md](F_5_Implementation/volna/QA.md).
