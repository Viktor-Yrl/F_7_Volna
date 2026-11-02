import 'dart:async';
import 'package:flutter/material.dart';
import '../app_controller.dart';
import '../data/models.dart';
import '../l10n/strings.dart';
import '../player/player_screen.dart';
import 'track_tile.dart';

/// Reads the current folder snapshot so refreshes never leave a stale queue.
class FolderTracksScreen extends StatelessWidget {
  const FolderTracksScreen({
    super.key,
    required this.app,
    required this.title,
    required this.tracks,
  });
  final AppController app;
  final String title;
  final List<Track> Function() tracks;

  Future<void> _play(List<Track> queue, int index) async {
    try {
      await app.library.media.requestNotifications();
    } catch (_) {}
    await app.playback.playTracks(queue, startIndex: index);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([app.library, app.playback]),
    builder: (context, _) {
      final queue = tracks();
      return Scaffold(
        appBar: AppBar(
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: context.l10n.play,
              onPressed: queue.isEmpty
                  ? null
                  : () => unawaited(_play(queue, 0)),
              icon: const Icon(Icons.play_arrow),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (app.library.error != null)
                ErrorBanner(
                  message: app.library.error!,
                  onDismiss: app.library.clearError,
                ),
              if (app.playback.error != null)
                ErrorBanner(
                  message: app.playback.error!,
                  onDismiss: app.playback.clearError,
                ),
              if (app.library.busy) const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(context.l10n.trackCount(queue.length)),
                ),
              ),
              Expanded(
                child: queue.isEmpty
                    ? Center(child: Text(context.l10n.noTracksAvailable))
                    : ListView.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, index) => TrackTile(
                          track: queue[index],
                          app: app,
                          onTap: () => unawaited(_play(queue, index)),
                          trailing: IconButton(
                            tooltip: context.l10n.favorite,
                            isSelected: app.library.isFavorite(queue[index].id),
                            icon: const Icon(Icons.favorite_border),
                            selectedIcon: const Icon(Icons.favorite),
                            onPressed: () => unawaited(
                              app.library.toggleFavorite(queue[index].id),
                            ),
                          ),
                        ),
                      ),
              ),
              MiniPlayer(app: app),
            ],
          ),
        ),
      );
    },
  );
}
