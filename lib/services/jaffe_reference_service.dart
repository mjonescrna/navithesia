import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/procedure_suggestion.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaffeReferenceService {
  static final Logger _logger = Logger('JaffeReferenceService');
  static final JaffeReferenceService _instance =
      JaffeReferenceService._internal();
  factory JaffeReferenceService() => _instance;
  JaffeReferenceService._internal();

  List<ProcedureSuggestion> _procedures = [];
  bool _isInitialized = false;
  final Map<String, Map<String, dynamic>> _customizations = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonContent = await rootBundle.loadString(
        'assets/jaffe_procedures.json',
      );
      final List<dynamic> data = json.decode(jsonContent);

      _procedures =
          data.map((json) {
            return ProcedureSuggestion(
              procedureName: json['procedureName'] as String,
              category: json['jaffeReference'] as String? ?? 'Unknown',
              techniques: List<String>.from(json['commonTechniques'] ?? []),
              complications: List<String>.from(
                json['commonComplications'] ?? [],
              ),
              confidence: 1.0,
              estimatedDuration:
                  (json['estimatedDuration'] as num?)?.toDouble() ?? 0.0,
              defaultAssessment:
                  json['defaultAssessment'] as String? ?? 'ASA II',
              coaCategories: List<String>.from(json['coaCategories'] ?? []),
              commonTechniques: List<String>.from(
                json['commonTechniques'] ?? [],
              ),
              anatomicalLocation: json['anatomicalLocation'] as String? ?? '',
              jaffeReference: json['jaffeReference'] as String? ?? '',
            );
          }).toList();

      await _loadCustomizations();

      _isInitialized = true;
      _logger.info(
        'Loaded ${_procedures.length} procedures from Jaffe database',
      );
    } catch (e) {
      _logger.severe('Error loading Jaffe procedures: $e');
      _procedures = _getDefaultProcedures();
    }
  }

  List<ProcedureSuggestion> searchProcedures(String query) {
    if (query.isEmpty) return [];

    final List<String> searchTerms = query.toLowerCase().trim().split(
      RegExp(r'\s+'),
    );
    if (searchTerms.isEmpty ||
        (searchTerms.length == 1 && searchTerms[0].length < 2))
      return [];

    final Set<String> seenProcedures = {};
    final List<ProcedureSuggestion> results = [];
    final Map<String, double> relevanceScores = {};

    for (var procedure in _procedures) {
      if (seenProcedures.contains(procedure.procedureName)) continue;

      double relevance = _calculateRelevance(procedure, searchTerms);
      if (relevance > 0) {
        seenProcedures.add(procedure.procedureName);
        results.add(procedure);
        relevanceScores[procedure.procedureName] = relevance;
      }
    }

    // Sort by relevance score
    results.sort((a, b) {
      final scoreA = relevanceScores[a.procedureName] ?? 0;
      final scoreB = relevanceScores[b.procedureName] ?? 0;
      return scoreB.compareTo(scoreA);
    });

    return results;
  }

  double _calculateRelevance(
    ProcedureSuggestion procedure,
    List<String> searchTerms,
  ) {
    double score = 0;
    final procedureName = procedure.procedureName.toLowerCase();
    final anatomicalLocation = procedure.anatomicalLocation.toLowerCase();
    final category = procedure.category.toLowerCase();
    final techniques =
        procedure.commonTechniques.map((t) => t.toLowerCase()).toList();
    final categories =
        procedure.coaCategories.map((c) => c.toLowerCase()).toList();

    for (var term in searchTerms) {
      // Exact matches get highest score
      if (procedureName == term) score += 10;
      if (anatomicalLocation == term) score += 8;

      // Starts with term gets high score
      if (procedureName.startsWith(term)) score += 7;
      if (anatomicalLocation.startsWith(term)) score += 6;

      // Contains term gets medium score
      if (procedureName.contains(term)) score += 5;
      if (anatomicalLocation.contains(term)) score += 4;
      if (category.contains(term)) score += 3;

      // Technique and category matches get lower scores
      if (techniques.any((t) => t.contains(term))) score += 2;
      if (categories.any((c) => c.contains(term))) score += 2;
    }

    return score;
  }

  Future<void> _loadCustomizations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customizationsJson = prefs.getString(
        'procedure_customizations',
      );
      if (customizationsJson != null) {
        final Map<String, dynamic> data = json.decode(customizationsJson);
        _customizations.clear();
        data.forEach((key, value) {
          _customizations[key] = Map<String, dynamic>.from(value);
        });
      }
    } catch (e) {
      _logger.warning('Error loading customizations: $e');
    }
  }

  Future<void> saveCustomization(
    String procedureName,
    Map<String, dynamic> customization,
  ) async {
    try {
      _customizations[procedureName] = customization;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'procedure_customizations',
        json.encode(_customizations),
      );
    } catch (e) {
      _logger.warning('Error saving customization: $e');
    }
  }

  Map<String, dynamic>? getCustomization(String procedureName) {
    return _customizations[procedureName];
  }

  List<String> getCommonComplications(String procedureName) {
    final procedure = _procedures.firstWhere(
      (p) => p.procedureName.toLowerCase() == procedureName.toLowerCase(),
      orElse: () => ProcedureSuggestion.empty(),
    );
    return procedure.complications;
  }

  List<ProcedureSuggestion> _getDefaultProcedures() {
    // Return a minimal set of common procedures as fallback
    return [
      ProcedureSuggestion(
        procedureName: 'Laparoscopic Cholecystectomy',
        category: 'Chapter 25: Anesthesia for Abdominal Surgery',
        techniques: ['ETT', 'Rapid Sequence Induction'],
        complications: ['PONV', 'Shoulder Pain', 'Pneumoperitoneum effects'],
        confidence: 1.0,
        estimatedDuration: 2.0,
        defaultAssessment: 'ASA II',
        coaCategories: ['General Anesthesia', 'Intra-abdominal'],
        commonTechniques: ['ETT', 'Rapid Sequence Induction'],
        anatomicalLocation: 'Abdomen',
        jaffeReference: 'Chapter 25: Anesthesia for Abdominal Surgery',
      ),
      // Add more default procedures as needed
    ];
  }
}
