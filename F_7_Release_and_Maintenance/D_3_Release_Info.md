# Volna Release Information

Updated: 2026-11-06. Published Android preview: `v1.6.0`.
Public release and asset metadata were confirmed through GitHub's API.

## Release and Artifact

| Field | Recorded value |
| --- | --- |
| Product | Volna |
| Source version | `1.6.0+11` |
| Dart package | `music_player_full` |
| Android application ID | `dev.viktoryarmarkin.music_player_full` |
| Release title | Volna v1.6.0 - Android Preview |
| Release status | Published pre-release, not a draft |
| Publication date | 2026-11-06 |
| Git tag | `v1.6.0` |
| Tag source commit | `5e3ccb3d7d1c4b340c002049ec1987b7c7d08e83` |
| Branch at publication | `Main_branch` |
| Build date recorded | 2026-11-06 |
| Public asset filename | `Volna-1.6.0-android-arm64.apk` |
| Local build filename | `app-arm64-v8a-release.apk` |
| File size | 21,903,593 bytes (about 20.9 MiB) |
| Architecture | arm64-v8a only |
| Minimum Android | Android 7.0 / API 24 |
| Target SDK | API 36 |
| APK versionName / versionCode | `1.6.0` / `2011` |
| Signing | Template debug/development key |
| Physical-phone acceptance of this exact artifact | NOT RECORDED |
| iOS | Frozen; not distributed |

The APK versionCode includes the ARM64 split offset; the source build number
in pubspec.yaml is `11`. Renaming the file did not change its package or signature.

- [Published release](https://github.com/Viktor-Yrl/F_7_Volna/releases/tag/v1.6.0)
- [Download ARM64 APK](https://github.com/Viktor-Yrl/F_7_Volna/releases/download/v1.6.0/Volna-1.6.0-android-arm64.apk)

SHA-256:

```text
f8bf0c2ccb303f794cfae40959fb9943d21489975f8a0b4c48a68e561e7bfea3
```

The local APK hash equals the asset digest reported by GitHub.
This is an artifact identity check, not proof of fresh-download installation
or full physical-device acceptance.

## Source and Documentation State

The application source matches the release-tag commit. The current stage
documentation and README maintenance are subsequent local edits, not content
already present in that immutable tag. The project owner will commit and push
these changes; this update does not stage files, commit, push, move tags or publish
another binary. Keep published source history and future documentation updates distinct.

Local artifact path relative to the repository root:

```text
F_5_Implementation/volna/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Build Procedure

From the repository root:

```powershell
cd F_5_Implementation/volna
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release --target-platform android-arm64 --split-per-abi
Get-FileHash build/app/outputs/flutter-apk/app-arm64-v8a-release.apk -Algorithm SHA256
```

Recorded toolchain: Flutter 3.38.9 / Dart 3.10.8.
A new build requires new verification: do not assume it has the same size/hash.
For a subsequent binary release, increment the version/build number and record
a new tag and artifact rather than silently replacing this published APK.

## Included Scope

Four tabs: Top 100, folder-style Playlists, Radio and Settings.
Local playback includes queue selection, play/pause, stop, seek, previous/next,
shuffle and repeat. Background media controls, persistent checkpoints,
English/Russian language and Dark/Mist Blue appearance are implemented.
The fixed radio catalog has 12 entries and bundled images, English entries first.

Downloads, favorites, manual playlists, single-file imports, custom station
editing, a device-wide scan, equalizer and cloud sync are not included.

## Limitations

- Capital, Heart and LBC returned HTTP 401 in the recorded QA environment.
- Retro FM, Radio Shanson and Humor FM encountered TLS failures in that network.
- WBUR network reception passed; audible phone playback was not certified.
- Current radio availability remains broadcaster/network dependent.
- The preview is development-signed, not production-signed.
- A signing-key change may require uninstalling the preview and losing local data.
- Physical-device acceptance and third-party asset/publication review remain open.
- Google Play readiness is not established.

See [radio sources](../F_5_Implementation/volna/RADIO_SOURCES.md),
[test results](../F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md),
[known issues](../F_6_Testing_and_Quality_Assurance/D_3_Known_Issues.md) and
[release checklist](D_1_Release_Checklist.md).
