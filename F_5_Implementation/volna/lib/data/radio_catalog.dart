import 'models.dart';

/// Bundled stations use stable IDs so saved playback state survives updates.
class RadioCatalog {
  // Local brand assets keep the station list usable without image downloads.
  static const logos = <String, String>{
    'radio:marusya': 'assets/radio/marusya.png',
    'radio:europa-plus': 'assets/radio/europa_plus.png',
    'radio:bbc-world-service': 'assets/radio/bbc_world_service.png',
    'radio:comedy-uk': 'assets/radio/comedy_uk.png',
    'radio:181-comedy-club': 'assets/radio/181_comedy_large.jpg',
    'radio:capital': 'assets/radio/capital.png',
    'radio:heart': 'assets/radio/heart.png',
    'radio:lbc': 'assets/radio/lbc.png',
    'radio:wbur': 'assets/radio/wbur.jpg',
    'radio:retro-fm': 'assets/radio/retro_fm.png',
    'radio:shanson': 'assets/radio/shanson.jpg',
    'radio:humor-fm': 'assets/radio/humor_fm.jpg',
  };

  static const stations = <Track>[
    // English-language stations precede Russian-language stations.
    Track(
      id: 'radio:bbc-world-service',
      uri:
          'https://a.files.bbci.co.uk/ms6/live/3441A116-B12E-4D2F-ACA8-C1984642FA4B/audio/simulcast/hls/nonuk/pc_hd_abr_v2/aks/bbc_world_service.m3u8',
      title: 'BBC World Service',
      artist: 'UK · International news',
      isRadio: true,
    ),
    Track(
      id: 'radio:comedy-uk',
      uri: 'https://stream.rcs.revma.com/cp7w38a8hxnwv',
      title: 'Comedy UK',
      artist: 'UK · British stand-up',
      isRadio: true,
    ),
    Track(
      id: 'radio:181-comedy-club',
      uri: 'https://listen.181fm.com/181-comedy_128k.mp3',
      title: '181.FM Comedy Club',
      artist: 'USA · Talk comedy',
      isRadio: true,
    ),
    Track(
      id: 'radio:capital',
      uri: 'https://media-ssl.musicradio.com/CapitalUK',
      title: 'Capital',
      artist: 'UK · Current pop hits',
      isRadio: true,
    ),
    Track(
      id: 'radio:heart',
      uri: 'https://media-ssl.musicradio.com/HeartUK',
      title: 'Heart',
      artist: 'UK · Popular hits',
      isRadio: true,
    ),
    Track(
      id: 'radio:lbc',
      uri: 'https://media-ssl.musicradio.com/LBCUK',
      title: 'LBC',
      artist: 'UK · News and talk',
      isRadio: true,
    ),
    Track(
      id: 'radio:wbur',
      uri: 'https://fm909.wbur.org/wbur_www',
      title: 'WBUR',
      artist: 'USA · News and NPR programs',
      isRadio: true,
    ),
    // Russian-language stations follow the English-language catalog.
    Track(
      id: 'radio:marusya',
      uri: 'https://cdn.radio-holding.ru/marusya_default',
      title: 'Marusya FM',
      artist: 'Russia · Russian hits',
      isRadio: true,
    ),
    Track(
      id: 'radio:europa-plus',
      uri: 'https://ep256.hostingradio.ru:8052/europaplus256.mp3',
      title: 'Europa Plus',
      artist: 'Russia · Pop music',
      isRadio: true,
    ),
    Track(
      id: 'radio:retro-fm',
      uri: 'https://retro.hostingradio.ru:8043/retro256.mp3',
      title: 'Retro FM',
      artist: 'Russia · Classic hits',
      isRadio: true,
    ),
    Track(
      id: 'radio:shanson',
      uri: 'https://chanson.hostingradio.ru:8041/chanson256.mp3',
      title: 'Radio Shanson',
      artist: 'Russia · Russian chanson',
      isRadio: true,
    ),
    Track(
      id: 'radio:humor-fm',
      uri: 'https://pub0201.101.ru:8443/stream/air/aac/64/102',
      title: 'Humor FM',
      artist: 'Russia · Comedy and music',
      isRadio: true,
    ),
  ];
}
