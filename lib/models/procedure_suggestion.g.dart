// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procedure_suggestion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProcedureSuggestionAdapter extends TypeAdapter<ProcedureSuggestion> {
  @override
  final int typeId = 2;

  @override
  ProcedureSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcedureSuggestion(
      procedureName: fields[0] as String,
      category: fields[1] as String,
      techniques: (fields[2] as List).cast<String>(),
      complications: (fields[3] as List).cast<String>(),
      confidence: fields[4] as double,
      estimatedDuration: fields[5] as double,
      defaultAssessment: fields[6] as String,
      coaCategories: (fields[7] as List).cast<String>(),
      commonTechniques: (fields[8] as List).cast<String>(),
      anatomicalLocation: fields[9] as String,
      jaffeReference: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProcedureSuggestion obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.procedureName)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.techniques)
      ..writeByte(3)
      ..write(obj.complications)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.estimatedDuration)
      ..writeByte(6)
      ..write(obj.defaultAssessment)
      ..writeByte(7)
      ..write(obj.coaCategories)
      ..writeByte(8)
      ..write(obj.commonTechniques)
      ..writeByte(9)
      ..write(obj.anatomicalLocation)
      ..writeByte(10)
      ..write(obj.jaffeReference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcedureSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
