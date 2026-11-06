# Changelog

Updated: 2026-11-06. This log distinguishes published application changes from
later local documentation work. Older internal snapshots are retained in
[QA.md](../F_5_Implementation/volna/QA.md), not presented as separately verified releases.

## Unreleased

### Documentation

- Replaced Word/TXT stage documents with English Markdown.
- Aligned requirements and minimum-version scope with the current Android application.
- Expanded the current interface specification and indexed the six screenshots.
- Updated technical decisions, test evidence and known limitations.
- Recorded the published tag, source commit, APK checksum and download links.
- Corrected obsolete references to a separate MVP directory.

These are local documentation changes awaiting the owner's commit and push.
They do not introduce a new application version or claim another binary release.

## [1.6.0](https://github.com/Viktor-Yrl/F_7_Volna/releases/tag/v1.6.0) - 2026-11-06

Published as **Volna v1.6.0 - Android Preview**, marked pre-release.
Source version: `1.6.0+11`; tag commit:
`5e3ccb3d7d1c4b340c002049ec1987b7c7d08e83`.

This is the confirmed public preview baseline. The feature summary below
covers the result of earlier development, not a claim that every feature
was first implemented on the publication date.

### Included

- Android-selected music folders with persistent access, recursive discovery,
  folder-style Playlists, counts, refresh and removal.
- Personal Top 100 using qualified listening rather than button presses.
- Local queue controls, play/pause, stop, seeking, previous/next, shuffle and repeat.
- Full player, mini player, background service and system media controls.
- English/Russian preferences and Dark/Mist Blue themes with persistence.
- Saved queue/position without startup autoplay.
- Twelve bundled radio entries and images; English-language entries first.
- Capital, Heart, LBC, WBUR, Retro FM, Radio Shanson and Humor FM extend the
  earlier five-entry development catalog.

### Reliability Improvements Included

- Playback position updates separated from unrelated list rebuilds.
- A newly selected folder's initial scan reused.
- Stale async transport work prevented from disabling a replacement queue's controls.
- Saved queue restoration deferred during temporary folder-access failure.
- Unneeded folder grants cleaned up while retaining queued-source access.
- Fixed-catalog stream handling simplified without arbitrary HTML scraping.

### Removed from Earlier Development Scope

- Download feature and favorites.
- Manual playlist creation/editing and single-file import/copy/hash workflow.
- Legacy collection loading, custom station editing and device-wide scan options.

### Verification and Limitations

- Latest audit: 39 offline tests passed and clean Flutter analysis.
- ARM64 release build verified; published/local APK digests match.
- WBUR reception passed an earlier network smoke test.
- Global station HTTP 401 and new Russian stream TLS failures remain recorded limitations.
- Current-build phone acceptance and production signing remain open.

See [D_3_Release_Info.md](D_3_Release_Info.md) for the artifact and
[D_3_Known_Issues.md](../F_6_Testing_and_Quality_Assurance/D_3_Known_Issues.md) for limitations.
