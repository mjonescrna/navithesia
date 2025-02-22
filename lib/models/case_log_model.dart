import 'package:hive/hive.dart';

part 'case_log_model.g.dart';

@HiveType(typeId: 0)
class CaseLog extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  int count;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String physicalStatus; // e.g., Class I, II, III-VI

  @HiveField(4)
  int patientAge;

  @HiveField(5)
  String anestheticMethod;

  @HiveField(6)
  String anatomicalCategory;

  @HiveField(7)
  String notes;

  CaseLog({
    required this.category,
    this.count = 0,
    required this.timestamp,
    this.physicalStatus = '',
    this.patientAge = 0,
    this.anestheticMethod = '',
    this.anatomicalCategory = '',
    this.notes = '',
  });
}
