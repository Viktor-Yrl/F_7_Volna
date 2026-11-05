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
  };

  static const stations = <Track>[
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
  ];
}
