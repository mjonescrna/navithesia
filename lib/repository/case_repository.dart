import 'package:hive_flutter/hive_flutter.dart';
import '../models/case_entry.dart';

class CaseRepository {
  static const String _boxName = 'cases';
  late Box<CaseEntry> _box;

  // Predefined lists for various categories
  static const List<String> anatomicalCategories = [
    'Head',
    'Neck',
    'Thorax',
    'Abdomen',
    'Upper Extremity',
    'Lower Extremity',
    'Perineum',
    'Spine',
    'Multiple Categories',
  ];

  static const List<String> anesthesiaTypes = [
    'General',
    'Regional',
    'MAC',
    'Epidural',
    'Spinal',
    'Combined Spinal-Epidural',
    'Peripheral Nerve Block',
  ];

  static const List<String> monitoringTypes = [
    'Standard ASA',
    'Arterial Line',
    'Central Line',
    'CVP',
    'TEE',
    'BIS',
    'Nerve Stimulator',
    'Temperature',
  ];

  static const List<String> specialTechniques = [
    'Ultrasound Guided',
    'Fiberoptic Intubation',
    'Rapid Sequence',
    'Arterial Line Placement',
    'Central Line Placement',
    'Double Lumen ETT',
  ];

  static const List<String> asaStatuses = [
    'ASA I',
    'ASA II',
    'ASA III',
    'ASA IV',
    'ASA V',
    'ASA VI',
    'E',
  ];

  Future<void> initialize() async {
    _box = await Hive.openBox<CaseEntry>(_boxName);
  }

  Future<void> addCase(CaseEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> updateCase(CaseEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> deleteCase(String id) async {
    await _box.delete(id);
  }

  CaseEntry? getCase(String id) {
    return _box.get(id);
  }

  List<CaseEntry> getAllCases() {
    return _box.values.toList();
  }

  List<CaseEntry> getCasesForDate(DateTime date) {
    return _box.values.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  Map<String, int> getCategoryCounts() {
    final Map<String, int> counts = {};

    for (var entry in _box.values) {
      for (var category in entry.selectedCategories) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }

    return counts;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  bool validateCase(CaseEntry entry) {
    if (entry.procedureName.isEmpty) return false;
    if (entry.patientAge < 0) return false;
    if (entry.asaStatus.isEmpty) return false;
    if (entry.anatomicalCategories.isEmpty) return false;
    if (entry.anesthesiaTypes.isEmpty) return false;
    if (entry.clinicalHours <= 0) return false;
    return true;
  }
}
