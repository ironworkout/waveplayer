import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

class SmartShuffle extends ChangeNotifier {
  final Random _rng = Random();
  final List<String> _recentIds = [];
  static const int _antiRepeat = 5;
  bool enabled = true;

  Song? pickNext(List<Song> pool) {
    if (pool.isEmpty) return null;
    if (!enabled) return pool[_rng.nextInt(pool.length)];

    final candidates = pool.where((s) => !_recentIds.contains(s.id)).toList();
    final active = candidates.isNotEmpty ? candidates : pool;

    final total = active.fold<double>(0, (s, x) => s + x.shuffleWeight);
    double roll = _rng.nextDouble() * total;
    for (final s in active) {
      roll -= s.shuffleWeight;
      if (roll <= 0) { _track(s.id); return s; }
    }
    _track(active.last.id);
    return active.last;
  }

  void _track(String id) {
    _recentIds.add(id);
    if (_recentIds.length > _antiRepeat) _recentIds.removeAt(0);
  }

  void onLike(Song s)     { s.isLiked = !s.isLiked; s.recalculateWeight(); notifyListeners(); }
  void onComplete(Song s) { s.playCount++;           s.recalculateWeight(); }
  void onSkip(Song s)     { s.skipCount++;           s.recalculateWeight(); }
}
