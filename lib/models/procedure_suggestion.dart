import 'package:hive/hive.dart';

part 'procedure_suggestion.g.dart';

@HiveType(typeId: 2)
class ProcedureSuggestion extends HiveObject {
  @HiveField(0)
  final String procedureName;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final List<String> techniques;

  @HiveField(3)
  final List<String> complications;

  @HiveField(4)
  double confidence;

  @HiveField(5)
  final double estimatedDuration;

  @HiveField(6)
  final String defaultAssessment;

  @HiveField(7)
  final List<String> coaCategories;

  @HiveField(8)
  final List<String> commonTechniques;

  @HiveField(9)
  final String anatomicalLocation;

  @HiveField(10)
  final String jaffeReference;

  ProcedureSuggestion({
    required this.procedureName,
    required this.category,
    required this.techniques,
    required this.complications,
    required this.confidence,
    required this.estimatedDuration,
    required this.defaultAssessment,
    required this.coaCategories,
    required this.commonTechniques,
    required this.anatomicalLocation,
    this.jaffeReference = '',
  });

  factory ProcedureSuggestion.empty() {
    return ProcedureSuggestion(
      procedureName: '',
      category: '',
      techniques: [],
      complications: [],
      confidence: 0.0,
      estimatedDuration: 0.0,
      defaultAssessment: '',
      coaCategories: [],
      commonTechniques: [],
      anatomicalLocation: '',
      jaffeReference: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'procedureName': procedureName,
      'category': category,
      'techniques': techniques,
      'complications': complications,
      'confidence': confidence,
      'estimatedDuration': estimatedDuration,
      'defaultAssessment': defaultAssessment,
      'coaCategories': coaCategories,
      'commonTechniques': commonTechniques,
      'anatomicalLocation': anatomicalLocation,
      'jaffeReference': jaffeReference,
    };
  }

  factory ProcedureSuggestion.fromJson(Map<String, dynamic> json) {
    return ProcedureSuggestion(
      procedureName: json['procedureName'] as String,
      category: json['category'] as String,
      techniques: List<String>.from(json['techniques']),
      complications: List<String>.from(json['complications']),
      confidence: json['confidence'] as double,
      estimatedDuration: json['estimatedDuration'] as double,
      defaultAssessment: json['defaultAssessment'] as String,
      coaCategories: List<String>.from(json['coaCategories']),
      commonTechniques: List<String>.from(json['commonTechniques']),
      anatomicalLocation: json['anatomicalLocation'] as String,
      jaffeReference: json['jaffeReference'] as String? ?? '',
    );
  }
}
