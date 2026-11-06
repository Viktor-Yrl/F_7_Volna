# Volna Known Issues

Updated: 2026-11-06. Baseline: Android preview `1.6.0+11`, tag `v1.6.0`.
Publication is confirmed; production readiness is not.

## R-01: Global Station Access Refusal

- Stations: Capital, Heart and LBC.
- Severity: Major for those entries; not a local-music failure.
- Status: Open, observed in the 2026-11-06 QA network; not retested during the later documentation audit.
- Reproduction: resolve configured station URLs from the checked environment.
  On a phone, select the station and record whether the refusal reproduces.
- Expected: playable audio data.
- Observed: HTTP 401 and no audio. The precise reason is not established.
- Impact: catalog presence and a logo must not be advertised as verified live access.
- Next action: confirm permitted integration/current endpoints and test on the
  intended device/network. Do not bypass authentication or access restrictions.

## R-02: New Russian Streams Unverified

- Stations: Retro FM, Radio Shanson and Humor FM.
- Severity: Major if reproduced on a target device; presently a verification blocker.
- Status: Open network-origin blocker, not a confirmed application defect.
- Reproduction: request configured HTTPS streams from the checked network.
- Expected: audio response.
- Observed: TLS connection failures during the 2026-11-06 catalog checks.
- Impact: successful live reception is not established for these entries.
- Next action: confirm origin URLs and test on the intended phone/network,
  keeping certificate validation enabled.

## D-01: Development Signing

- Severity: Blocker for a production-signed stable release.
- Status: Open; the public pre-release still uses the template debug key.
- Verification: Android Gradle release signing configuration.
- Impact: the preview is not production-signed. A different signing key can
  require uninstalling it, which may remove its local settings/history.
- Next action: configure a private stable signing identity and secure backup
  before stable/store distribution; keep secrets outside the repository.

## Acceptance and Publication Gaps

- Fresh download and full physical-phone acceptance of the recorded APK are not documented.
- Lock-screen controls, calls, Bluetooth and long-run battery behavior need recorded checks.
- WBUR network data was received, but audible phone decoding is not certified.
- Third-party station-logo/stream publication terms require review.
- Google Play readiness is not established.
- Current Markdown documentation awaits the owner's commit and push. This does
  not invalidate the already published app binary.

## Intended Limitations

These are current scope choices, not defects:

- Android only; the published APK supports ARM64 with API 24 or newer.
- Shared local cover and filename-based track titles; no embedded metadata extraction.
- Broadcaster-controlled radio availability; catalog changes require an app update.
- No downloads, favorites, manual playlists, single-file imports, custom station
  editing, device-wide library scan, equalizer or cloud sync.
- iOS is frozen.

## Reporting

Record an ID, severity, version/commit, APK hash, device/Android version, network,
steps, expected/actual results, sanitized evidence, status and resolution.
Keep resolved/historical issues labeled. Do not infer audible playback from
a screenshot's LIVE or pause indicator alone.

See [D_2_Test_Results.md](D_2_Test_Results.md),
[D_3_Release_Info.md](../F_7_Release_and_Maintenance/D_3_Release_Info.md) and
[RADIO_SOURCES.md](../F_5_Implementation/volna/RADIO_SOURCES.md).
