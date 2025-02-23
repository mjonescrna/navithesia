// lib/screens/logs_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../repository/case_log_repository.dart';
import '../repository/coa_guidelines.dart';
import '../widgets/mini_ring.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:confetti/confetti.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage>
    with SingleTickerProviderStateMixin {
  final CaseLogRepository _repository = CaseLogRepository();
  bool _isSyncing = false;
  String _searchQuery = '';
  String _selectedGroup = 'All';
  late AnimationController _animationController;
  late ConfettiController _confettiController;
  final Map<String, bool> _completedCategories = {};

  // Define gradient colors for categories
  final Map<String, List<Color>> categoryColors = {
    'Patient Physical Status': [Color(0xFF4158D0), Color(0xFF3B2667)],
    'Special Cases': [Color(0xFF0093E9), Color(0xFF80D0C7)],
    'Anatomical Categories': [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
    'Methods of Anesthesia': [Color(0xFFA9C9FF), Color(0xFFFFBBEC)],
    'Obstetrical Management': [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
    'Special Techniques': [Color(0xFF4158D0), Color(0xFFC850C0)],
  };

  // Categories grouped by type
  final Map<String, List<String>> categoryGroups = {
    'Patient Physical Status': ['ASA I & II', 'ASA III', 'ASA IV & V'],
    'Special Cases': [
      'Geriatric 65+ years',
      'Pediatric 2-12 years',
      'Pediatric (under 2 years)',
      'Trauma/Emergency',
    ],
    'Anatomical Categories': [
      'Intra-abdominal',
      'Extrathoracic',
      'Intrathoracic',
      'Vascular',
      'Head',
      'Neck',
    ],
    'Methods of Anesthesia': [
      'General Anesthesia',
      'IV Induction',
      'Mask Induction',
      'Regional Anesthesia',
      'Spinal',
      'Epidural',
      'Peripheral Nerve Block',
    ],
    'Obstetrical Management': ['Cesarean Delivery', 'Analgesia for Labor'],
    'Special Techniques': [
      'Central Line Placement',
      'Arterial Line Placement',
      'Ultrasound Guided Techniques',
      'Pain Management Encounters',
    ],
  };

  @override
  void initState() {
    super.initState();
    _repository.initializeCOACategories();
    _setupPeriodicSync();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _initializeCompletedCategories();
  }

  void _initializeCompletedCategories() {
    categoryGroups.forEach((group, categories) {
      for (var category in categories) {
        int current = _repository.getCountForCategory(category);
        int required = _repository.getRequiredForCategory(category);
        _completedCategories[category] = current >= required;
      }
    });
  }

  void _checkCompletion(String category) {
    int current = _repository.getCountForCategory(category);
    int required = _repository.getRequiredForCategory(category);
    bool wasCompleted = _completedCategories[category] ?? false;
    bool isNowCompleted = current >= required;

    if (!wasCompleted && isNowCompleted) {
      _completedCategories[category] = true;
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _setupPeriodicSync() {
    // TODO: Implement periodic sync with server
    // Future implementation will include:
    // - Authentication
    // - API endpoints
    // - Error handling
    // - Retry logic
  }

  Future<void> _syncWithServer() async {
    setState(() => _isSyncing = true);
    try {
      // TODO: Implement actual API sync
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _downloadLogs({String? category}) async {
    // Generate CSV or PDF format
    final Map<String, dynamic> logsData = _repository.getAllLogs();
    if (category != null) {
      // Filter for specific category
      final filteredData = Map<String, dynamic>.from(logsData)
        ..removeWhere((key, value) => !key.startsWith(category));
      logsData.clear();
      logsData.addAll(filteredData);
    }

    // Convert to CSV format
    String csvData = 'Category,Current,Required,Date Updated\n';
    logsData.forEach((key, value) {
      csvData +=
          '$key,${value['current']},${value['required']},${value['lastUpdated']}\n';
    });

    // Save to temporary file and share
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/case_logs.csv');
    await file.writeAsString(csvData);

    // Share the file using platform-specific sharing
    final result = await showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text('Export Logs'),
            message: const Text('Choose export format'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 'csv');
                },
                child: const Text('CSV Format'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 'pdf');
                },
                child: const Text('PDF Format'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              isDestructiveAction: true,
              child: const Text('Cancel'),
            ),
          ),
    );

    if (result == null) return;

    // For now, we'll just use the CSV file
    // TODO: Implement PDF export when selected
    try {
      await file.create(recursive: true);
      await file.writeAsString(csvData);
      // Show success message
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Success'),
                content: const Text('Logs have been exported successfully.'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: Text('Failed to export logs: $e'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  List<String> get filteredGroups {
    if (_selectedGroup != 'All') {
      return [_selectedGroup];
    }
    return categoryGroups.keys.toList();
  }

  bool _categoryMatchesSearch(String category) {
    if (_searchQuery.isEmpty) return true;
    return category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        _getCategoryPath(
          category,
        ).toLowerCase().contains(_searchQuery.toLowerCase());
  }

  // Helper method to get full category path
  String _getCategoryPath(String category) {
    String groupTitle = '';
    categoryGroups.forEach((key, value) {
      if (value.contains(category)) {
        groupTitle = key;
      }
    });
    return '$groupTitle - $category';
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Hero(
            tag: 'searchBar',
            child: CupertinoSearchTextField(
              placeholder: 'Search categories...',
              style: const TextStyle(color: CupertinoColors.white),
              placeholderStyle: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
              ),
              backgroundColor: CupertinoColors.systemGrey6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip('All'),
                ...categoryGroups.keys.map((group) => _buildFilterChip(group)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String group) {
    bool isSelected = _selectedGroup == group;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          setState(() {
            _selectedGroup = isSelected ? 'All' : group;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? CupertinoColors.systemBlue : Colors.grey[850],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            group,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGroup(String groupTitle, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            groupTitle,
            style: const TextStyle(
              fontSize: 18,
              color: CupertinoColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...categories.map((category) => _buildLogTile(category, groupTitle)),
      ],
    );
  }

  Widget _buildLogTile(String category, String groupTitle) {
    int current = _repository.getCountForCategory(category);
    int required = COAGuidelines.requiredCounts[category] ?? 0;
    double progress = required > 0 ? current / required : 0.0;
    progress = progress.clamp(0.0, 1.0);
    bool isCompleted = current >= required && required > 0;

    return Container(
      decoration: BoxDecoration(
        color:
            isCompleted
                ? Colors.greenAccent.withOpacity(0.2)
                : Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$current/$required',
                style: TextStyle(
                  fontSize: 16,
                  color: isCompleted ? Colors.greenAccent : Colors.grey[300],
                  fontWeight: FontWeight.w500,
                  inherit: true,
                ),
              ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    HSVColor.lerp(
                      HSVColor.fromColor(Colors.red),
                      HSVColor.fromColor(Colors.greenAccent),
                      progress,
                    )!.toColor(),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, List<String>>> filteredCategories = [];

    if (_searchQuery.isEmpty && _selectedGroup == 'All') {
      filteredCategories = categoryGroups.entries.toList();
    } else {
      categoryGroups.forEach((group, categories) {
        if (_selectedGroup == 'All' || _selectedGroup == group) {
          List<String> matchingCategories =
              categories.where((category) {
                return category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    group.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

          if (matchingCategories.isNotEmpty) {
            filteredCategories.add(MapEntry(group, matchingCategories));
          }
        }
      });
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid),
            label: 'Add Case',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Messages',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoPageScaffold(
          backgroundColor: Colors.black,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.black,
            middle: const Text(
              "Clinical Experiences",
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 18,
                inherit: true,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isSyncing ? null : _syncWithServer,
                  child: Icon(
                    _isSyncing
                        ? CupertinoIcons.refresh_circled
                        : CupertinoIcons.cloud_upload,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed:
                      () => _downloadLogs(
                        category:
                            _selectedGroup != 'All' ? _selectedGroup : null,
                      ),
                  child: const Icon(
                    CupertinoIcons.cloud_download,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final group = filteredCategories[index].key;
                      final categories = filteredCategories[index].value;
                      return _buildCategoryGroup(group, categories);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
