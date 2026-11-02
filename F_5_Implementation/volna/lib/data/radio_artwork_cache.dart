import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'radio_catalog.dart';

/// The native media notification needs a file URI rather than a Flutter asset.
class RadioArtworkCache {
  RadioArtworkCache({Future<Directory>? directory, AssetBundle? bundle})
    : _directory = directory,
      _bundle = bundle ?? rootBundle;
  final Future<Directory>? _directory;
  final AssetBundle _bundle;
  final Map<String, Future<Uri?>> _pending = {};

  Future<Uri?> uriFor(Track track) {
    final asset = RadioCatalog.logos[track.id];
    if (asset == null) return Future.value(null);
    return _pending.putIfAbsent(asset, () => _copy(asset));
  }

  Future<Uri?> _copy(String asset) async {
    try {
      final root = await (_directory ?? getApplicationSupportDirectory());
      final directory = Directory(p.join(root.path, 'radio_artwork'));
      await directory.create(recursive: true);
      final data = await _bundle.load(asset);
      final file = File(p.join(directory.path, p.basename(asset)));
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      return file.uri;
    } catch (_) {
      // Artwork failures must never prevent an otherwise valid audio stream.
      return null;
    }
  }
}
