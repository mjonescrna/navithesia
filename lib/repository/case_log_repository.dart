// case_log_repository.dart
import 'coa_guidelines.dart';

class CaseLogRepository {
  // Singleton instance.
  static final CaseLogRepository _instance = CaseLogRepository._internal();
  factory CaseLogRepository() => _instance;
  CaseLogRepository._internal();

  // Map from category name to current count.
  final Map<String, int> _currentCounts = {};

  /// Initializes the repository with all COA categories set to zero.
  void initializeCOACategories() {
    for (var category in COAGuidelines.categories) {
      _currentCounts[category.name] = 0;
    }
  }

  /// Getter for the current counts.
  Map<String, int> get currentCounts => _currentCounts;

  /// Update the count for a given category.
  void updateCount(String categoryName, int increment) {
    if (_currentCounts.containsKey(categoryName)) {
      _currentCounts[categoryName] = _currentCounts[categoryName]! + increment;
    } else {
      // If for some reason the category wasn’t initialized, add it.
      _currentCounts[categoryName] = increment;
    }
  }
}
