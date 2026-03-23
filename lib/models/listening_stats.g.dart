// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
part of 'listening_stats.dart';

class ListeningStatsAdapter extends TypeAdapter<ListeningStats> {
  @override
  final int typeId = 2;

  @override
  ListeningStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListeningStats()
      ..songId = fields[0] as String
      ..totalMs = fields[1] as int
      ..completePlays = fields[2] as int
      ..skips = fields[3] as int
      ..playDates = (fields[4] as List).cast<DateTime>()
      ..playsByDay = (fields[5] as Map).cast<String, int>();
  }

  @override
  void write(BinaryWriter writer, ListeningStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.songId)
      ..writeByte(1)..write(obj.totalMs)
      ..writeByte(2)..write(obj.completePlays)
      ..writeByte(3)..write(obj.skips)
      ..writeByte(4)..write(obj.playDates)
      ..writeByte(5)..write(obj.playsByDay);
  }

  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ListeningStatsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
