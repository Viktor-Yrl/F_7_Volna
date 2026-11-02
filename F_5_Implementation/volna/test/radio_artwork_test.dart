import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player_full/data/models.dart';
import 'package:music_player_full/data/radio_artwork_cache.dart';
import 'package:music_player_full/data/radio_catalog.dart';
import 'package:music_player_full/ui/track_artwork.dart';

class FailingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw StateError('Missing artwork');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'every bundled station logo decodes and renders without cropping',
    (tester) async {
      expect(RadioCatalog.stations, hasLength(5));
      for (final station in RadioCatalog.stations) {
        final path = RadioCatalog.logos[station.id];
        expect(path, isNotNull);
        await tester.runAsync(() async {
          final data = await rootBundle.load(path!);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, greaterThan(0));
          frame.image.dispose();
          codec.dispose();
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: TrackArtwork(track: station),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'notification artwork is copied locally and cached without network',
    (tester) async {
      await tester.runAsync(() async {
        final root = await Directory.systemTemp.createTemp('volna_art_');
        try {
          final cache = RadioArtworkCache(directory: Future.value(root));
          final station = RadioCatalog.stations.last;
          final uri = await cache.uriFor(station);
          expect(uri!.scheme, 'file');
          expect(await File.fromUri(uri).length(), greaterThan(0));
          expect(await cache.uriFor(station), uri);
          expect(
            await cache.uriFor(
              const Track(
                id: 'local',
                uri: 'file:///music.mp3',
                title: 'Local',
              ),
            ),
            isNull,
          );
          final broken = RadioArtworkCache(
            directory: Future.value(root),
            bundle: FailingBundle(),
          );
          expect(await broken.uriFor(station), isNull);
        } finally {
          await root.delete(recursive: true);
        }
      });
    },
  );
}
