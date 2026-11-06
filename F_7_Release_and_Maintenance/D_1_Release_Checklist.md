# Volna Release Checklist

Updated: 2026-11-06. Published preview: `v1.6.0`, source `1.6.0+11`.
Checked items refer to verified evidence; unchecked items remain unconfirmed.
The project owner handles documentation commits and pushes.

## Recorded Application Checks

- [x] Audit rerun: 39 offline tests passed.
- [x] Audit rerun: Flutter analysis reported no issues.
- [x] ARM64 release build completed; its images/native ABI were checked.
- [x] AAPT confirms minimum API 24, target API 36, versionName 1.6.0 and versionCode 2011.
- [x] Earlier catalog check received WBUR audio through the application resolver.
- [ ] Download this exact public APK and record installation on a compatible phone.
- [ ] Record model, Android version, app version, APK hash and test date.
- [ ] Complete local playback, folders, background and system-control acceptance.
- [ ] Verify all stations on the intended device/network or record remaining failures.

Use [D_1_Test_Plan.md](../F_6_Testing_and_Quality_Assurance/D_1_Test_Plan.md) and
[D_2_Test_Results.md](../F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md).

## Published Preview

- [x] GitHub reports the release as published and marked pre-release, not draft.
- [x] Tag v1.6.0 resolves to `5e3ccb3d7d1c4b340c002049ec1987b7c7d08e83`.
- [x] Current application source matches that baseline.
- [x] Release asset is `Volna-1.6.0-android-arm64.apk`, 21,903,593 bytes.
- [x] GitHub asset SHA-256 matches the local build.
- [x] Published notes disclose stream limitations and development signing.
- [x] Tag, commit, links and checksum are recorded in [D_3_Release_Info.md](D_3_Release_Info.md).
- [ ] Complete a fresh-download installation check; listing/digest checks alone are insufficient.

## Current Documentation Update

- [x] Align requirements, version scope, UI, technical decisions, QA and release notes.
- [x] Distinguish tested evidence, network observations and pending phone acceptance.
- [ ] Owner reviews and commits the current documentation/images/deletions.
- [ ] Owner pushes the documentation commit to GitHub.
- [ ] Owner verifies current branch documentation renders correctly after the push.

These pending documentation actions do not mean the existing application
release is unpublished. Do not move the already published tag to include later docs.

## Before Stable or Store Distribution

- [ ] Configure a private production signing identity and secure backup.
- [ ] Keep keys/passwords outside public source control.
- [ ] Plan update compatibility if replacing the preview signing key.
- [ ] Complete physical-device acceptance and relevant store/privacy requirements.
- [ ] Review third-party logo/stream publication terms.
- [ ] Resolve or accurately disclose remaining user-facing limitations.

## Future Release Procedure

1. Choose a new version/build number for changed binaries.
2. Run relevant analysis, tests and device checks; record artifact SHA-256.
3. Owner commits and pushes the source intended for that binary.
4. Create a new tag at the correct source commit; leave old published tags unchanged.
5. Upload the matching APK to Releases and disclose architecture/signing/limitations.
6. Verify publication, downloaded artifact identity and installation.
7. Record the release in [D_2_Changelog.md](D_2_Changelog.md) and D_3_Release_Info.md.

For maintenance, retain a known-good release and matching source. Report defects
with version/device details and repeat affected checks after fixes.
