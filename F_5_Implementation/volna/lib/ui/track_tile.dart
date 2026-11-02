import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/models.dart';
import 'track_artwork.dart';
import '../l10n/strings.dart';
import '../l10n/ui_message.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.app,
    required this.onTap,
    this.trailing,
  });
  final Track track;
  final AppController app;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app.playback,
    builder: (context, _) {
      final active = app.playback.current?.id == track.id;
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        leading: SizedBox(
          width: 46,
          height: 46,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TrackArtwork(track: track, cacheWidth: 192),
          ),
        ),
        title: Text(
          track.titleLabel(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Theme.of(context).colorScheme.primary : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          track.artistLabel(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            trailing ??
            (track.durationMs > 0
                ? Text(formatTime(Duration(milliseconds: track.durationMs)))
                : null),
        onTap: app.playback.busy ? null : onTap,
      );
    },
  );
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });
  final UiMessage message;
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(message.localize(context.l10n)),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.closeMessage,
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    ),
  );
}
