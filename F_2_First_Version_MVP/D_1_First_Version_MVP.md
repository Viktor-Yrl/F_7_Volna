# Volna Minimum Version Scope

Updated: 2026-11-06. Current preview: `1.6.0+11`, public tag `v1.6.0`.

## Goal

Deliver a small usable Android player for selected local music folders,
background listening and a fixed radio catalog, without accounts or a backend.

This document defines the minimum scope of the current public preview.
It does not claim that a separate single-file MVP project still exists.
The application maintained in this repository is `F_5_Implementation/volna`.

## Included Scope

| Area | Included behavior |
| --- | --- |
| Top 100 | Personal ranking based on qualified local listening |
| Playlists | Selected Android folders, recursive discovery, counts, refresh and removal |
| Local playback | Queue, play/pause, stop, seek, previous/next, shuffle, repeat one/all |
| Background audio | Android media notification and lock-screen controls |
| Radio | Fixed 12-entry catalog with brand images and country/genre labels |
| Settings | English/Russian and Dark/Mist Blue with persistence |
| Restoration | Folders, statistics, settings, queue and position; no automatic playback |
| Feedback | Empty states, loading indicators and dismissible errors |

Target: Android 7.0 / API 24 or newer. The published APK is ARM64 only.
MP3 is the primary local format; decoder support determines other formats.

## Acceptance Baseline

- A user can select a folder, open its songs and control local playback.
- Refresh updates selected folders; removal never deletes original audio.
- Top 100 counts qualified listening, not radio or seek jumps.
- Background controls and restart restoration behave correctly on the target phone.
- Language and theme changes do not require leaving/restarting the app.
- Radio entries either produce playable audio or a visible failure state.
- The published APK must match its recorded checksum and source baseline.

These are acceptance criteria, not a claim that all manual device checks passed.
The latest audit confirmed 39 automated tests and clean analysis.
Physical-device results for this exact artifact are still not recorded.
Some radio streams remain blocked/unverified.

## Excluded Scope

No downloads, favorites, manual playlist editor, single-file import, custom radio
editing, device-wide scan, equalizer, account/cloud features or active iOS release.
These are exclusions, not unfinished requirements for this preview.

## Status and Next Gate

A GitHub pre-release and ARM64 APK are published. Production readiness still
requires device acceptance, stable release signing and publication/asset review.
Documentation commits and pushes are performed by the project owner.

See [requirements](../F_1_Tasks_and_Requirements/D_1_Tasks_and_Requirements.md),
[test results](../F_6_Testing_and_Quality_Assurance/D_2_Test_Results.md) and
[release information](../F_7_Release_and_Maintenance/D_3_Release_Info.md).
