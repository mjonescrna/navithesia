import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/clinical_site.dart';
import '../models/clinical_goal.dart';
import '../services/clinical_site_service.dart';
import '../repository/case_log_repository.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final ClinicalSiteService _siteService = ClinicalSiteService();
  final CaseLogRepository _caseRepository = CaseLogRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  List<ClinicalSite> _searchResults = [];
  ClinicalSite? _selectedSite;
  int _rotationWeeks = 4;
  final List<ClinicalGoal> _goals = [];
  final List<String> _invitedClassmates = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);
    try {
      await _siteService.initialize();
      // Get user's current location (implement proper location service)
      await _siteService.updateCurrentLocation(26.0187, -80.1798);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.length >= 2) {
      _searchSites();
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _searchSites() async {
    setState(() => _isSearching = true);
    try {
      final results = await _siteService.searchSites(_searchController.text);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching sites: $e');
      setState(() => _isSearching = false);
    }
  }

  Widget _buildSiteSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical Site',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _searchController,
            placeholder: 'Search hospitals within 100 miles...',
            prefix: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                CupertinoIcons.search,
                color: CupertinoColors.systemGrey,
              ),
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            style: const TextStyle(color: CupertinoColors.white),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CupertinoActivityIndicator(),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final site = _searchResults[index];
                  final distance = _siteService.getDistance(site.id);
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedSite = site;
                        _searchController.text = site.name;
                        _searchResults = [];
                      });
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                site.name,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 16,
                                ),
                              ),
                              if (distance != null)
                                Text(
                                  '${distance.toStringAsFixed(1)} miles away',
                                  style: TextStyle(
                                    color: CupertinoColors.white.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          color: CupertinoColors.systemGrey,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRotationDuration() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rotation Duration',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CupertinoSlider(
                  value: _rotationWeeks.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  onChanged: (value) {
                    setState(() => _rotationWeeks = value.round());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$_rotationWeeks weeks',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Goals',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_goals.length < 10)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _addNewGoal,
                child: const Icon(
                  CupertinoIcons.add_circled,
                  color: CupertinoColors.systemBlue,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._goals.map(_buildGoalTile),
        if (_goals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add up to 10 goals for this rotation',
                style: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoalTile(ClinicalGoal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.category,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${goal.targetCount}',
                      style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (goal.collaborators.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.person_2_fill,
                            color: CupertinoColors.systemBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${goal.collaborators.length}',
                            style: const TextStyle(
                              color: CupertinoColors.systemBlue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _editGoal(goal),
                    child: const Icon(
                      CupertinoIcons.pencil_circle,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progressPercentage,
              backgroundColor: CupertinoColors.systemGrey6,
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isOverdue
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGreen,
              ),
            ),
          ),
          if (goal.daysRemaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${goal.daysRemaining} days remaining',
                style: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addNewGoal() {
    if (_selectedSite == null) {
      _showError('Please select a clinical site first');
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => _GoalEditSheet(
            site: _selectedSite!,
            onSave: (category, target, collaborators) {
              setState(() {
                _goals.add(
                  ClinicalGoal.create(
                    category: category,
                    targetCount: target,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(
                      Duration(days: _rotationWeeks * 7),
                    ),
                    clinicalSiteId: _selectedSite!.id,
                    collaborators: collaborators,
                  ),
                );
              });
            },
          ),
    );
  }

  void _editGoal(ClinicalGoal goal) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => _GoalEditSheet(
            site: _selectedSite!,
            initialCategory: goal.category,
            initialTarget: goal.targetCount,
            initialCollaborators: goal.collaborators,
            onSave: (category, target, collaborators) {
              setState(() {
                final index = _goals.indexWhere((g) => g.id == goal.id);
                if (index != -1) {
                  _goals[index] = ClinicalGoal(
                    id: goal.id,
                    category: category,
                    targetCount: target,
                    startDate: goal.startDate,
                    endDate: goal.endDate,
                    clinicalSiteId: goal.clinicalSiteId,
                    collaborators: collaborators,
                    progressByUser: goal.progressByUser,
                    isCompleted: goal.isCompleted,
                    notes: goal.notes,
                  );
                }
              });
            },
          ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text('Goals', style: TextStyle(color: CupertinoColors.white)),
      ),
      child: SafeArea(
        child:
            _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSiteSelector(),
                    const SizedBox(height: 16),
                    _buildRotationDuration(),
                    const SizedBox(height: 16),
                    _buildGoalsList(),
                  ],
                ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

class _GoalEditSheet extends StatefulWidget {
  final ClinicalSite site;
  final String? initialCategory;
  final int? initialTarget;
  final List<String>? initialCollaborators;
  final Function(String, int, List<String>) onSave;

  const _GoalEditSheet({
    required this.site,
    this.initialCategory,
    this.initialTarget,
    this.initialCollaborators,
    required this.onSave,
  });

  @override
  State<_GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<_GoalEditSheet> {
  late String _selectedCategory;
  late TextEditingController _targetController;
  List<String> _selectedCollaborators = [];

  final List<String> _categories = [
    'Pediatric (2-12 years)',
    'Geriatric (65+ years)',
    'Trauma/Emergency',
    'Obstetric',
    'Pain Management',
    'Regional',
    'Cardiovascular',
    'Thoracic',
    'Neurologic',
    'Orthopedic',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? _categories.first;
    _targetController = TextEditingController(
      text: widget.initialTarget?.toString() ?? '',
    );
    _selectedCollaborators = widget.initialCollaborators ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: CupertinoColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const Text(
                'Set Goal',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  final target = int.tryParse(_targetController.text);
                  if (target == null || target <= 0) {
                    // Show error
                    return;
                  }
                  widget.onSave(
                    _selectedCategory,
                    target,
                    _selectedCollaborators,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CupertinoPicker(
              itemExtent: 32,
              onSelectedItemChanged: (index) {
                setState(() => _selectedCategory = _categories[index]);
              },
              children:
                  _categories
                      .map(
                        (cat) => Text(
                          cat,
                          style: const TextStyle(color: CupertinoColors.white),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _targetController,
            placeholder: 'Target number of cases',
            keyboardType: TextInputType.number,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            style: const TextStyle(color: CupertinoColors.white),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.circular(8),
            onPressed: _inviteCollaborators,
            child: const Text('Invite Classmates'),
          ),
        ],
      ),
    );
  }

  void _inviteCollaborators() {
    // Implement collaborator invitation
    // This would typically show a list of classmates to select from
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }
}
