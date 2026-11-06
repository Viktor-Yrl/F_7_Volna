# Volna Test Plan

Updated: 2026-11-06. Scope: Android preview `1.6.0+11`, tag `v1.6.0`.
This plan targets the current requirements, not retired single-file/import features.

## Scope and Methods

Test Top 100, folder-style Playlists, Radio, Settings, the full/mini player,
background controls and state restoration. Android 7.0 / API 24 is the build
minimum; the published artifact is ARM64. iOS is excluded.

- Logic tests: persistence, folder access, queue handling and listening counts.
- Widget tests: controls, navigation, translations, artwork and layout.
- Static analysis: Dart/Flutter diagnostics.
- Network smoke tests: stream resolution and receipt of audio/playlist data.
- Physical-device acceptance: audible playback and Android integration.

Offline/mocked tests do not certify native playback or live stations.
Use a fresh install and an in-place update where signatures allow it.
Record the APK checksum so results refer to the correct artifact.

## Acceptance Scenarios

| Area | Steps | Expected result |
| --- | --- | --- |
| Launch | Install/open the APK on compatible ARM64 Android | No crash; Top 100 opens first |
| Add folder | Cancel picker, then select a folder containing nested audio | Safe cancellation; accessible songs appear |
| Refresh | Add/remove files externally, then refresh | Selected folders reflect current contents |
| Overlapping folders | Select a parent and nested folder | Correct per-folder membership without duplicated global identities |
| Folder queue | Open a folder and select a track or app-bar Play | That folder's queue starts at the intended item |
| Remove folder | Remove a selection while stopped and while its music is queued | Entry removed; originals untouched; required queue access retained |
| Access loss | Revoke access/reinsert storage, refresh and reselect if needed | Clear error and recovery without silently losing saved selection |
| Playback | Play/pause, stop, seek, previous/next, queue selection | Correct audio and state, including queue boundaries |
| Slow commands | Seek then switch track/queue; stop during loading | Stale operations do not disable or control the new transport |
| Modes | Shuffle and repeat off/one/all | Behavior matches the selected local mode |
| Top 100 | Listen normally; test pause, seek, replay and radio | Only qualified local listening counts; maximum 100, ranked correctly |
| Restoration | Change settings/queue/position and restart | State restores without autoplay |
| Unavailable saved queue | Restart with inaccessible storage, restore access | Saved checkpoint is not erased; restoration can retry |
| Background | Minimize, lock screen and use system controls | Playback and controls function on the target phone |
| Notifications | Grant and deny notification permission | Both outcomes handled; refusal does not block starting audio |
| Interruptions | Calls, competing audio, wired headset and Bluetooth | Audio/session state responds correctly |
| Language | Switch English/Russian while playing; restart | Selection persists; user filenames are unchanged |
| Theme | Switch Dark/Mist Blue while playing; restart | Immediate change and persistent preference |
| Layout | Small/wide screens, long names, larger fonts | Usable controls without incoherent overlap |
| Radio | Test every catalog entry and station switching | Correct branding plus audio, or clear failure state |
| Network | Disconnect/reconnect; retry a failed station | No crash or misleading active-playing state |
| Stability | Run an extended session under battery restrictions | Record continuity and resource/battery observations |

Known-duration play qualification is half the duration clamped to 1-30 seconds;
unknown durations require 30 seconds. Seek jumps, pause and radio are excluded.

## Commands

From the repository root:

```powershell
cd F_5_Implementation/volna
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

For an audit without dependency resolution, use `flutter analyze --no-pub` and
`flutter test --no-pub`. Optional live checks from the application directory:

```powershell
flutter test --dart-define=CHECK_LIVE_RADIO=true test/radio_resolver_test.dart
```

Run live checks separately: upstream access refusal or a network failure is not
an offline logic regression. Never disable TLS validation to make a check pass.

## Recording and Exit Criteria

Record date, version/commit, APK SHA-256, phone model, Android version, network,
scenario, expected/actual result and evidence. Use PASS, FAIL, BLOCKED or NOT RECORDED.
Sanitize logs/screenshots; do not attach personal music, passwords or signing keys.

Current results: [D_2_Test_Results.md](D_2_Test_Results.md).
Open limitations: [D_3_Known_Issues.md](D_3_Known_Issues.md).
Requirements: [current specification](../F_1_Tasks_and_Requirements/D_1_Tasks_and_Requirements.md).

A public preview must disclose failures. Stable/store acceptance additionally
requires recorded phone checks, production signing and publication review.
