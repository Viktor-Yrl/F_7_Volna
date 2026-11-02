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
    this.origin = 'import',
    this.addedAt = 0,
  });
  final String id, uri, title, artist, album, origin;
  final int durationMs, addedAt;
  bool get isRadio => origin == 'radio';
  Map<String, dynamic> toJson() => {
    'id': id,
    'uri': uri,
    'title': title,
    'artist': artist,
    'album': album,
    'durationMs': durationMs,
    'origin': origin,
    'addedAt': addedAt,
  };
  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as String,
    uri: json['uri'] as String,
    title: json['title'] as String,
    artist: json['artist'] as String? ?? 'Unknown artist',
    album: json['album'] as String? ?? '',
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    origin: json['origin'] as String? ?? 'import',
    addedAt: (json['addedAt'] as num?)?.toInt() ?? 0,
  );
}

/// Read-only compatibility record for playlists saved by older releases.
class SavedPlaylist {
  SavedPlaylist({
    required this.id,
    required this.name,
    Iterable<String> trackIds = const [],
  }) : trackIds = List.unmodifiable(trackIds.toSet());
  final String id, name;
  final List<String> trackIds;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trackIds': trackIds,
  };
  factory SavedPlaylist.fromJson(Map<String, dynamic> json) => SavedPlaylist(
    id: json['id'] as String,
    name: json['name'] as String,
    trackIds: (json['trackIds'] as List? ?? []).cast<String>(),
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
