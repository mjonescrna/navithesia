// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClinicalGoalAdapter extends TypeAdapter<ClinicalGoal> {
  @override
  final int typeId = 4;

  @override
  ClinicalGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClinicalGoal(
      id: fields[0] as String,
      category: fields[1] as String,
      targetCount: fields[2] as int,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      clinicalSiteId: fields[5] as String,
      collaborators: (fields[6] as List).cast<String>(),
      progressByUser: (fields[7] as Map).cast<String, int>(),
      notes: fields[9] as String,
    ).._isCompleted = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, ClinicalGoal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.targetCount)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.clinicalSiteId)
      ..writeByte(6)
      ..write(obj.collaborators)
      ..writeByte(7)
      ..write(obj.progressByUser)
      ..writeByte(8)
      ..write(obj._isCompleted)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicalGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
