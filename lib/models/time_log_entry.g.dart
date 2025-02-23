// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeLogEntryAdapter extends TypeAdapter<TimeLogEntry> {
  @override
  final int typeId = 0;

  @override
  TimeLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeLogEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      firstClockIn: fields[4] as DateTime?,
      firstClockOut: fields[5] as DateTime?,
      secondClockIn: fields[6] as DateTime?,
      secondClockOut: fields[7] as DateTime?,
      totalShiftMinutes: fields[8] as int,
      anesthesiaMinutes: fields[9] as int,
      conferenceMinutes: fields[10] as int,
      dnpProjectMinutes: fields[11] as int,
      presentationMinutes: fields[12] as int,
      isBoardPrepDay: fields[13] as bool,
      isCallExperience: fields[14] as bool,
      description: fields[15] as String,
      notes: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimeLogEntry obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.firstClockIn)
      ..writeByte(5)
      ..write(obj.firstClockOut)
      ..writeByte(6)
      ..write(obj.secondClockIn)
      ..writeByte(7)
      ..write(obj.secondClockOut)
      ..writeByte(8)
      ..write(obj.totalShiftMinutes)
      ..writeByte(9)
      ..write(obj.anesthesiaMinutes)
      ..writeByte(10)
      ..write(obj.conferenceMinutes)
      ..writeByte(11)
      ..write(obj.dnpProjectMinutes)
      ..writeByte(12)
      ..write(obj.presentationMinutes)
      ..writeByte(13)
      ..write(obj.isBoardPrepDay)
      ..writeByte(14)
      ..write(obj.isCallExperience)
      ..writeByte(15)
      ..write(obj.description)
      ..writeByte(16)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
