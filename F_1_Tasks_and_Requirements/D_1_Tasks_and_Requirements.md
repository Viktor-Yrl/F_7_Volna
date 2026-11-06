# Volna Requirements

Updated: 2026-11-06. Baseline: Android preview `1.6.0+11`, tag `v1.6.0`.
This is the current product specification, aligned with the implemented app.
It replaces the earlier brief; retired features are not current requirements.

## Purpose and Audience

Provide straightforward background listening to a personal music collection
and a bundled radio catalog. Intended for personal use, a development portfolio
and public preview users.

## Platform and Delivery

- Android is the active platform. The published APK requires Android 7.0 / API 24
  or newer and an ARM64 device.
- iOS files are frozen; iOS is not a supported release target.
- No account, application backend or cloud synchronization is required.
- Offline listening is available for accessible local files; radio needs internet.

## Functional Requirements

| ID | Requirement |
| --- | --- |
| FR-01 | Open Top 100 first and provide four tabs: Top 100, Playlists, Radio and Settings. |
| FR-02 | Let users select folders through the Android system picker and retain read access. |
| FR-03 | Show selected folders as Playlists entries with track counts; include nested audio files. |
| FR-04 | Let users refresh selected folders and remove a selection without deleting original files. |
| FR-05 | Open a folder's track list; selecting a song starts that list as the playback queue. |
| FR-06 | Provide play/pause, stop, seeking for local tracks, previous/next and queue selection. |
| FR-07 | Support shuffle and repeat off, one track or the full queue for local music. |
| FR-08 | Support background playback and Android notification/lock-screen media controls. |
| FR-09 | Maintain a personal Top 100 from qualified local listening, not a global music chart. |
| FR-10 | Provide a read-only catalog of 12 stations with bundled brand images and country/genre labels. |
| FR-11 | Default to English and allow persistent English/Russian selection in Settings. |
| FR-12 | Provide persistent Dark and Mist Blue light themes, changing without an app restart. |
| FR-13 | Restore selected folders, statistics, settings, queue and position without autoplay. |
| FR-14 | Show useful loading, empty and error states; allow dismissing displayed errors. |

### Local Music and Access

MP3 is the primary target. Other audio formats depend on Android decoder support.
Files are read in place; no copy/import or device-wide library scan is required.
The folder picker grants access to selected locations; notification permission
is separate and its refusal must not prevent starting playback.
Folder track titles currently come from filenames. Embedded artist/album tags
and artwork are not extracted; local tracks use a shared cover.

### Listening Statistics

A play qualifies after 30 seconds of actual progress or half of a shorter track.
For known durations, the threshold has a one-second minimum; unknown durations
use 30 seconds. Radio, paused time and seeking alone are excluded.
Show at most 100 currently accessible local tracks with positive counts,
highest count first, then title for ties. Save counts between launches.

### Radio Catalog

English-language entries precede Russian-language entries:

1. BBC World Service
2. Comedy UK
3. 181.FM Comedy Club
4. Capital
5. Heart
6. LBC
7. WBUR
8. Marusya FM
9. Europa Plus
10. Retro FM
11. Radio Shanson
12. Humor FM

The catalog cannot be edited by users. Stream failure must be reported rather
than treated as successful playback. Radio seeking, shuffle and repeat are disabled.
Catalog inclusion is not a guarantee of live access; current failures and
verification limits are recorded in [D_3_Known_Issues.md](../F_6_Testing_and_Quality_Assurance/D_3_Known_Issues.md).

## Quality and Release Requirements

- Keep audio ownership independent of individual screens.
- Handle denied/revoked folder access and unavailable files without deleting music.
- Persist settings locally; do not translate personal folder or file names.
- Never bypass TLS validation or broadcaster authentication/access restrictions.
- Complete automated checks and disclose preview limitations before distribution.
- Complete physical-device acceptance and production signing before a stable/store release.

## Not Included

Downloads, favorites, manually created/edited playlists, individual file imports,
custom radio URLs, device-wide music scanning, an equalizer, cloud sync and iOS delivery.

## Related Documents

- [Version scope](../F_2_First_Version_MVP/D_1_First_Version_MVP.md)
- [Interface](../F_3_Interface_Design/D_1_Interface_Description.md)
- [Technical decisions](../F_4_Technical_Decisions/D_1_Technical_Decisions.md)
- [Acceptance plan](../F_6_Testing_and_Quality_Assurance/D_1_Test_Plan.md)
- [Published build information](../F_7_Release_and_Maintenance/D_3_Release_Info.md)
