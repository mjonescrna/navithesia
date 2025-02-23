import 'package:hive_flutter/hive_flutter.dart';
import '../models/time_log_entry.dart';

class TimeLogRepository {
  static const String _boxName = 'time_logs';
  late Box<TimeLogEntry> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<TimeLogEntry>(_boxName);
  }

  Future<void> addTimeLog(TimeLogEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> updateTimeLog(TimeLogEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> deleteTimeLog(String id) async {
    await _box.delete(id);
  }

  TimeLogEntry? getTimeLog(String id) {
    return _box.get(id);
  }

  List<TimeLogEntry> getAllTimeLogs() {
    return _box.values.toList();
  }

  List<TimeLogEntry> getTimeLogsForDate(DateTime date) {
    return _box.values.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  int calculateTotalMinutes(String clockIn, String clockOut) {
    final inParts = clockIn.split(':');
    final outParts = clockOut.split(':');

    final inTime = DateTime(
      2024,
      1,
      1,
      int.parse(inParts[0]),
      int.parse(inParts[1]),
    );

    final outTime = DateTime(
      2024,
      1,
      1,
      int.parse(outParts[0]),
      int.parse(outParts[1]),
    );

    return outTime.difference(inTime).inMinutes;
  }

  String formatMinutesToHours(int minutes) {
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}';
  }
}
