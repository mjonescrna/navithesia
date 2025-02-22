import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';

class AddCasePage extends StatefulWidget {
  const AddCasePage({Key? key}) : super(key: key);

  @override
  _AddCasePageState createState() => _AddCasePageState();
}

class _AddCasePageState extends State<AddCasePage> {
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _totalCasesController = TextEditingController();
  final TextEditingController _anesthesiaHoursController =
      TextEditingController();
  final TextEditingController _clinicalHoursController =
      TextEditingController();
  final TextEditingController _patientAssessmentController =
      TextEditingController();

  final OCRService _ocrService = OCRService();

  // Sample autocomplete suggestions (simulate AI/database integration)
  final List<String> _procedureSuggestions = [
    "Appendectomy",
    "Laparoscopic Cholecystectomy",
    "Central Venous Catheter Insertion",
    "Regional Anesthesia - Epidural",
    "Regional Anesthesia - Spinal",
  ];

  String _selectedProcedure = '';
  bool _instructionsShown = false;

  Future<void> _showInstructionsIfNeeded() async {
    if (!_instructionsShown) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("Camera Instructions"),
            content: const Text(
              "Snap a picture of the case or procedure to add it to your case logs automatically. Click OK to dismiss. This overlay will not appear again.",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _instructionsShown = true;
      });
    }
  }

  // Simulate auto-population of fields based on the procedure text.
  void _autoPopulateFields(String procedure) {
    setState(() {
      _totalCasesController.text = "1";
      _anesthesiaHoursController.text = "2";
      _clinicalHoursController.text = "3";
      _patientAssessmentController.text = "Normal";
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Case / Procedure'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.camera),
          onPressed: () async {
            await _showInstructionsIfNeeded();
            String recognizedText = await _ocrService.processImage(null);
            setState(() {
              _procedureController.text = recognizedText;
              _autoPopulateFields(recognizedText);
            });
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your case/procedure:",
                style: TextStyle(fontSize: 16, color: CupertinoColors.white),
              ),
              const SizedBox(height: 8),
              // Autocomplete field for procedure input.
              Material(
                color: Colors.transparent,
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _procedureSuggestions.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _selectedProcedure = selection;
                      _procedureController.text = selection;
                      _autoPopulateFields(selection);
                    });
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    fieldTextEditingController.text = _selectedProcedure;
                    return CupertinoTextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      placeholder: 'Start typing case/procedure...',
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                      ),
                    );
                  },
                  optionsViewBuilder: (
                    BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: CupertinoColors.darkBackgroundGray,
                        elevation: 4.0,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Auto-populated Details:",
                style: TextStyle(fontSize: 16, color: CupertinoColors.white),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _totalCasesController,
                placeholder: 'Total Cases',
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _anesthesiaHoursController,
                placeholder: 'Total Anesthesia Hours',
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _clinicalHoursController,
                placeholder: 'Total Clinical Hours',
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _patientAssessmentController,
                placeholder: 'Patient Assessment',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton.filled(
                  child: const Text(
                    'Submit Case',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    // TODO: Save the case details and update logs/countdown.
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
