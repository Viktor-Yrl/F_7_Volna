# Volna

[Русская версия](README.ru.md)

Android music player built with Flutter. Version 1.6.0+11.
The sibling `music_player` MVP is a separate project and is not modified.

## Scope

Four main tabs: Top 100, Playlists (selected folders), Radio and Settings.
Playback controls, the full player and background audio remain available.
The former playlist editor, import/copy/hash workflow and unused form dialogs
are removed. file_picker is removed; crypto is no longer a direct dependency
(it may remain transitively required by other packages).

## Features

- Selected phone folders with persistent read access and recursive music scanning.
- Folder-style Playlists entries with track counts; each folder plays its own queue.
- Favorites, queue, play/pause, seek, previous/next, shuffle and repeat one/all.
- Top 100 based on local qualified listening: 30 seconds or half a short track.
  Radio and seeking do not count toward listening time.
- Background playback, media notification and lock-screen controls.
- Five built-in stations with bundled logos: Marusya FM, Europa Plus,
  BBC World Service, Comedy UK and 181.FM Comedy Club.
- Saved queue and position without automatic playback on startup.

## Navigation and Language

Tabs: **Top 100, Playlists, Radio, Settings**. Top 100 opens first.
The **Playlists > +** button opens the system folder picker directly.
Open a selected folder to play its music, including tracks from nested folders.
Refresh using the refresh icon; remove a folder selection through its menu.
Playlists is the name of the folder tab. New manual playlists and single-file
imports are not supported. Existing playlists are available as read-only saved
collections; previous imports remain under Saved files.

English is the default regardless of the phone language. Switch between
English and Русский under **Settings > Language**. The choice survives restart
and does not interrupt playback. Personal metadata and playlist names are not
translated. Android system permission dialogs follow the system language.

**Music downloading has been removed.** There is no download screen or URL
download command. Previously downloaded files remain under Saved files;
their files, favorites, playlist references and statistics are preserved.
Radio is a fixed catalog and does not support manually adding stations.

## Run and Build

Run these commands from this project directory:

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
flutter build apk --release --split-per-abi
```

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
  library/                Folders, imports, playlists and statistics
  player/                 Playback controller, full player and mini player
  settings/               Language preference and settings tab
  l10n/                   ARB translations and generated localization classes
  ui/                     Main navigation, folder views and shared track widgets
android/                  Android host, document-tree access and media service
assets/                   Cover image and station logos
test/                     Data, migration, playback and widget tests
```

Edit translations in `lib/l10n/app_en.arb` and `app_ru.arb`, then run
`flutter gen-l10n`. Do not edit generated Dart localization classes.
Main source-code comments are in English. iOS platform files are frozen;
development and build verification currently target Android only.

## Data and Access

JSON stores library metadata, favorites, playlists, statistics, language and
playback checkpoints locally. Writes are serialized; corrupt JSON is backed up.
Folder access is granted through the system picker. Music is played in place:
no new private copies are created. Removing a folder selection never deletes
its originals. Files copied by older versions remain accessible and unchanged.
There are no in-app commands for deleting audio files or editing saved collections.
Uninstalling the app removes its private data and files. There is no cloud backup.

The old full-device scan mode is removed. References to legacy MediaStore tracks
are restored by ID with already granted permission only, then cached in schema 2
under Saved device tracks. Unresolved references are retained, not erased.
Broad audio permission declarations remain only for that compatibility path;
the app does not request a new broad audio grant. Notification permission is
requested for playback.

## Limitations and Verification

- Radio needs internet; availability and endpoints depend on the broadcaster.
  See [RADIO_SOURCES.md](RADIO_SOURCES.md).
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
are recorded in [QA.md](QA.md).
