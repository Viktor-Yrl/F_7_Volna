import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../app_controller.dart';
import '../data/models.dart';
import '../ui/track_tile.dart';
import '../ui/track_artwork.dart';
import '../l10n/strings.dart';

/// Full player view; transport actions delegate to the playback controller.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.app});
  final AppController app;
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double? _drag;
  String? _trackId;
  void _queue() {
    final player = widget.app.playback;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .7,
          child: ListenableBuilder(
            listenable: player,
            builder: (context, _) => Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    context.l10n.playbackQueue,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: player.queue.length,
                    itemBuilder: (context, i) => TrackTile(
                      track: player.queue[i],
                      app: widget.app,
                      onTap: () {
                        unawaited(player.selectQueueIndex(i));
                        Navigator.pop(context);
                      },
                      trailing: i == player.index
                          ? const Icon(Icons.equalizer_rounded)
                          : Text('${i + 1}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.app.playback, widget.app.library]),
    builder: (context, _) {
      final player = widget.app.playback;
      final track = player.current;
      if (_trackId != track?.id) {
        _trackId = track?.id;
        _drag = null;
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.nowPlaying),
          actions: [
            IconButton(
              tooltip: context.l10n.queue,
              onPressed: track == null ? null : _queue,
              icon: const Icon(Icons.queue_music),
            ),
            IconButton(
              tooltip: context.l10n.stop,
              onPressed: track == null
                  ? null
                  : () => unawaited(player.stop(clearQueue: true)),
              icon: const Icon(Icons.stop_circle_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 48 || constraints.maxHeight <= 0) {
                // Android may report a zero-sized viewport during the first frame.
                return const SizedBox.shrink();
              }
              final wide = constraints.maxWidth > 760;
              final side = wide
                  ? 350.0
                  : math.min(
                      constraints.maxWidth - 48,
                      math.max(180.0, constraints.maxHeight * .43),
                    );
              final cover = SizedBox(
                width: side,
                height: side,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TrackArtwork(track: track),
                      if (player.busy || player.buffering)
                        const ColoredBox(
                          color: Color(0x66000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              );
              final controls = _controls(track);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 940),
                    child: wide
                        ? Row(
                            children: [
                              cover,
                              SizedBox(width: 48),
                              Expanded(child: controls),
                            ],
                          )
                        : Column(
                            children: [cover, SizedBox(height: 28), controls],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  Widget _controls(Track? track) {
    final app = widget.app;
    final player = app.playback;
    final total = player.duration.inMilliseconds.toDouble();
    final value = _drag ?? player.position.inMilliseconds.toDouble();
    final repeatIcon = player.repeat == LoopMode.one
        ? Icons.repeat_one_rounded
        : Icons.repeat_rounded;
    final repeatLabel = switch (player.repeat) {
      LoopMode.off => context.l10n.repeatOff,
      LoopMode.all => context.l10n.repeatAll,
      LoopMode.one => context.l10n.repeatOne,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          track?.titleLabel(context) ?? context.l10n.noTrackSelected,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 27,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8),
        Text(
          track?.artistLabel(context) ?? '',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFB6BDBE)),
        ),
        if (track?.isRadio == true)
          Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              context.l10n.live,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB5EE52)),
            ),
          )
        else ...[
          SizedBox(height: 20),
          Slider(
            value: value.clamp(0, total > 0 ? total : 1),
            max: total > 0 ? total : 1,
            label: formatTime(Duration(milliseconds: value.toInt())),
            onChanged: player.canSeek
                ? (value) => setState(() => _drag = value)
                : null,
            onChangeEnd: player.canSeek
                ? (value) async {
                    await player.seek(Duration(milliseconds: value.toInt()));
                    if (mounted) setState(() => _drag = null);
                  }
                : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatTime(Duration(milliseconds: value.toInt()))),
              Text(formatTime(player.duration)),
            ],
          ),
        ],
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: context.l10n.previousTrack,
              onPressed: player.hasPrevious
                  ? () => unawaited(player.previous())
                  : null,
              icon: const Icon(Icons.skip_previous_rounded, size: 34),
            ),
            SizedBox(width: 16),
            IconButton.filled(
              tooltip: player.playing
                  ? context.l10n.pause
                  : player.completed
                  ? context.l10n.replay
                  : context.l10n.play,
              onPressed: track != null && !player.busy
                  ? () => unawaited(player.toggle())
                  : null,
              style: IconButton.styleFrom(fixedSize: const Size(84, 84)),
              icon: Icon(
                player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 44,
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              tooltip: context.l10n.nextTrack,
              onPressed: player.hasNext ? () => unawaited(player.next()) : null,
              icon: const Icon(Icons.skip_next_rounded, size: 34),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: context.l10n.shuffle,
              isSelected: player.shuffle,
              onPressed: track != null && !track.isRadio && !player.busy
                  ? () => unawaited(player.setShuffle(!player.shuffle))
                  : null,
              icon: const Icon(Icons.shuffle_rounded),
            ),
            IconButton(
              tooltip: repeatLabel,
              isSelected: player.repeat != LoopMode.off,
              onPressed: track != null && !track.isRadio && !player.busy
                  ? () => unawaited(
                      player.setRepeat(switch (player.repeat) {
                        LoopMode.off => LoopMode.all,
                        LoopMode.all => LoopMode.one,
                        LoopMode.one => LoopMode.off,
                      }),
                    )
                  : null,
              icon: Icon(repeatIcon),
            ),
            IconButton(
              tooltip: context.l10n.favorite,
              isSelected: track != null && app.library.isFavorite(track.id),
              onPressed: track != null && !track.isRadio
                  ? () => unawaited(app.library.toggleFavorite(track.id))
                  : null,
              icon: const Icon(Icons.favorite_border_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
            ),
          ],
        ),
        if (player.error != null) ...[
          SizedBox(height: 12),
          ErrorBanner(message: player.error!, onDismiss: player.clearError),
        ],
      ],
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.app});
  final AppController app;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app.playback,
    builder: (context, _) {
      final player = app.playback;
      final track = player.current;
      if (track == null) return const SizedBox.shrink();
      return Material(
        color: const Color(0xFF303638),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 16, right: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: TrackArtwork(track: track, cacheWidth: 192),
                ),
              ),
              title: Text(
                track.titleLabel(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track.isRadio
                    ? context.l10n.liveRadio
                    : track.artistLabel(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => PlayerScreen(app: app)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: context.l10n.previousTrack,
                    onPressed: player.hasPrevious
                        ? () => unawaited(player.previous())
                        : null,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  IconButton(
                    tooltip: player.playing
                        ? context.l10n.pause
                        : context.l10n.play,
                    onPressed: player.busy
                        ? null
                        : () => unawaited(player.toggle()),
                    icon: player.busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            player.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                  ),
                  IconButton(
                    tooltip: context.l10n.nextTrack,
                    onPressed: player.hasNext
                        ? () => unawaited(player.next())
                        : null,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
            ),
            if (!track.isRadio)
              LinearProgressIndicator(
                minHeight: 2,
                value: player.duration.inMilliseconds > 0
                    ? (player.position.inMilliseconds /
                              player.duration.inMilliseconds)
                          .clamp(0, 1)
                    : 0,
              ),
          ],
        ),
      );
    },
  );
}
