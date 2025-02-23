import 'package:hive/hive.dart';

part 'case_entry.g.dart';

@HiveType(typeId: 1)
class CaseEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String procedureName;

  @HiveField(3)
  String notes;

  @HiveField(4)
  int patientAge;

  @HiveField(5)
  String asaStatus;

  @HiveField(6)
  List<String> anatomicalCategories;

  @HiveField(7)
  List<String> anesthesiaTypes;

  @HiveField(8)
  List<String> monitoringTypes;

  @HiveField(9)
  List<String> specialTechniques;

  @HiveField(10)
  bool isEmergency;

  @HiveField(11)
  double clinicalHours;

  @HiveField(12)
  List<String> selectedCategories;

  CaseEntry({
    required this.id,
    required this.date,
    required this.procedureName,
    required this.notes,
    required this.patientAge,
    required this.asaStatus,
    required this.anatomicalCategories,
    required this.anesthesiaTypes,
    required this.monitoringTypes,
    required this.specialTechniques,
    required this.isEmergency,
    required this.clinicalHours,
    required this.selectedCategories,
  });

  factory CaseEntry.create({
    required String procedureName,
    required DateTime date,
    required String notes,
    required int patientAge,
    required String asaStatus,
    required List<String> anatomicalCategories,
    required List<String> anesthesiaTypes,
    required List<String> monitoringTypes,
    required List<String> specialTechniques,
    required bool isEmergency,
    required double clinicalHours,
    required List<String> selectedCategories,
  }) {
    return CaseEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      procedureName: procedureName,
      notes: notes,
      patientAge: patientAge,
      asaStatus: asaStatus,
      anatomicalCategories: anatomicalCategories,
      anesthesiaTypes: anesthesiaTypes,
      monitoringTypes: monitoringTypes,
      specialTechniques: specialTechniques,
      isEmergency: isEmergency,
      clinicalHours: clinicalHours,
      selectedCategories: selectedCategories,
    );
  }
}
