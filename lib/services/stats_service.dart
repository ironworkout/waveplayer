import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/song.dart';
import '../models/listening_stats.dart';

class StatsService extends ChangeNotifier {
  Future<void> recordPlay(Song song, Duration listened) async {
    final box = Hive.box<ListeningStats>('stats');
    var stats = box.get(song.id) ?? (ListeningStats()..songId = song.id);
    stats.recordPlay(listened.inMilliseconds, song.durationMs);
    await box.put(song.id, stats);
    notifyListeners();
  }

  Duration get totalListeningTime {
    final box = Hive.box<ListeningStats>('stats');
    final ms = box.values.fold<int>(0, (s, x) => s + x.totalMs);
    return Duration(milliseconds: ms);
  }

  List<Song> topSongs(List<Song> allSongs, {int limit = 10}) {
    final box = Hive.box<ListeningStats>('stats');
    final ranked = allSongs.map((s) {
      final st = box.get(s.id);
      return MapEntry(s, st?.completePlays ?? 0);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(limit).map((e) => e.key).toList();
  }

  Map<String, int> weekActivity() {
    final box = Hive.box<ListeningStats>('stats');
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = day.toIso8601String().substring(0, 10);
      result[key] = box.values.fold(0, (s, x) => s + (x.playsByDay[key] ?? 0));
    }
    return result;
  }
}
