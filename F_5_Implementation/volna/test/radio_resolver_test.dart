import 'dart:io';
import 'dart:convert';
import 'package:music_player_full/data/radio_catalog.dart';
import 'package:music_player_full/l10n/ui_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/data/radio_resolver.dart';

void main() {
  // Opt in for release QA; normal tests never depend on public radio servers.
  if (const bool.fromEnvironment('CHECK_LIVE_RADIO')) {
    for (final station in RadioCatalog.stations) {
      test('live catalog: ${station.title}', () async {
        final uri = await RadioResolver().resolve(station.uri);
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 10);
        try {
          final request = await client.getUrl(uri);
          final response = await request.close().timeout(
            const Duration(seconds: 10),
          );
          expect(response.statusCode, HttpStatus.ok);
          final chunk = await response.first.timeout(
            const Duration(seconds: 10),
          );
          expect(chunk, isNotEmpty);
          final type = response.headers.contentType?.mimeType ?? '';
          expect(
            type.startsWith('audio/') ||
                utf8.decode(chunk, allowMalformed: true).startsWith('#EXTM3U'),
            isTrue,
            reason: 'Unexpected stream type: $type',
          );
        } finally {
          client.close(force: true);
        }
      });
    }
  }
  test(
    'direct audio, redirects, HLS, playlists, HTTP errors and unsupported websites',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final response = request.response;
        if (request.uri.path == '/redirect') {
          response.statusCode = HttpStatus.temporaryRedirect;
          response.headers.set(HttpHeaders.locationHeader, '/audio');
          await response.close();
          return;
        }
        if (request.uri.path == '/audio') {
          response.headers.contentType = ContentType('audio', 'mpeg');
          response.write('ID3');
        } else if (request.uri.path == '/hls') {
          response.headers.contentType = ContentType('audio', 'x-mpegurl');
          response.write('#EXTM3U\n#EXT-X-VERSION:3\nsegment.ts');
        } else if (request.uri.path == '/playlist') {
          response.headers.contentType = ContentType('audio', 'x-scpls');
          response.write('[playlist]\nFile1=/audio');
        } else if (request.uri.path == '/offline') {
          response.statusCode = HttpStatus.serviceUnavailable;
        } else {
          response.headers.contentType = ContentType.html;
          response.write(
            request.uri.path == '/site'
                ? '<audio><source src="/audio"></audio>'
                : '<html>Website only</html>',
          );
        }
        await response.close();
      });
      final base = 'http://127.0.0.1:${server.port}';
      try {
        expect((await RadioResolver().resolve('$base/audio')).path, '/audio');
        expect(
          (await RadioResolver().resolve('$base/redirect')).path,
          '/audio',
        );
        expect(
          (await RadioResolver().resolve('$base/playlist')).path,
          '/audio',
        );
        expect((await RadioResolver().resolve('$base/hls')).path, '/hls');
        await expectLater(
          RadioResolver().resolve('$base/site'),
          throwsA(
            isA<LocalizedException>().having(
              (e) => e.localized.id,
              'message',
              MessageId.radioWebsite,
            ),
          ),
        );
        await expectLater(
          RadioResolver().resolve('$base/offline'),
          throwsA(
            isA<LocalizedException>().having(
              (e) => e.localized.status,
              'HTTP status',
              503,
            ),
          ),
        );
      } finally {
        await server.close(force: true);
      }
    },
  );
}
