# Volna Current Interface Specification

Updated: 2026-11-06. Baseline: `1.6.0+11`, Android preview `v1.6.0`.
This document describes the current application, not the earlier single-file mockup.

## Navigation

The initial tab is Top 100. Bottom navigation contains Top 100, Playlists, Radio
and Settings. Folder contents and the full player open as separate routes.
Back returns to the previous route. Changing tabs does not recreate the audio engine.

## Top 100

- Show up to 100 accessible local tracks, sorted by listening count, then title.
- Display a shared cover, filename-based title, artist placeholder and play count.
- Highlight the selected track using the active theme's accent.
- Selecting a row starts the ranked list as a queue at that track.
- With no qualified history, show an icon and a no-history message.
- No favorites, download or manual playlist controls are present.

## Playlists

- Each selected folder is a yellow folder row with its name and recursive track count.
- The plus action opens Android's folder picker directly.
- Refresh rescans selected folders. Add/refresh actions are disabled while busy.
- A folder menu removes the selection, never the original audio files.
- If no folders are selected, offer an Add folder button.
- Opening a folder navigates to its current track list.

### Folder Track List

Show the folder name, total count, track rows and a play action in the app bar.
The app-bar action starts from the first track and is disabled for an empty list.
Selecting a row starts that folder's queue at the selected song.
Show an empty message if no tracks are available. Display scan progress and
dismissible library/playback errors when applicable. Keep the mini player below
the list when a current item exists.

## Radio

- Display the fixed 12-entry catalog, English-language stations before Russian ones.
- Each row contains the station's bundled brand image, name and country/genre label.
- Images use containment rather than cropping the logo.
- Selecting a station loads it as a one-item queue.
- No add/edit/delete station controls exist.
- Stream failure produces a dismissible error; a visible selected row/logo alone
  does not certify that audio is playing.

## Settings

Appearance provides Dark and Light - Mist Blue choices.
Language provides English and Russian choices; English is the default.
Changes persist and apply without restarting or intentionally interrupting audio.
While saving, show progress and disable preference changes. A failed save shows
an error and retains the previous selection. Android permission dialogs use
the phone's system language, not the application's selected language.

## Full Player

- Show cover/logo, title and artist or station description.
- For local music, show position, duration and a seek slider.
- For radio, show LIVE rather than a seek slider.
- Provide previous, play/pause/replay and next controls.
- For local queues, provide shuffle and repeat off/all/one.
- Previous/next depend on queue availability; radio disables previous, seeking,
  shuffle and repeat. A single-station queue has no next item.
- Provide app-bar actions to view the queue and stop playback.
- Queue selection starts playback from the selected item.
- Show a loading/buffering overlay and playback errors when present.
- Adapt to available space, with scrolling and a side-by-side layout on wide screens.

## Mini Player

Show only when a current track/station exists. Display artwork, title and
artist/live-radio subtitle, plus previous/play-pause/next controls.
Tapping the text/artwork area opens the full player.
Local music has a thin progress indicator; radio does not.
During source loading, show progress and prevent conflicting row selections.

## Empty, Loading and Error States

| State | Behavior |
| --- | --- |
| No listening history | Top 100 placeholder |
| No selected folders | Add folder action |
| Empty folder | No available tracks message |
| No current track | Mini player hidden; full-player playback controls unavailable |
| Folder scan | Linear progress; folder management actions blocked while busy |
| Source loading/buffering | Player progress indication |
| Lost access / unavailable source | Dismissible localized error |
| Preference save failure | Error; prior preference retained |

## Appearance and Content

Dark uses charcoal surfaces and a lime accent. Mist Blue uses tinted light
surfaces rather than a pure white page. Local tracks use the shared mountain
cover; embedded ID3 artwork/artist metadata is not extracted.
User folder/file names are not translated.

## Screenshot Index

The following existing images illustrate the current dark English UI.
They are visual references, not an acceptance record tied to a verified APK hash.

| Asset | Screen |
| --- | --- |
| [1.jpg](1.jpg) | Radio list with BBC selected and mini player |
| [2.jpg](2.jpg) | Full radio player displaying LBC branding |
| [3.jpg](3.jpg) | Folder-style Playlists and local mini player |
| [4.jpg](4.jpg) | Full local-track player |
| [5.jpg](5.jpg) | Populated personal Top 100 |
| [6.jpg](6.jpg) | Settings with appearance and language choices |

No Mist Blue reference screenshot is currently included in this folder.
The LBC screenshot's pause/LIVE state does not establish current stream availability.
For tested behavior and open limitations, use
[D_2_Test_Results.md](../F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md) and
[D_3_Known_Issues.md](../F_6_Testing_and_Quality_Assurance/D_3_Known_Issues.md).
