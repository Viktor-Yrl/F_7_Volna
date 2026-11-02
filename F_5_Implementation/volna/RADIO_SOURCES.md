# Built-in Radio Catalog

Checked 2026-11-01. Catalog: `lib/data/radio_catalog.dart`.

| Station | Public stream | Verification |
| --- | --- | --- |
| Marusya FM | https://cdn.radio-holding.ru/marusya_default | Official marus.fm player endpoint, redirects to audio/mpeg |
| Europa Plus (Russia) | https://ep256.hostingradio.ru:8052/europaplus256.mp3 | HTTP 200 audio/mpeg, Icecast identifies Europa Plus; Android playback verified |
| BBC World Service | https://a.files.bbci.co.uk/ms6/live/3441A116-B12E-4D2F-ACA8-C1984642FA4B/audio/simulcast/hls/nonuk/pc_hd_abr_v2/aks/bbc_world_service.m3u8 | HTTPS HLS returned by the public BBC media selector; live child playlist and Android playback verified |
| Comedy UK | https://stream.rcs.revma.com/cp7w38a8hxnwv | Source from official comedyuk.online/listen1 player; redirects to audio/mpeg; Android playback verified |
| 181.FM Comedy Club | https://listen.181fm.com/181-comedy_128k.mp3 | Published by 181.fm/links; audio/mpeg with Comedy Club metadata; Android playback verified |

## Bundled Logo Sources

Images were downloaded unchanged from the broadcasters' official sites/CDNs.
They remain third-party brand assets, not newly created Volna artwork.

| Local asset | Source |
| --- | --- |
| assets/radio/marusya.png | https://marus.fm/img/logo460.png |
| assets/radio/europa_plus.png | https://europaplus.ru/tg.png |
| assets/radio/bbc_world_service.png | https://ichef.bbci.co.uk/images/ic/raw/p0kps3vt.png (World Service image on the official BBC audio page) |
| assets/radio/comedy_uk.png | https://mmo.aiircdn.com/2747/69d8b8d62ae7a.png (official Comedy UK player) |
| assets/radio/181_comedy_large.jpg | https://www.181.fm/images/og181fmlogo.jpg |

The 181.FM channel uses its broadcaster's official network logo. Brand/image
usage terms must be reviewed before public/commercial store distribution;
these downloads do not assert ownership or a blanket redistribution license.

Official sites: https://marus.fm/, https://europaplus.ru/,
https://www.bbc.com/audio/stations.
BBC media metadata source:
https://open.live.bbc.co.uk/mediaselector/6/select/version/2.0/mediaset/pc/vpid/bbc_world_service/format/json.

The old BBC pool_904 playlist and stream.live.vc.bbcmedia.co.uk mount were not
working in this check and are not used. Do not replace current endpoints with
old copied links without testing live media, not just the master playlist.

The application does not host, record or redistribute station media. There is
no affiliation with these broadcasters. Availability, geographic restrictions
and endpoint changes are controlled by the broadcasters. No authentication,
certificate validation or access restrictions are bypassed.

The catalog is bundled with the application; changing a station endpoint
currently requires an application update. Station inclusion/publication terms
have not been certified for commercial store distribution.
