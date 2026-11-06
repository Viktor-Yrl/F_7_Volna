# Volna Test Results

Updated: 2026-11-06. Baseline: `1.6.0+11`, public pre-release `v1.6.0`.

## Baseline and Environment

| Field | Verified or recorded value |
| --- | --- |
| Application source commit | `5e3ccb3d7d1c4b340c002049ec1987b7c7d08e83` |
| Latest documentation audit | 2026-11-06; tests and analysis rerun |
| Host/toolchain | Windows; Flutter 3.38.9 / Dart 3.10.8 |
| Widget viewports | 320x640, 412x915, 1024x768 logical pixels |
| Public APK | `Volna-1.6.0-android-arm64.apk` |
| Local APK | `app-arm64-v8a-release.apk` |
| APK size/ABI | 21,903,593 bytes / arm64-v8a only |
| APK platform metadata | Minimum API 24; target API 36; versionName 1.6.0; versionCode 2011 |
| Physical phone/Android version for acceptance | NOT RECORDED |

APK SHA-256:
`f8bf0c2ccb303f794cfae40959fb9943d21489975f8a0b4c48a68e561e7bfea3`.

## Documentation Audit Results

| Check | Status | Evidence / boundary |
| --- | --- | --- |
| Offline suite rerun | PASS | 39 tests, using flutter test --no-pub |
| Static analysis rerun | PASS | No issues, using flutter analyze --no-pub |
| Radio catalog and artwork | PASS | Tests cover 12 entries, IDs/order, image decoding and containment |
| Radio scrolling and labels | PASS | Widget checks at three viewport sizes; English/Russian labels |
| Source vs release tag | PASS | GitHub tag v1.6.0 points to the application baseline commit |
| Published release/asset | PASS | GitHub API reports published pre-release and ARM64 asset |
| Local vs published APK identity | PASS | Local SHA-256 equals the asset digest reported by GitHub |
| APK metadata | PASS | AAPT confirms package/version, API 24 minimum and ARM64 |
| Local documentation links | PASS | Rechecked after the documentation update; no missing targets |

The application source has no local differences from the baseline commit.
Documentation edits are separate and await the owner's commit/push.
Publication and checksum checks do not establish that a fresh download has
been installed and acceptance-tested on a phone.

## Earlier Build and Network Evidence

These checks were recorded during the 2026-11-06 catalog update.
They were not rerun as live playback tests in the later documentation audit.

| Check | Status | Recorded result |
| --- | --- | --- |
| ARM64 release build | PASS | Build succeeded; all 12 images and ARM64-only native libraries checked |
| WBUR network smoke test | PASS | HTTPS 200, audio/mpeg, MP3 bytes; application resolver check passed |
| Capital, Heart and LBC | BLOCKED | HTTP 401; no audio received from the checked environment |
| Retro FM, Radio Shanson and Humor FM | BLOCKED | TLS connection failures in the checked environment |

These observations are network-specific, not proof of current worldwide access.
See [RADIO_SOURCES.md](../F_5_Implementation/volna/RADIO_SOURCES.md).

## Latest Artifact Physical-Device Acceptance

| Scenario | Recorded status |
| --- | --- |
| Fresh download, installation and launch | NOT RECORDED |
| Folder picker, nested discovery and refresh | NOT RECORDED |
| Audible playback, seeking and queue controls | NOT RECORDED |
| Listening qualification and Top 100 | NOT RECORDED |
| Background/locked-screen playback and media controls | NOT RECORDED |
| Calls, headset, Bluetooth and competing audio | NOT RECORDED |
| Language/theme persistence and larger fonts | NOT RECORDED |
| All stations on the intended device/network | NOT RECORDED |
| Extended playback and battery behavior | NOT RECORDED |

Screenshots show real UI examples but are not a complete acceptance log tied
to this checksum. NOT RECORDED does not assert that a feature fails or that
the owner has never tried it.

## Future Results

| Date | Version / commit / APK hash | Phone / Android | Network | Scenario | Expected / actual | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Pending | Pending | Pending | Pending | Pending | Pending | NOT RECORDED |

Historical [QA.md](../F_5_Implementation/volna/QA.md) includes superseded
development snapshots. Do not combine old test totals or resurrect retired
features as current requirements. Use [D_1_Test_Plan.md](D_1_Test_Plan.md) for scope.
