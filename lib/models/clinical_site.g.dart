// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_site.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClinicalSiteAdapter extends TypeAdapter<ClinicalSite> {
  @override
  final int typeId = 3;

  @override
  ClinicalSite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClinicalSite(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      phoneNumber: fields[5] as String,
      website: fields[6] as String,
      specialties: (fields[7] as List).cast<String>(),
      caseVolumes: (fields[8] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ClinicalSite obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.website)
      ..writeByte(7)
      ..write(obj.specialties)
      ..writeByte(8)
      ..write(obj.caseVolumes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicalSiteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
