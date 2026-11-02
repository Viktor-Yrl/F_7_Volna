import 'dart:io';
import 'package:music_player_full/l10n/ui_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/data/radio_resolver.dart';

void main() {
  test('Marus website maps to official public audio endpoint', () {
    expect(
      RadioResolver.normalize(Uri.parse('https://marus.fm/')).toString(),
      'https://cdn.radio-holding.ru/marusya_default',
    );
    expect(
      RadioResolver.normalize(Uri.parse('https://marus.fm/podcast')).path,
      '/podcast',
    );
  });
  test('direct audio, HTML audio source, HLS and invalid website', () async {
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
      expect((await RadioResolver().resolve('$base/redirect')).path, '/audio');
      expect((await RadioResolver().resolve('$base/site')).path, '/audio');
      expect((await RadioResolver().resolve('$base/hls')).path, '/hls');
      await expectLater(
        RadioResolver().resolve('$base/invalid'),
        throwsA(
          isA<LocalizedException>().having(
            (e) => e.localized.id,
            'message',
            MessageId.radioWebsite,
          ),
        ),
      );
    } finally {
      await server.close(force: true);
    }
  });
}
