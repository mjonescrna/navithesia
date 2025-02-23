// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseEntryAdapter extends TypeAdapter<CaseEntry> {
  @override
  final int typeId = 1;

  @override
  CaseEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      procedureName: fields[2] as String,
      notes: fields[3] as String,
      patientAge: fields[4] as int,
      asaStatus: fields[5] as String,
      anatomicalCategories: (fields[6] as List).cast<String>(),
      anesthesiaTypes: (fields[7] as List).cast<String>(),
      monitoringTypes: (fields[8] as List).cast<String>(),
      specialTechniques: (fields[9] as List).cast<String>(),
      isEmergency: fields[10] as bool,
      clinicalHours: fields[11] as double,
      selectedCategories: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CaseEntry obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.procedureName)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.patientAge)
      ..writeByte(5)
      ..write(obj.asaStatus)
      ..writeByte(6)
      ..write(obj.anatomicalCategories)
      ..writeByte(7)
      ..write(obj.anesthesiaTypes)
      ..writeByte(8)
      ..write(obj.monitoringTypes)
      ..writeByte(9)
      ..write(obj.specialTechniques)
      ..writeByte(10)
      ..write(obj.isEmergency)
      ..writeByte(11)
      ..write(obj.clinicalHours)
      ..writeByte(12)
      ..write(obj.selectedCategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
