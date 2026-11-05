import 'dart:convert';
import 'dart:io';
import 'models.dart';
import '../l10n/ui_message.dart';

/// Accepts stream and playlist endpoints from the bundled radio catalog.
class RadioResolver {
  Future<Uri> resolve(String input, {int depth = 0}) async {
    final uri = parseAudioUrl(input);
    if (depth > 2) {
      throw const LocalizedException(UiMessage(MessageId.radioRedirects));
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 12));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != 200) {
        throw LocalizedException(
          UiMessage(MessageId.radioHttp, status: response.statusCode),
        );
      }
      var base = uri;
      // Reuse the validated CDN endpoint rather than selecting another server.
      for (final redirect in response.redirects) {
        base = base.resolveUri(redirect.location);
      }
      parseAudioUrl(base.toString());
      final mime = response.headers.contentType?.mimeType.toLowerCase() ?? '';
      if (mime == 'text/html' || mime == 'application/xhtml+xml') {
        throw const LocalizedException(UiMessage(MessageId.radioWebsite));
      }
      if (mime != 'audio/x-mpegurl' &&
          mime != 'audio/mpegurl' &&
          mime != 'audio/x-scpls') {
        return base;
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 10))) {
        bytes.addAll(chunk);
        if (bytes.length > 512 * 1024) {
          throw const LocalizedException(
            UiMessage(MessageId.radioPageTooLarge),
          );
        }
      }
      final body = utf8.decode(bytes, allowMalformed: true);
      if (body.contains('#EXT-X-')) return base;
      String? candidate;
      for (final line in const LineSplitter().convert(body)) {
        final clean = line.trim();
        if (clean.startsWith('#') || clean.isEmpty) continue;
        if (clean.startsWith('http://') || clean.startsWith('https://')) {
          candidate = clean;
          break;
        }
        if (RegExp(r'^File\d+=', caseSensitive: false).hasMatch(clean)) {
          candidate = clean.substring(clean.indexOf('=') + 1);
          break;
        }
      }
      if (candidate == null || candidate.trim().isEmpty) {
        throw const LocalizedException(UiMessage(MessageId.radioWebsite));
      }
      final next = parseAudioUrl(base.resolve(candidate.trim()).toString());
      client.close(force: true);
      return resolve(next.toString(), depth: depth + 1);
    } finally {
      client.close(force: true);
    }
  }
}
