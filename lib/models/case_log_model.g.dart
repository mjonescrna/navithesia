// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseLogAdapter extends TypeAdapter<CaseLog> {
  @override
  final int typeId = 0;

  @override
  CaseLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseLog(
      category: fields[0] as String,
      count: fields[1] as int,
      timestamp: fields[2] as DateTime,
      physicalStatus: fields[3] as String,
      patientAge: fields[4] as int,
      anestheticMethod: fields[5] as String,
      anatomicalCategory: fields[6] as String,
      notes: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CaseLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.count)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.physicalStatus)
      ..writeByte(4)
      ..write(obj.patientAge)
      ..writeByte(5)
      ..write(obj.anestheticMethod)
      ..writeByte(6)
      ..write(obj.anatomicalCategory)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
