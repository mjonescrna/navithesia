import 'package:hive/hive.dart';

part 'time_log_entry.g.dart';

@HiveType(typeId: 0)
class TimeLogEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  @HiveField(4)
  DateTime? firstClockIn;

  @HiveField(5)
  DateTime? firstClockOut;

  @HiveField(6)
  DateTime? secondClockIn;

  @HiveField(7)
  DateTime? secondClockOut;

  @HiveField(8)
  int totalShiftMinutes;

  @HiveField(9)
  int anesthesiaMinutes;

  @HiveField(10)
  int conferenceMinutes;

  @HiveField(11)
  int dnpProjectMinutes;

  @HiveField(12)
  int presentationMinutes;

  @HiveField(13)
  bool isBoardPrepDay;

  @HiveField(14)
  bool isCallExperience;

  @HiveField(15)
  String description;

  @HiveField(16)
  String notes;

  TimeLogEntry({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.firstClockIn,
    this.firstClockOut,
    this.secondClockIn,
    this.secondClockOut,
    required this.totalShiftMinutes,
    required this.anesthesiaMinutes,
    required this.conferenceMinutes,
    required this.dnpProjectMinutes,
    required this.presentationMinutes,
    required this.isBoardPrepDay,
    required this.isCallExperience,
    required this.description,
    required this.notes,
  });

  factory TimeLogEntry.fromFields(List<dynamic> fields) {
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
}
