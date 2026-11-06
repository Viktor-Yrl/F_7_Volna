# Verification History

## Current Baseline - 2026-11-06

Current application source: `1.6.0+11`, published pre-release `v1.6.0`,
tag commit `5e3ccb3d7d1c4b340c002049ec1987b7c7d08e83`.

- The documentation audit reran all 39 offline tests and Flutter analysis successfully.
- GitHub API confirms the public pre-release and its ARM64 APK. The asset digest
  matches the local APK SHA-256; the recorded size is 21,903,593 bytes.
- The APK minimum is API 24, target API 36, native ABI arm64-v8a,
  versionName 1.6.0 and split versionCode 2011.
- Current scope is Top 100, selected-folder Playlists, fixed 12-station Radio,
  Settings, full/mini player, background audio and persisted English/Russian
  plus Dark/Mist Blue choices.
- Downloads, favorites, manual playlists, single-file import, custom radio
  editing, device-wide scanning and active iOS delivery are excluded.
- Live streams were not retested during the documentation audit. Earlier network
  observations remain qualified by their environment and date.
- Full physical-phone acceptance is not recorded for this exact artifact.

The authoritative current documents are
[D_2_Test_Results.md](../../F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md),
[D_3_Known_Issues.md](../../F_6_Testing_and_Quality_Assurance/D_3_Known_Issues.md) and
[D_3_Release_Info.md](../../F_7_Release_and_Maintenance/D_3_Release_Info.md).
The project owner handles documentation commits and pushes.

## Historical Development Records

Everything below is retained historical evidence, beginning with the original
2026-10-27 verification log. Some sections have retrospective dates, different
test totals and removed features. They are not the current specification or
acceptance report, and their old scope must not be interpreted as still implemented.

## Folder-only library / 2026-11-05

- 35 current tests passed; Flutter analysis reported no issues. Checks cover
  a clean install, direct folder picking, manual refresh and a restart with
  favorites, play counts, language, queue and playback position preserved.
- A mixed snapshot test confirms that retired collection fields and unrelated
  track IDs are ignored. Saving the library does not modify audio files.
- This replaces earlier compatibility checks for single-file imports, manual
  playlists, downloaded files, custom stations and device-wide MediaStore IDs.

## Playback, folder refresh and radio checks / 2026-11-05

- All 41 offline tests passed; Flutter analysis reported no issues. Tests
  cover isolated position notifications, slider and mini-player progress,
  reading a newly selected folder once, and refreshing all folders from the UI.
- For a separate network smoke test, run
  `flutter test --dart-define=CHECK_LIVE_RADIO=true test/radio_resolver_test.dart`.
  The check resolves each catalog URL and reads from the stream or HLS playlist;
  it does not verify Android decoding or audible playback.
- BBC World Service, Comedy UK and 181.FM Comedy Club returned stream data or
  a playlist. Marusya FM and Europa Plus timed out before HTTP from this
  network; independent requests to both original addresses also timed out.

## Four-Tab Scope / 1.6.0 / 2026-11-01

- Playlists retains its name and displays selected folders. The plus button
  opens the system folder picker directly without a source menu.
- Removed manual playlist creation/editing, single-file import, copying,
  SHA-256 deduplication, private-file deletion commands and unused dialogs.
  Removed playlist_screen.dart, dialogs.dart and track_actions.dart.
- Existing playlist records have a small immutable SavedPlaylist compatibility
  model and open in the existing folder-track view without editing controls.
  Old imported/downloaded files remain under Saved files; JSON keys, IDs,
  order, favorites, statistics, queue references and original files are retained.
- Removed file_picker and its unused transitive dependencies. crypto is no
  longer direct but remains required transitively by other packages.
- Removed 49 unused translation messages per language and the unused native
  import-metadata bridge. Home is 321 lines; LibraryController is 280 lines.
- 41 tests passed, including direct folder picking, saved collection order,
  read-only collections across reload, previous files, favorites, Top 100,
  background-player state logic and language/layout checks at three sizes.
- Android split release builds succeeded. ARM64 is Volna 1.6.0, versionCode
  2011, native-code arm64-v8a, about 21.2 MiB versus 22.8 MiB previously.
- No device/emulator is connected, so physical playback is not verified here.
  ios/ hashes match the initial snapshot; its auto-generated registration
  change from dependency resolution was restored to keep that platform frozen.
- Both README files describe the reduced scope and compatibility behavior.

## Download Feature Removed / 1.5.2 / 2026-11-01

- Removed the download screen, manager, navigation entry, AppController wiring,
  file-download import method, download-only messages and obsolete tests.
  The lib/downloads directory is no longer present.
- Existing origin=download records remain private owned tracks. No user files
  or persisted library data are deleted. Imported files still exposes them.
- Added storage and widget regression checks for old downloaded files, playlist
  references, favorites, statistics and playback. Source menu checks verify that
  downloading is absent at 320x640, 412x915 and 1024x768.
- 40 tests passed; static analysis reported no issues. Split Android release
  builds succeeded: Volna 1.5.2, ARM64 versionCode 2010, native-code arm64-v8a.
- README files now document the current folder/radio feature set rather than
  historical download capabilities.
- No Android device or emulator is connected; no on-device check is claimed.
  ios/ file hashes match the pre-change snapshot.

## Structural Cleanup / 1.5.1 / 2026-11-01

- Removed duplicate FoldersScreen and its menu entry; selected folders remain
  managed directly in Playlists. Settings is now a tab only.
- DownloadsScreen owns its dialog, progress, playback controls and route.
  TrackActions is shared between downloads and Top 100. Home decreased from
  627 to 381 lines; library and audio ownership remain in their controllers.
- Removed full-device scan mode, unused toggles and permission-request API.
  Refresh scans only selected folders. A targeted legacy-ID resolver retains
  playlist, favorite, history and queue references using already granted access.
  Resolved metadata is stored in schema 2; unresolved references are not erased.
- Upgrade tests cover referenced-ID-only queries, persistence across restart,
  absent permission/retry, language and checkpoint preservation, and no device
  database queries on fresh installs. Widget tests cover the extracted download
  route/dialog at three sizes, favorites and playlist assignment.
- 43 tests passed; flutter analyze reported no issues. Debug and split release
  Android builds succeeded. ARM64 package is Volna 1.5.1 / versionCode 2009.
- Emulator/phone was unavailable at final install attempt (adb: no devices);
  no on-device validation is claimed for this maintenance release.
- ios/ file hashes are identical to the pre-change snapshot. Both README files
  describe current folder access and legacy compatibility.

## Folder Playlists and Navigation / 1.5.0 / 2026-11-01

- Tabs are Top 100, Playlists, Radio, Settings; the Music screen is removed.
- Selected document-tree roots display as yellow folders with track counts.
  Opening one shows only its recursively scanned music and plays that queue.
  Custom playlists and private imported/downloaded files remain accessible.
- Per-root membership is separate from global track deduplication. Tests cover
  overlapping roots, removal of a root and isolation of playback queues.
- 39 tests passed; static analysis reported no issues. English/Russian switching
  tested with the new Settings tab at phone and tablet sizes.
- Emulator: saved Volna_QA folder restored, displayed two tracks including the
  nested track, opened successfully and played both local songs in order.
  Verified Settings as a bottom tab and Top 100 as the initial screen.
- Screenshots: navigation_15.png, folders_15.png, folder_tracks_15.png,
  settings_tab_15.png in the task QA directory.
- Android split release APKs built. iOS is not a development/build target for
  this change; hashes of files under ios/ are unchanged from the initial snapshot.
- Physical Android phone verification remains outstanding.

## English / Russian Localization / 1.4.0 / 2026-11-01

- English is the default independently of the device locale. Settings provides
  English / Русский selection and persists it in settings.json.
- 37 tests passed; flutter analyze reported no issues. Added coverage for
  defaults, saved language restoration, unsupported locales, failed saves,
  plural counts and language switching at 320x640, 412x915 and 1024x768.
- Existing personal playlist names remain unchanged after switching languages.
- Android emulator: English library and settings verified, switched to Russian,
  force-stopped and relaunched; Russian library labels and selected folders
  restored correctly. Switched back to English while 181.FM continued PLAYING.
- Screenshots: language_en.png, settings_en.png, settings_ru.png,
  language_ru_restart.png and settings_final.png in the task QA directory.
- Release split APKs built and x86_64 release installed as an in-place update.
  ARM64 package: Volna 1.4.0, versionCode 2007, native-code arm64-v8a.
- Main README is English; README.ru.md contains Russian documentation.
- Project remains under F_7_Volna; the previous project root was not recreated.
- Physical Android phone and iOS device verification remain outstanding.

## Comedy Stations and Artwork / 1.3.0 / 2026-11-01

- Comedy UK and 181.FM Comedy Club added; catalog remains read-only with five
  entries and stable existing station IDs.
- Both new streams reached Android media-session PLAYING with advancing
  position and correct station metadata on the emulator.
- Official logo assets bundled for all five stations. Catalog, mini player and
  full-player screenshots checked; the full player shows station branding rather
  than the mountain placeholder. Native metadata now carries local artwork.
- 31 tests passing, including actual image decoding, complete-logo containment,
  local notification-artwork preparation, caching and nonfatal artwork failure.
- Static analysis clean. Main Dart/Kotlin code comments are English; Russian
  UI strings remain unchanged. No Cyrillic comment lines remain in lib/Kotlin.
- Screenshots: five_logos.png and 181_full_player.png in the task QA directory.
- Android notification shade visually verified the 181.FM brand artwork in the
  media card (radio_notification_logo.png). Release split APK build succeeded;
  ARM64 package reports Volna 1.3.0, versionCode 2006, arm64-v8a.
- Physical S10e and iOS testing remain outstanding.

## Fixed Radio Catalog / 1.2.0 / 2026-11-01

- Built-in Marusya FM, Europa Plus (Russia), BBC World Service (English).
- No add, edit or delete controls; obsolete station mutation methods removed.
- 29 passing tests; catalog availability on a fresh store, immutable entries,
  stable IDs, upgrade archive preservation and known legacy-ID migration tested.
- Widget checks at 320x640, 412x915 and 1024x768 assert all three station names
  and absence of station add/action menus.
- Native emulator checks: each station reached Android media-session PLAYING
  with advancing position and correct metadata. Europa Plus MP3 and BBC HLS
  switching tested. Marusya had one transient connect timeout; retry succeeded.
- Resolver now returns the validated final redirect URI so the decoder does not
  select a second random CDN server. Local redirect regression test passed.
- Source checks and maintenance notes: RADIO_SOURCES.md.
- Availability still depends on external station servers and local network.

## Update 2026-11-01 / 1.1.0

- 28 automated tests passing, including folder persistence/overlap/revocation,
  Top-100 cap and ordering, listening threshold/seek/pause/repeat, radio URL
  resolution, HTML audio extraction, HLS preservation and invalid website errors.
- Android native debug build passed. System folder picker selected Volna_QA;
  both a root MP3 and a nested MP3 appeared without broad audio permission.
- Actual playback of both documents succeeded. Both appeared in Top-100 with
  one qualified play each. Mini player exposes previous/play/next controls.
- Actual marus.fm homepage entered in the radio form: resolver selected the
  public stream used by the official website. Android media session reported
  PLAYING with advancing position and the radio screen showed Pause, no error.
- Official stream endpoint checked: HTTPS redirect, HTTP 200, audio/mpeg.
- New screenshots are in the task workspace's music_player_qa directory:
  folder_tracks.png, top100_playing.png, radio_confirmed.png.
- Physical Samsung S10e and iOS acceptance testing remain outstanding.

## Automated

- Flutter 3.38.9 / Dart 3.10.8.
- `flutter analyze`: no issues.
- `flutter test`: 22 passing tests.
- Debug Android APK: successful build and installation.
- Release split APKs: successful build for armeabi-v7a, arm64-v8a, x86_64.
- Release x86_64 APK installed over debug without clearing the library.

## Observed on Android 16 / API 36.1 Emulator

- First launch renders the library without a layout exception.
- Audio permission prompt is shown after requesting a scan.
- After granting permission, MediaStore returns the test MP3 in Downloads.
- Selecting a track requests notification permission and starts playback.
- After Home, Android `dumpsys media_session` reports this application's active
  media session with state PLAYING, title and queue metadata.
- Download through the UI from the public Samplelib HTTPS MP3 URL completes.
  The resulting file is listed in Downloads and can be selected for playback.
- Player UI renders cover, title, progress, queue and transport controls.
- After installing release and restarting, both the device track and downloaded
  copy remain listed. The queue and position restore without autoplay.
- Under heavy host load the emulator MP3 codec produced a renderer failure.
  The application did not crash. An additional regression test verifies that a
  decoder error cannot leave the UI indicating playback and that retry works.

## Still Requires Device Acceptance Testing

- Physical Samsung S10e, long playback and battery-management restrictions.
- Lock-screen/headset controls, calls, audio focus and Bluetooth routing.
- Actual long-running radio stations and connection loss/reconnection behavior.
  Radio URL validation, persistence, disabled seeking and dialog input are
  covered automatically; a real broadcast station has not been certified.
- Full manual playlist CRUD/reordering and multi-file system picker on devices.
  Core import/playlist persistence and protection of original files are covered
  automatically using temporary files and an injected metadata provider.
- iOS build, signing, picker and background audio on macOS/physical iPhone.
- Store signing, privacy declarations and publication review.

This is a functional Android development build, not a claim of store readiness.
No changes were made to the sibling MVP. Its main.dart SHA-256 remained
`789351A3AA22722CB912210AF2167C6196FB0F5C4C11D3BFB6C24F6C4990AFBA`.
