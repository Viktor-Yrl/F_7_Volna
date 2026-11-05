import '../l10n/ui_message.dart';

/// Persisted document-tree access; this is not a raw filesystem path.
class MusicFolder {
  const MusicFolder({required this.uri, required this.name});
  final String uri, name;
  Map<String, dynamic> toJson() => {'uri': uri, 'name': name};
  factory MusicFolder.fromJson(Map<String, dynamic> json) =>
      MusicFolder(uri: json['uri'] as String, name: json['name'] as String);
}

/// Immutable media identity shared by the library, queue and playback history.
class Track {
  const Track({
    required this.id,
    required this.uri,
    required this.title,
    this.artist = 'Unknown artist',
    this.album = '',
    this.durationMs = 0,
    this.isRadio = false,
  });
  final String id, uri, title, artist, album;
  final int durationMs;
  final bool isRadio;
  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as String,
    uri: json['uri'] as String,
    title: json['title'] as String,
    artist: json['artist'] as String? ?? 'Unknown artist',
    album: json['album'] as String? ?? '',
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  );
}

Uri parseAudioUrl(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    throw const LocalizedException(UiMessage(MessageId.invalidAudioUrl));
  }
  return uri;
}

String formatTime(Duration value) {
  final seconds = value.inSeconds < 0 ? 0 : value.inSeconds;
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return seconds >= 3600
      ? '${seconds ~/ 3600}:${((seconds ~/ 60) % 60).toString().padLeft(2, '0')}:$rest'
      : '${seconds ~/ 60}:$rest';
}
