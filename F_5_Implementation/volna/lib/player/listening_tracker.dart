import '../data/models.dart';

/// Counts playback progress rather than button presses or seek jumps.
class ListeningTracker {
  ListeningTracker(this.onQualified);
  final void Function(Track) onQualified;
  String? _id;
  Duration? _previous;
  bool _active = false, _counted = false;
  int _listenedMs = 0;

  void reset() {
    _id = null;
    _previous = null;
    _active = false;
    _counted = false;
    _listenedMs = 0;
  }

  void sample(
    Track? track,
    Duration position,
    Duration duration, {
    required bool active,
  }) {
    if (track == null || track.isRadio) {
      reset();
      return;
    }
    if (_id != track.id) {
      reset();
      _id = track.id;
    }
    final previous = _previous;
    if (previous != null &&
        position < previous &&
        duration > Duration.zero &&
        previous >= duration - const Duration(seconds: 2) &&
        position < const Duration(seconds: 2)) {
      _counted = false;
      _listenedMs = 0;
    }
    final delta = previous == null ? 0 : (position - previous).inMilliseconds;
    if (_active && active && delta > 0 && delta <= 2000) _listenedMs += delta;
    _previous = position;
    _active = active;
    // Short tracks qualify halfway through; longer tracks require 30 seconds.
    final threshold = duration > Duration.zero
        ? (duration.inMilliseconds ~/ 2).clamp(1000, 30000)
        : 30000;
    if (!_counted && _listenedMs >= threshold) {
      _counted = true;
      onQualified(track);
    }
  }
}
