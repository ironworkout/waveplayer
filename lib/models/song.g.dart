// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
part of 'song.dart';

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..artist = fields[2] as String
      ..album = fields[3] as String
      ..filePath = fields[4] as String
      ..durationMs = fields[5] as int
      ..isLiked = fields[6] as bool
      ..playCount = fields[7] as int
      ..skipCount = fields[8] as int
      ..shuffleWeight = fields[9] as double
      ..lastPlayed = fields[10] as DateTime?
      ..thumbnailUrl = fields[11] as String?
      ..sourceStr = fields[12] as String;
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.artist)
      ..writeByte(3)..write(obj.album)
      ..writeByte(4)..write(obj.filePath)
      ..writeByte(5)..write(obj.durationMs)
      ..writeByte(6)..write(obj.isLiked)
      ..writeByte(7)..write(obj.playCount)
      ..writeByte(8)..write(obj.skipCount)
      ..writeByte(9)..write(obj.shuffleWeight)
      ..writeByte(10)..write(obj.lastPlayed)
      ..writeByte(11)..write(obj.thumbnailUrl)
      ..writeByte(12)..write(obj.sourceStr);
  }

  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SongAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
