import 'dart:async';

import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/models.dart';
import '../player/player_screen.dart';
import 'track_tile.dart';
import 'folder_tracks_screen.dart';
import '../l10n/strings.dart';
import '../settings/settings_screen.dart';

/// Main navigation shell; feature controllers own data and audio operations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.app});
  final AppController app;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _tab = 0;
  AppController get app => widget.app;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(app.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Native audio continues playing when this screen is not visible.
    if (state == AppLifecycleState.paused) unawaited(app.savePlayback());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // The audio player belongs to the app/service, not this individual route.
    super.dispose();
  }

  Widget _topTracks() {
    final tracks = app.library.topTracks;
    if (tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noListeningHistory,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return TrackTile(
          track: track,
          app: app,
          onTap: () => unawaited(playFromList(context, app, tracks, index)),
          trailing: Builder(
            builder: (context) => Text(
              '${app.library.playCount(track.id)}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app.library,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(
          [
            context.l10n.top100,
            context.l10n.playlists,
            context.l10n.radio,
            context.l10n.settings,
          ][_tab],
        ),
        actions: [
          if (_tab == 1) ...[
            IconButton(
              tooltip: context.l10n.addFolder,
              onPressed: app.library.busy || !app.library.media.supported
                  ? null
                  : () => unawaited(app.library.addFolder()),
              icon: const Icon(Icons.add_rounded),
            ),
            if (app.library.media.supported)
              IconButton(
                tooltip: context.l10n.refreshLibrary,
                onPressed: app.library.busy
                    ? null
                    : () => unawaited(app.library.scan()),
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (app.library.busy) const LinearProgressIndicator(minHeight: 2),
            if (app.library.error != null)
              ErrorBanner(
                message: app.library.error!,
                onDismiss: app.library.clearError,
              ),
            ListenableBuilder(
              listenable: app.playback,
              builder: (context, _) => app.playback.error == null
                  ? const SizedBox.shrink()
                  : ErrorBanner(
                      message: app.playback.error!,
                      onDismiss: app.playback.clearError,
                    ),
            ),
            Expanded(
              child: switch (_tab) {
                0 => _topTracks(),
                1 => _playlists(),
                2 => _radio(),
                _ => SettingsScreen(settings: app.settings),
              },
            ),
            MiniPlayer(app: app),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: context.l10n.top100,
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_music),
            label: context.l10n.playlists,
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            selectedIcon: Icon(Icons.radio),
            label: context.l10n.radio,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: context.l10n.settings,
          ),
        ],
      ),
    ),
  );

  // Folder-style entries expose selected document trees without copying audio.
  Widget _playlists() => ListView(
    children: [
      for (final folder in app.library.folders) _folderTile(folder),
      if (app.library.folders.isEmpty && app.library.media.supported)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: app.library.busy
                    ? null
                    : () => unawaited(app.library.addFolder()),
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(context.l10n.addFolder),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _folderTile(MusicFolder folder) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    leading: const Icon(Icons.folder, color: Color(0xFFFFB900), size: 44),
    title: Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      context.l10n.trackCount(app.library.tracksForFolder(folder.uri).length),
    ),
    trailing: PopupMenuButton<String>(
      tooltip: context.l10n.musicFolders,
      onSelected: (_) => unawaited(app.library.removeFolder(folder.uri)),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'remove', child: Text(context.l10n.removeFolder)),
      ],
    ),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FolderTracksScreen(
          app: app,
          title: folder.name,
          tracks: () => app.library.tracksForFolder(folder.uri),
        ),
      ),
    ),
  );
  Widget _radio() => ListView.builder(
    itemCount: app.library.stations.length,
    itemBuilder: (context, i) {
      final station = app.library.stations[i];
      return TrackTile(
        track: station,
        app: app,
        onTap: () => unawaited(playFromList(context, app, [station], 0)),
      );
    },
  );
}
