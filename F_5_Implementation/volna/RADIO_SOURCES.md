# Built-in Radio Catalog

Catalog: `lib/data/radio_catalog.dart`. Expanded 2026-11-06 to 12 stations.
English-language stations precede Russian-language stations. The original five
entries below retain their 2026-11-01 verification results, not a new playback claim.

| Station | Public stream | Verification |
| --- | --- | --- |
| Marusya FM | https://cdn.radio-holding.ru/marusya_default | Official marus.fm player endpoint, redirects to audio/mpeg |
| Europa Plus (Russia) | https://ep256.hostingradio.ru:8052/europaplus256.mp3 | HTTP 200 audio/mpeg, Icecast identifies Europa Plus; Android playback verified |
| BBC World Service | https://a.files.bbci.co.uk/ms6/live/3441A116-B12E-4D2F-ACA8-C1984642FA4B/audio/simulcast/hls/nonuk/pc_hd_abr_v2/aks/bbc_world_service.m3u8 | HTTPS HLS returned by the public BBC media selector; live child playlist and Android playback verified |
| Comedy UK | https://stream.rcs.revma.com/cp7w38a8hxnwv | Source from official comedyuk.online/listen1 player; redirects to audio/mpeg; Android playback verified |
| 181.FM Comedy Club | https://listen.181fm.com/181-comedy_128k.mp3 | Published by 181.fm/links; audio/mpeg with Comedy Club metadata; Android playback verified |
| Capital | https://media-ssl.musicradio.com/CapitalUK | Published in the official Global Player page's free playback configuration; HTTP 401 in this environment on 2026-11-06, no audio received |
| Heart | https://media-ssl.musicradio.com/HeartUK | Published in the official Global Player page's free playback configuration; HTTP 401 in this environment on 2026-11-06, no audio received |
| LBC | https://media-ssl.musicradio.com/LBCUK | Published in the official Global Player page's playback configuration; HTTP 401 in this environment on 2026-11-06, no audio received |
| WBUR | https://fm909.wbur.org/wbur_www | Current WBUR website player constant; HTTPS 200 audio/mpeg, WBUR-FM metadata and MP3 bytes received on 2026-11-06; physical-device playback not tested |
| Retro FM (Russia) | https://retro.hostingradio.ru:8043/retro256.mp3 | Publicly listed MP3 endpoint; TLS connection failed in this environment on 2026-11-06; live audio unverified |
| Radio Shanson (Russia) | https://chanson.hostingradio.ru:8041/chanson256.mp3 | Publicly listed MP3 endpoint; TLS connection failed in this environment on 2026-11-06; live audio unverified |
| Humor FM (Russia) | https://pub0201.101.ru:8443/stream/air/aac/64/102 | Public 101.ru channel 102 endpoint; TLS connection failed in this environment on 2026-11-06; live audio unverified |

Official player metadata: https://www.globalplayer.com/live/capital/uk/,
https://www.globalplayer.com/live/heart/uk/, https://www.globalplayer.com/live/lbc/uk/,
and https://www.wbur.org/ways-to-listen. WBUR's current website JavaScript defines
`https://fm909.wbur.org/wbur_www` as its live stream. An older StreamGuys host failed
certificate validation and is deliberately not used.

Russian station sites: https://retrofm.ru/, https://radioshanson.ru/,
https://www.veseloeradio.ru/, https://101.ru/radio/channel/102.
The Retro FM and Shanson mounts also appear in public station directories;
they could not be confirmed against live origin metadata from this network.
Shanson is the Russian broadcaster, not the separate Zaycev.FM chanson channel.

Do not treat catalog inclusion or a passing offline test as proof of live access.
The three new Russian streams still need phone/network testing. Capital, Heart
and LBC are present as requested but may remain unavailable: HTTP 401 is an
upstream access refusal, not a successful audio response. No login, token,
geographic restriction or TLS validation is bypassed by the app.

## Bundled Logo Sources

Images were downloaded unchanged. The original five and new UK/US images come
from broadcaster sites/CDNs; the three new Russian images use the public brand
image mirrors explicitly listed below because direct origin requests failed.
They remain third-party brand assets, not newly created Volna artwork.

| Local asset | Source |
| --- | --- |
| assets/radio/marusya.png | https://marus.fm/img/logo460.png |
| assets/radio/europa_plus.png | https://europaplus.ru/tg.png |
| assets/radio/bbc_world_service.png | https://ichef.bbci.co.uk/images/ic/raw/p0kps3vt.png (World Service image on the official BBC audio page) |
| assets/radio/comedy_uk.png | https://mmo.aiircdn.com/2747/69d8b8d62ae7a.png (official Comedy UK player) |
| assets/radio/181_comedy_large.jpg | https://www.181.fm/images/og181fmlogo.jpg |
| assets/radio/capital.png | https://herald.musicradio.com/media/0d3d891d-32f2-4c53-95ee-8d1e35bdd126.png (official Global Player metadata) |
| assets/radio/heart.png | https://herald.musicradio.com/media/49b9e8cb-15bf-4bf2-8c28-a4850cc6b0f3.png (official Global Player metadata) |
| assets/radio/lbc.png | https://herald.musicradio.com/media/5a8b3e18-6682-4024-a0f3-d94fcffe1abe.png (official Global Player metadata) |
| assets/radio/wbur.jpg | https://media.wbur.org/wp/2016/06/WBUR-News-Tile-400x400.jpg (official WBUR News artwork) |
| assets/radio/retro_fm.png | https://images.seeklogo.com/logo-png/48/1/retro-fm-russia-logo-png_seeklogo-486855.png (Seeklogo brand mirror) |
| assets/radio/shanson.jpg | https://static-media.streema.com/media/cache/78/6a/786ab432e712247d77d15fbcbe808781.jpg (Streema station directory) |
| assets/radio/humor_fm.jpg | https://media.radiodeck.com/stations/5f74fcf0664ee84008423fcf/profile/600db79c75d61f06fafac93c/xl.jpg (Radiodeck station directory) |

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
