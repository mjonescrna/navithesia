import 'package:hive/hive.dart';

part 'clinical_goal.g.dart';

@HiveType(typeId: 4)
class ClinicalGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final int targetCount;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  @HiveField(5)
  final String clinicalSiteId;

  @HiveField(6)
  final List<String> collaborators;

  @HiveField(7)
  final Map<String, int> progressByUser;

  @HiveField(8)
  bool _isCompleted = false;

  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) {
    _isCompleted = value;
  }

  @HiveField(9)
  final String notes;

  ClinicalGoal({
    required this.id,
    required this.category,
    required this.targetCount,
    required this.startDate,
    required this.endDate,
    required this.clinicalSiteId,
    required this.collaborators,
    this.progressByUser = const {},
    this.isCompleted = false,
    this.notes = '',
  });

  factory ClinicalGoal.create({
    required String category,
    required int targetCount,
    required DateTime startDate,
    required DateTime endDate,
    required String clinicalSiteId,
    required List<String> collaborators,
  }) {
    return ClinicalGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      targetCount: targetCount,
      startDate: startDate,
      endDate: endDate,
      clinicalSiteId: clinicalSiteId,
      collaborators: collaborators,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'targetCount': targetCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'clinicalSiteId': clinicalSiteId,
      'collaborators': collaborators,
      'progressByUser': progressByUser,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory ClinicalGoal.fromJson(Map<String, dynamic> json) {
    return ClinicalGoal(
      id: json['id'] as String,
      category: json['category'] as String,
      targetCount: json['targetCount'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      clinicalSiteId: json['clinicalSiteId'] as String,
      collaborators: List<String>.from(json['collaborators']),
      progressByUser: Map<String, int>.from(json['progressByUser']),
      isCompleted: json['isCompleted'] as bool,
      notes: json['notes'] as String,
    );
  }

  double get progressPercentage {
    final total = progressByUser.values.fold(0, (sum, count) => sum + count);
    return total / targetCount;
  }

  void updateProgress(String userId, int count) {
    progressByUser[userId] = count;
    isCompleted = progressPercentage >= 1.0;
  }

  bool isCollaborator(String userId) {
    return collaborators.contains(userId);
  }

  Duration get remainingTime {
    return endDate.difference(DateTime.now());
  }

  bool get isOverdue {
    return daysRemaining < 0 && !isCompleted;
  }

  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }
}
