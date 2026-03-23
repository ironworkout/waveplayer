import 'package:hive/hive.dart';

part 'listening_stats.g.dart';

@HiveType(typeId: 2)
class ListeningStats extends HiveObject {
  @HiveField(0) late String songId;
  @HiveField(1) int totalMs = 0;
  @HiveField(2) int completePlays = 0;
  @HiveField(3) int skips = 0;
  @HiveField(4) List<DateTime> playDates = [];
  @HiveField(5) Map<String, int> playsByDay = {};

  void recordPlay(int listenedMs, int totalDurationMs) {
    totalMs += listenedMs;
    playDates.add(DateTime.now());
    if (listenedMs / totalDurationMs > 0.8) completePlays++;
    final key = DateTime.now().toIso8601String().substring(0, 10);
    playsByDay[key] = (playsByDay[key] ?? 0) + 1;
    if (isInBox) save();
  }

  String get totalTimeFormatted {
    final h = totalMs ~/ 3600000;
    final m = (totalMs ~/ 60000) % 60;
    return h > 0 ? '${h}h ${m}min' : '${m} min';
  }
}
