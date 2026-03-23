import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String name;
  @HiveField(2) List<String> songIds = [];
  @HiveField(3) DateTime createdAt = DateTime.now();
  @HiveField(4) String? coverSongId;

  int get length => songIds.length;

  void addSong(String songId) {
    if (!songIds.contains(songId)) {
      songIds.add(songId);
      if (isInBox) save();
    }
  }

  void removeSong(String songId) {
    songIds.remove(songId);
    if (isInBox) save();
  }

  void reorder(int oldIndex, int newIndex) {
    final item = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, item);
    if (isInBox) save();
  }
}
