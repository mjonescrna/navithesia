import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int _rotationWeeks = 4;
  Map<String, int> _goalCounts = {
    'Pediatric Cases': 0,
    'Regional Anesthesia': 0,
    'OB Anesthesia': 0,
    // Add additional goal categories as needed.
  };

  // In a production app, you would compute the completion percentage based on real case log data.
  double get _completionPercentage {
    int totalGoals = _goalCounts.values.fold(0, (sum, count) => sum + count);
    int requiredCases = _rotationWeeks * 5; // Example: 5 cases per week
    return (totalGoals / requiredCases).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Set Goals')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Rotation duration selection.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rotation Duration (weeks):'),
                  CupertinoSegmentedControl<int>(
                    groupValue: _rotationWeeks,
                    onValueChanged: (int value) {
                      setState(() {
                        _rotationWeeks = value;
                      });
                    },
                    children: {
                      4: Padding(padding: EdgeInsets.all(4), child: Text('4')),
                      8: Padding(padding: EdgeInsets.all(4), child: Text('8')),
                      12: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('12'),
                      ),
                      16: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('16'),
                      ),
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Goals list for various categories.
              Expanded(
                child: ListView(
                  children:
                      _goalCounts.keys.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(category)),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Text('${_goalCounts[category]}'),
                                onPressed: () {
                                  setState(() {
                                    _goalCounts[category] =
                                        _goalCounts[category]! + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              // Display completion percentage for the rotation goals.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Completion: ${(_completionPercentage * 100).toStringAsFixed(1)}%',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
              ),
              CupertinoButton.filled(
                child: Text('Save Goals'),
                onPressed: () {
                  // TODO: Save the goals persistently and update completion calculations as needed.
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text('Goals Saved'),
                        content: Text('Your rotation goals have been saved.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('OK'),
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
}
