import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/radio_catalog.dart';
import '../l10n/strings.dart';

/// Shared artwork keeps the list, mini player and full player consistent.
class TrackArtwork extends StatelessWidget {
  const TrackArtwork({super.key, required this.track, this.cacheWidth});
  final Track? track;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final asset = RadioCatalog.logos[track?.id];
    if (track?.isRadio == true) {
      // Contain preserves complete brand marks instead of cropping their text.
      return ColoredBox(
        color: Colors.white,
        child: asset == null
            ? Center(child: Icon(Icons.radio_rounded, color: Color(0xFF34403B)))
            : Image.asset(
                asset,
                fit: BoxFit.contain,
                cacheWidth: cacheWidth,
                semanticLabel: context.l10n.logoLabel(
                  track!.titleLabel(context),
                ),
                errorBuilder: (_, error, stack) => Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF34403B),
                  ),
                ),
              ),
      );
    }
    return Image.asset(
      'assets/images/cover.png',
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      semanticLabel: context.l10n.mountainLake,
    );
  }
}
