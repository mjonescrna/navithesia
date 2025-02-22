import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int _rotationWeeks = 4;
  // Sample goals: keys are COA categories, values are target and current counts.
  Map<String, Map<String, int>> _goals = {
    "Pediatric Cases": {"target": 30, "completed": 10},
    "Regional Anesthesia": {"target": 35, "completed": 15},
    "OB Anesthesia": {"target": 20, "completed": 5},
  };

  // For classmate invitations (simulate a detailed search UI)
  final List<String> _classmates = [
    "Alice Johnson",
    "Bob Smith",
    "Charlie Davis",
    "Dana Lee",
    // ... add additional classmates as needed
  ];
  String _selectedClassmate = "";

  @override
  Widget build(BuildContext context) {
    double overallProgress = _calculateOverallProgress();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          "Goals",
          style: TextStyle(color: CupertinoColors.white, fontSize: 16),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section: Rotation duration and goal selection.
              const Text(
                "Set Your Clinical Rotation",
                style: TextStyle(fontSize: 16, color: CupertinoColors.white),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      "Rotation Duration (weeks):",
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  CupertinoSegmentedControl<int>(
                    groupValue: _rotationWeeks,
                    children: const {
                      4: Padding(padding: EdgeInsets.all(8), child: Text("4")),
                      8: Padding(padding: EdgeInsets.all(8), child: Text("8")),
                      12: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("12"),
                      ),
                      16: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("16"),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        _rotationWeeks = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Middle section: Progress indicators.
              const Text(
                "Your Progress",
                style: TextStyle(fontSize: 16, color: CupertinoColors.white),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goals.keys.map((category) {
                  int target = _goals[category]!["target"]!;
                  int completed = _goals[category]!["completed"]!;
                  double progress = target > 0 ? completed / target : 0;
                  return Container(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008B9F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          category,
                          style: const TextStyle(fontSize: 16, color: Colors.white, inherit: true),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade700,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}% completed",
                          style: const TextStyle(fontSize: 14, color: Colors.white, inherit: true),
                        ),
                        // Uncomment the following if you want a Cupertino-style circular indicator.
                        // CupertinoActivityIndicator(radius: 10),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Overall Progress: ${(overallProgress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(fontSize: 16, color: CupertinoColors.white, inherit: true),
                ),
              ),
              const SizedBox(height: 16),
              // Bottom section: Invite classmates.
              const Text(
                "Invite a Classmate",
                style: TextStyle(fontSize: 16, color: CupertinoColors.white, inherit: true),
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _classmates.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _selectedClassmate = selection;
                    });
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController fieldController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    fieldController.text = _selectedClassmate;
                    return CupertinoTextField(
                      controller: fieldController,
                      focusNode: fieldFocusNode,
                      placeholder: 'Type classmate name',
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                        inherit: true,
                      ),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        inherit: true,
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
                                style: const TextStyle(fontSize: 14, color: CupertinoColors.white, inherit: true),
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
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: const Text("Save Goals", style: TextStyle(fontSize: 16, inherit: true)),
                onPressed: () {
                  // TODO: Save goals (send to backend when available).
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text("Goals Saved"),
                        content: const Text("Your rotation goals have been saved."),
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateOverallProgress() {
    double totalProgress = 0;
    int count = _goals.length;
    _goals.forEach((key, value) {
      int target = value["target"]!;
      int completed = value["completed"]!;
      if (target > 0) totalProgress += (completed / target);
    });
    return count > 0 ? totalProgress / count : 0;
  }
}
