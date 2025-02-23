// lib/repository/case_log_repository.dart

import 'coa_guidelines.dart'; // Ensure this file defines COACategory and COAGuidelines.categories as a List<COACategory>

class CaseLogRepository {
  final Map<String, int> _categoryCounts = {};
  final Map<String, int> _requiredCounts = {};

  void initializeCOACategories() {
    // Initialize required counts for key categories
    _requiredCounts['Total Clinical Hours'] = 600;
    _requiredCounts['Special Cases - Geriatric (65+ years)'] = 100;
    _requiredCounts['Special Cases - Pediatric (2 to 12 years)'] = 75;
    _requiredCounts['Obstetrical Management - Analgesia for labor'] = 40;

    // Initialize current counts to 0
    _categoryCounts.clear();
    for (var category in _requiredCounts.keys) {
      _categoryCounts[category] = 0;
    }
  }

  int getCountForCategory(String category) {
    return _categoryCounts[category] ?? 0;
  }

  int getRequiredForCategory(String category) {
    return _requiredCounts[category] ?? 0;
  }

  void updateCount(String category, int increment) {
    _categoryCounts[category] = (_categoryCounts[category] ?? 0) + increment;
  }

  Map<String, dynamic> getAllLogs() {
    Map<String, dynamic> allLogs = {};

    _categoryCounts.forEach((category, count) {
      allLogs[category] = {
        'current': count,
        'required': getRequiredForCategory(category),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    });

    return allLogs;
  }
}
