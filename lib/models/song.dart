import 'package:hive/hive.dart';

part 'song.g.dart';

enum SongSource { local, stream }

@HiveType(typeId: 0)
class Song extends HiveObject {
  Song(); 

  @HiveField(0) late String id;
  @HiveField(1) late String title;
  @HiveField(2) late String artist;
  @HiveField(3) late String album;
  @HiveField(4) late String filePath;
  @HiveField(5) late int durationMs;
  @HiveField(6) bool isLiked = false;
  @HiveField(7) int playCount = 0;
  @HiveField(8) int skipCount = 0;
  @HiveField(9) double shuffleWeight = 1.0;
  @HiveField(10) DateTime? lastPlayed;
  @HiveField(11) String? thumbnailUrl;
  @HiveField(12) String sourceStr = 'local';

  SongSource get source =>
      sourceStr == 'stream' ? SongSource.stream : SongSource.local;

  bool get isStream => source == SongSource.stream;

  void recalculateWeight() {
    shuffleWeight = 1.0
        + (isLiked ? 0.5 : 0.0)
        + (playCount * 0.1)
        - (skipCount * 0.2);
    shuffleWeight = shuffleWeight.clamp(0.1, 5.0);
    if (isInBox) save();
  }

  String get durationFormatted {
    final d = Duration(milliseconds: durationMs);
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory Song.fromStream({
    required String id,
    required String title,
    required String artist,
    required String videoId,
    required int durationMs,
    String? thumbnailUrl,
  }) {
    final s = Song()
      ..id = id
      ..title = title
      ..artist = artist
      ..album = ''
      ..filePath = videoId
      ..durationMs = durationMs
      ..thumbnailUrl = thumbnailUrl
      ..sourceStr = 'stream';
    return s;
  }

  factory Song.fromLocal({
    required String id,
    required String title,
    required String artist,
    required String album,
    required String filePath,
    required int durationMs,
  }) {
    final s = Song()
      ..id = id
      ..title = title
      ..artist = artist
      ..album = album
      ..filePath = filePath
      ..durationMs = durationMs
      ..sourceStr = 'local';
    return s;
  }
}
