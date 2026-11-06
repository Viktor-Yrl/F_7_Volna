# Volna Technical Decisions

Updated: 2026-11-06. Baseline: `1.6.0+11`, tag `v1.6.0`,
application source commit `5e3ccb3d7d1c4b340c002049ec1987b7c7d08e83`.

## Platform and Scope

Flutter renders the UI; Dart implements application logic. Android is the active
platform. The published ARM64 build requires Android 7.0 / API 24 or newer;
its target SDK is API 36. iOS files are frozen and not part of current delivery.
There is no application backend, account or cloud synchronization.

Four main tabs are Top 100, Playlists (selected folders), Radio and Settings.
The full player and mini player are additional views. Downloads, favorites,
manual playlists, individual file import and custom radio editing are excluded.

## Dependencies

| Dependency | Configured version | Responsibility |
| --- | --- | --- |
| just_audio | 0.10.6 | Local/stream audio engine and playback queue |
| just_audio_background | 0.0.1-beta.17 | Background integration and media notifications |
| audio_service | 0.18.19 | Android media-service infrastructure |
| audio_session | 0.2.4 | Music audio-session configuration |
| path_provider | 2.1.6 | App-private support-directory location |
| path | ^1.9.1 | Filesystem path handling |
| flutter_localizations | Flutter SDK | Framework localization |
| intl | 0.20.2 | Localization support |
| flutter_test / flutter_lints | SDK / ^6.0.0 | Automated tests and analysis conventions |

The committed lockfile records resolved dependencies. Toolchain used for the
verified checks: Flutter 3.38.9 / Dart 3.10.8.

## Responsibilities and State

- `main.dart` initializes the background service/audio session and launches the app.
- `app.dart` owns MaterialApp configuration, themes and locale.
- `AppController` coordinates library, playback, settings and playback checkpoints.
- `LibraryController` owns selected folders, scanned tracks and play counts.
- `PlaybackController` owns the single audio engine and queue.
- `AppSettings` owns persisted language and appearance preferences.

Feature controllers use Flutter's ChangeNotifier. UI listens to the relevant
controller. Playback position uses a separate ValueNotifier so progress ticks
do not rebuild unrelated track lists. No extra state-management framework is needed.
Source is grouped under `data`, `library`, `player`, `settings`, `l10n` and `ui`;
the repository [README](../README.md) explains individual files.

## Local Music Access

A MethodChannel connects Dart's MediaLibrary to native Android Kotlin.
Android's Storage Access Framework supplies selected document-tree URIs and
persistent read grants. Scanning runs off the Android UI thread, traverses nested
folders and returns audio document identities and filename-based titles.

Files remain in place. There is no import copy, hashing workflow or whole-device
MediaStore scan. MP3 is primary; other audio MIME types/extensions are discovered,
but playback depends on platform decoders. Embedded artist/album tags and cover
images are not extracted; local artwork is shared.

Adding a folder reuses its first scan; refresh scans selected roots. Folder
membership is tracked separately from deduplicated track IDs for overlapping roots.
Grant cleanup retains roots needed by saved folders or the active playback queue.
Removing a folder selection never deletes original audio.

## Audio and Asynchronous Work

The app-level player survives route changes. Async source loads and transport
commands use generation checks/serialization to avoid stale commands controlling
a replacement queue. UI exposes loading, buffering, error and completed states.

Local controls include play/pause, stop, seek, previous/next, queue selection,
shuffle and repeat off/one/all. Radio is loaded as a single-station queue and
disables seeking, shuffle and repeat. Native background integration supplies
media notification and lock-screen controls; real-device behavior still needs
the acceptance checks listed in the test plan.

## Listening Statistics

ListeningTracker samples actual progress and excludes pause, radio and seek jumps.
The qualification threshold is half of a known duration, clamped to 1-30 seconds;
unknown durations require 30 seconds. Qualified plays update persisted counts.
Top 100 shows accessible local tracks with positive counts, sorted by count
descending and title for ties, limited to 100 entries.

## Radio

RadioCatalog supplies 12 immutable entries and stable IDs, English first.
RadioResolver follows redirects and supported stream/playlist endpoints without
scraping arbitrary HTML. RadioArtworkCache prepares bundled images for system
media controls. Catalog/URL changes require an application update.

Current network evidence and origin/image sources are in
[RADIO_SOURCES.md](../F_5_Implementation/volna/RADIO_SOURCES.md).
WBUR reception passed; Capital/Heart/LBC returned HTTP 401; the three newly added
Russian streams encountered TLS failures in the checked environment.
These are recorded observations, not promises of current worldwide availability.

## Persistence

LibraryStore uses dart:convert and local JSON under the application support
directory. Separate snapshots contain folder references/play counts, settings
and playback IDs/current item/position/repeat/shuffle. Writes are serialized,
using a temporary file and replacement; damaged JSON is preserved as a backup.
No SQL database is used.

Startup restores state without autoplay. A temporarily inaccessible folder can
defer queue restoration; checkpoints must not erase that unresolved saved queue.
Position checkpoint writes are throttled rather than performed on every tick.

## Localization and Themes

Editable strings live in `app_en.arb` and `app_ru.arb`. `flutter gen-l10n`
generates three Dart localization files; do not edit those directly.
UiMessage represents localized interface errors. Personal metadata is not translated.
English and Dark are defaults; English/Russian and Dark/Mist Blue are persisted
and change without an app restart.

## Android Security and Release Configuration

Permissions cover internet, wake locks, foreground media playback and notifications.
Folder access is granted by the system picker, not a device-wide storage permission.
Notification permission is separate and optional for starting playback.
Catalog URLs use HTTPS. Cleartext is currently allowed for playback compatibility;
TLS certificate validation and broadcaster access restrictions are not bypassed.

Application ID: `dev.viktoryarmarkin.music_player_full`.
Gradle builds the Android host. The release configuration still uses the template
debug key, so the published artifact is a preview, not production-signed.
The split ARM64 APK has versionName `1.6.0` and versionCode `2011`;
the source build number in pubspec.yaml remains `11`.

## Verification and Distribution

The documentation audit reran all 39 offline tests and Flutter analysis successfully.
The published pre-release APK matches the local APK by SHA-256.
Physical-phone acceptance and production/store checks remain pending.

See [D_2_Test_Results.md](../F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md),
[D_3_Release_Info.md](../F_7_Release_and_Maintenance/D_3_Release_Info.md) and the build
commands there. Documentation commits/pushes are the project owner's responsibility;
this documentation update does not create commits, tags or a new binary.
