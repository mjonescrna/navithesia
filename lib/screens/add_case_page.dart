// lib/screens/add_case_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../repository/case_repository.dart';
import '../models/case_entry.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/jaffe_reference_service.dart';
import '../models/procedure_suggestion.dart';
import './home_page.dart';

class AddCasePage extends StatefulWidget {
  const AddCasePage({super.key});

  @override
  State<AddCasePage> createState() => _AddCasePageState();
}

class _AddCasePageState extends State<AddCasePage> {
  final OCRService _ocrService = OCRService();
  final CaseRepository _repository = CaseRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final JaffeReferenceService _jaffeService = JaffeReferenceService();
  bool _isProcessing = false;

  // Form Controllers
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _patientAgeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Selected Values
  String _selectedASA = '';
  bool _isEmergency = false;
  List<String> _selectedAnatomicalCategories = [];
  List<String> _selectedAnesthesiaTypes = [];
  List<String> _selectedMonitoring = [];
  List<String> _selectedTechniques = [];
  final DateTime _selectedDate = DateTime.now();
  double _clinicalHours = 0.0;
  List<ProcedureSuggestion> _suggestions = [];
  String _jaffeReference = '';
  List<String> _commonComplications = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _procedureController.addListener(_onProcedureSearchChanged);
  }

  Future<void> _initializeServices() async {
    await _repository.initialize();
    await _jaffeService.initialize();
  }

  void _onProcedureSearchChanged() {
    if (_procedureController.text.length >= 2) {
      final suggestions = _jaffeService.searchProcedures(
        _procedureController.text,
      );
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _selectProcedure(ProcedureSuggestion suggestion) {
    setState(() {
      _procedureController.text = suggestion.procedureName;

      // Set anatomical categories
      if (suggestion.anatomicalLocation.isNotEmpty) {
        _selectedAnatomicalCategories = [suggestion.anatomicalLocation];
      }

      // Set anesthesia types
      _selectedAnesthesiaTypes =
          suggestion.coaCategories
              .where((cat) => CaseRepository.anesthesiaTypes.contains(cat))
              .toList();

      // Set monitoring types - always include Standard ASA and Temperature
      _selectedMonitoring = [
        'Standard ASA',
        'Temperature',
        ...suggestion.commonTechniques
            .where(
              (tech) =>
                  CaseRepository.monitoringTypes.contains(tech) &&
                  tech != 'Standard ASA' &&
                  tech != 'Temperature',
            )
            .toList(),
      ];

      // Set special techniques
      _selectedTechniques =
          suggestion.commonTechniques
              .where((tech) => CaseRepository.specialTechniques.contains(tech))
              .toList();

      // Set clinical hours
      _clinicalHours = suggestion.estimatedDuration;

      // Set ASA status
      _selectedASA = suggestion.defaultAssessment;

      // Set complications
      _commonComplications = suggestion.complications;

      _showSuggestions = false;
    });

    // Load any saved customizations for this procedure
    _loadProcedureCustomizations(suggestion.procedureName);
  }

  Future<void> _loadProcedureCustomizations(String procedureName) async {
    // TODO: Load saved customizations from local storage
    // This will be implemented to load any user-specific changes
  }

  Future<void> _saveProcedureCustomizations() async {
    // TODO: Save current customizations to local storage
    // This will be implemented to save any user changes for future use
  }

  Future<void> _takePicture() async {
    setState(() => _isProcessing = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        final result = await _ocrService.processImage(File(image.path));
        _populateFieldsFromOCR(result);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _populateFieldsFromOCR(Map<String, dynamic> data) {
    setState(() {
      _procedureController.text = data['procedure'] ?? '';
      _patientAgeController.text = data['age']?.toString() ?? '';
      _selectedASA = data['asa'] ?? '';
      if (data['anatomicalLocation'] != null) {
        _selectedAnatomicalCategories = [data['anatomicalLocation']];
      }
      if (data['anesthesiaType'] != null) {
        _selectedAnesthesiaTypes = [data['anesthesiaType']];
      }
      if (data['techniques'] != null) {
        _selectedTechniques = List<String>.from(data['techniques']);
      }
      _clinicalHours = (data['duration'] as num?)?.toDouble() ?? 0.0;
    });
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      style: const TextStyle(color: CupertinoColors.white),
      placeholderStyle: TextStyle(
        color: CupertinoColors.systemGrey.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCheckboxList(
    String title,
    List<String> options,
    List<String> selectedValues,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedValues.contains(option);
                return GestureDetector(
                  onTap: () {
                    final newValues = List<String>.from(selectedValues);
                    if (isSelected) {
                      newValues.remove(option);
                    } else {
                      newValues.add(option);
                    }
                    onChanged(newValues);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey6.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color:
                            isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.systemGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildProcedureSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: _procedureController,
          placeholder: 'Search procedure...',
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
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children:
                  _suggestions
                      .map(
                        (suggestion) => CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          onPressed: () => _selectProcedure(suggestion),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suggestion.procedureName,
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      suggestion.jaffeReference,
                                      style: TextStyle(
                                        color: CupertinoColors.white
                                            .withOpacity(0.7),
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
                        ),
                      )
                      .toList(),
            ),
          ),
        if (_jaffeReference.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Reference: $_jaffeReference',
              style: TextStyle(
                color: CupertinoColors.systemBlue.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _saveCase() async {
    if (_procedureController.text.isEmpty) {
      _showError('Please enter a procedure');
      return;
    }

    if (_selectedASA.isEmpty) {
      _showError('Please select an ASA status');
      return;
    }

    if (_selectedAnatomicalCategories.isEmpty) {
      _showError('Please select at least one anatomical category');
      return;
    }

    if (_selectedAnesthesiaTypes.isEmpty) {
      _showError('Please select at least one anesthesia type');
      return;
    }

    try {
      final entry = CaseEntry.create(
        date: _selectedDate,
        procedureName: _procedureController.text,
        patientAge: int.tryParse(_patientAgeController.text) ?? 0,
        asaStatus: _selectedASA,
        anatomicalCategories: _selectedAnatomicalCategories,
        anesthesiaTypes: _selectedAnesthesiaTypes,
        monitoringTypes: _selectedMonitoring,
        specialTechniques: _selectedTechniques,
        isEmergency: _isEmergency,
        clinicalHours: _clinicalHours,
        notes: _notesController.text,
        selectedCategories: [
          ..._selectedAnatomicalCategories,
          ..._selectedAnesthesiaTypes,
          ..._selectedMonitoring,
          ..._selectedTechniques,
        ],
      );

      if (_repository.validateCase(entry)) {
        await _repository.addCase(entry);
        if (mounted) {
          _showSuccess('Case added successfully');
          _resetForm(); // Clear the form for next entry
        }
      } else {
        _showError('Please fill in all required fields');
      }
    } catch (e) {
      _showError('Failed to save case: ${e.toString()}');
    }
  }

  void _resetForm() {
    setState(() {
      _procedureController.clear();
      _patientAgeController.clear();
      _weightController.clear();
      _heightController.clear();
      _notesController.clear();
      _selectedASA = '';
      _isEmergency = false;
      _selectedAnatomicalCategories = [];
      _selectedAnesthesiaTypes = [];
      _selectedMonitoring = [];
      _selectedTechniques = [];
      _clinicalHours = 0.0;
      _commonComplications = [];
      _jaffeReference = '';
    });
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Add Another Case'),
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
              ),
              CupertinoDialogAction(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate back to home page and select the home tab
                  Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(
                      builder:
                          (context) => HomePage(
                            residentName:
                                'Your Name', // Replace with actual resident name
                            schoolName:
                                'Your School', // Replace with actual school name
                          ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: const Text(
          'Add Case',
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isProcessing ? null : _takePicture,
              child:
                  _isProcessing
                      ? const CupertinoActivityIndicator()
                      : const Icon(
                        CupertinoIcons.camera,
                        color: CupertinoColors.systemBlue,
                      ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveCase,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              'Procedure Details',
              Column(
                children: [
                  _buildProcedureSearch(),
                  if (_commonComplications.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Common Complications:',
                      style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _commonComplications
                              .map(
                                (complication) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemYellow
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    complication,
                                    style: const TextStyle(
                                      color: CupertinoColors.systemYellow,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _patientAgeController,
                          placeholder: 'Age',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _weightController,
                          placeholder: 'Weight (kg)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSection(
              'Patient Status',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckboxList(
                    'ASA Status',
                    CaseRepository.asaStatuses,
                    [_selectedASA],
                    (values) => setState(() => _selectedASA = values.first),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CupertinoSwitch(
                        value: _isEmergency,
                        onChanged:
                            (value) => setState(() => _isEmergency = value),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Emergency Case',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSection(
              'Anatomical Categories',
              _buildCheckboxList(
                '',
                CaseRepository.anatomicalCategories,
                _selectedAnatomicalCategories,
                (values) =>
                    setState(() => _selectedAnatomicalCategories = values),
              ),
            ),
            _buildSection(
              'Anesthesia Types',
              _buildCheckboxList(
                '',
                CaseRepository.anesthesiaTypes,
                _selectedAnesthesiaTypes,
                (values) => setState(() => _selectedAnesthesiaTypes = values),
              ),
            ),
            _buildSection(
              'Monitoring',
              _buildCheckboxList(
                '',
                CaseRepository.monitoringTypes,
                _selectedMonitoring,
                (values) => setState(() => _selectedMonitoring = values),
              ),
            ),
            _buildSection(
              'Special Techniques',
              _buildCheckboxList(
                '',
                CaseRepository.specialTechniques,
                _selectedTechniques,
                (values) => setState(() => _selectedTechniques = values),
              ),
            ),
            _buildSection(
              'Clinical Hours',
              Row(
                children: [
                  Expanded(
                    child: CupertinoSlider(
                      value: _clinicalHours,
                      min: 0,
                      max: 24,
                      divisions: 48,
                      onChanged:
                          (value) => setState(() => _clinicalHours = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_clinicalHours.toStringAsFixed(1)} hours',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Notes',
              CupertinoTextField(
                controller: _notesController,
                placeholder: 'Additional notes...',
                minLines: 3,
                maxLines: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _procedureController.dispose();
    _patientAgeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
