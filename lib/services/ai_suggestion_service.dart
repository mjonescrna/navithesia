import 'package:hive/hive.dart';
import '../models/procedure_suggestion.dart';

class AISuggestionService {
  static const String _boxName = 'procedure_suggestions';
  late Box<ProcedureSuggestion> _suggestionsBox;

  Future<void> initialize() async {
    _suggestionsBox = await Hive.openBox<ProcedureSuggestion>(_boxName);
  }

  Future<List<ProcedureSuggestion>> getSuggestions(String query) async {
    if (query.length < 2) return [];

    // Search in local database first
    final localSuggestions =
        _suggestionsBox.values.where((suggestion) {
          return suggestion.procedureName.toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();

    if (localSuggestions.isNotEmpty) {
      return localSuggestions;
    }

    // If no local suggestions, use default mappings
    return _getDefaultSuggestions(query);
  }

  List<ProcedureSuggestion> _getDefaultSuggestions(String query) {
    // This would be replaced with your surgical procedure database
    final defaultProcedures = [
      ProcedureSuggestion(
        procedureName: 'Laparoscopic Cholecystectomy',
        estimatedDuration: 2.0,
        defaultAssessment: 'Routine laparoscopic procedure',
        coaCategories: ['Intra-abdominal', 'General Anesthesia'],
        commonTechniques: ['ETT', 'IV Induction'],
        anatomicalLocation: 'Abdomen',
      ),
      // Add more default procedures...
    ];

    return defaultProcedures.where((procedure) {
      return procedure.procedureName.toLowerCase().contains(
        query.toLowerCase(),
      );
    }).toList();
  }

  Future<void> learnFromEdit(
    ProcedureSuggestion original,
    Map<String, dynamic> edits,
  ) async {
    // Create updated suggestion
    final updatedSuggestion = ProcedureSuggestion(
      procedureName: edits['procedureName'] ?? original.procedureName,
      estimatedDuration:
          edits['estimatedDuration'] ?? original.estimatedDuration,
      defaultAssessment:
          edits['defaultAssessment'] ?? original.defaultAssessment,
      coaCategories: List<String>.from(
        edits['coaCategories'] ?? original.coaCategories,
      ),
      commonTechniques: List<String>.from(
        edits['commonTechniques'] ?? original.commonTechniques,
      ),
      anatomicalLocation:
          edits['anatomicalLocation'] ?? original.anatomicalLocation,
    );

    // Store in local database
    await _suggestionsBox.put(
      updatedSuggestion.procedureName,
      updatedSuggestion,
    );
  }

  Future<ProcedureSuggestion> analyzeText(String text) async {
    // TODO: Implement actual text analysis
    // This is a mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return ProcedureSuggestion(
      procedureName: text.split('\n').first,
      coaCategories: ['General Anesthesia'],
      estimatedDuration: 2.0,
      defaultAssessment: 'ASA II',
      commonTechniques: ['ETT', 'IV Induction'],
      anatomicalLocation: 'Abdomen',
      jaffeReference: 'Chapter 1: Basic Principles',
    );
  }
}
