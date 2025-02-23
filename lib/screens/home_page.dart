// lib/screens/home_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../repository/case_log_repository.dart';
import 'add_case_page.dart';
import 'logs_page.dart';
import 'goals_page.dart';
import 'message_page.dart';

class HomePage extends StatefulWidget {
  final String residentName;
  final String schoolName;

  const HomePage({
    super.key,
    required this.residentName,
    required this.schoolName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Main total case countdown: starts at 600.
  int _totalCaseCountdown = 600;
  late ConfettiController _confettiController;
  final CaseLogRepository _repository = CaseLogRepository();

  // The four key categories to display on the home screen.
  final List<String> keyCategories = [
    "Total Clinical Hours",
    "Special Cases - Geriatric (65+ years)",
    "Special Cases - Pediatric (2 to 12 years)",
    "Obstetrical Management - Analgesia for labor",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Initialize the repository counts from COA guidelines.
    _repository.initializeCOACategories();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Simulate logging a case.
  // In this demo, we update each key category by incrementing its count by 1.
  void _simulateLogCase() {
    setState(() {
      // Update each key category's count.
      for (var category in keyCategories) {
        _repository.updateCount(category, 1);
      }
      // Also, update the overall case countdown.
      if (_totalCaseCountdown > 0) {
        _totalCaseCountdown--;
        if (_totalCaseCountdown == 0) {
          _confettiController.play();
        }
      }
    });
  }

  // Build the large central case countdown ring.
  Widget _buildLargeCountdown() {
    double percentComplete = (600 - _totalCaseCountdown) / 600;
    int currentCases = 600 - _totalCaseCountdown;
    bool isCompleted = _totalCaseCountdown == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: percentComplete,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted
                    ? Colors.greenAccent
                    : HSVColor.lerp(
                      HSVColor.fromColor(Colors.red),
                      HSVColor.fromColor(Colors.greenAccent),
                      percentComplete,
                    )!.toColor(),
              ),
              backgroundColor: Colors.grey[800],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_totalCaseCountdown',
                style: TextStyle(
                  fontSize: 72,
                  color: isCompleted ? Colors.greenAccent : Colors.lightBlue,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cases Remaining',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Progress: $currentCases/600',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(percentComplete * 100).toStringAsFixed(1)}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted ? Colors.greenAccent : Colors.lightBlue,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a tile for a key category. Uses the repository to get current and required counts.
  Widget _buildKeyTile(String category) {
    int current = _repository.getCountForCategory(category);
    int required = _repository.getRequiredForCategory(category);
    double progress = required > 0 ? current / required : 0.0;
    progress = progress.clamp(0.0, 1.0);
    bool isCompleted = current >= required && required > 0;

    return Container(
      decoration: BoxDecoration(
        color:
            isCompleted
                ? Colors.greenAccent.withOpacity(0.2)
                : Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 8),
              Text(
                '$current/$required',
                style: TextStyle(
                  fontSize: 16,
                  color: isCompleted ? Colors.greenAccent : Colors.grey[300],
                  fontWeight: FontWeight.w500,
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

  Widget _buildHomeTab() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: const Text(
          'NaviThesia',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resident Info
              Text(
                widget.residentName,
                style: const TextStyle(
                  fontSize: 24,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.schoolName,
                style: const TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              // Large Center Case Countdown Ring
              Center(child: _buildLargeCountdown()),
              const SizedBox(height: 20),
              // Header for Case Log Totals with "Show All" link.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Case Log Totals:',
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (_) => const LogsPage()),
                      );
                    },
                    child: const Text(
                      'Show All',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Grid (or List) of key category tiles.
              ...keyCategories.map((cat) => _buildKeyTile(cat)),
              const SizedBox(height: 20),
              // For demonstration, a button to simulate logging a case.
              CupertinoButton.filled(
                onPressed: _simulateLogCase,
                child: const Text('Simulate Log Case'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: CupertinoColors.black,
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, color: CupertinoColors.white),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text, color: CupertinoColors.white),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: CupertinoColors.activeBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white,
                size: 30,
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flag, color: CupertinoColors.white),
            label: 'Goals',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.chat_bubble_2,
              color: CupertinoColors.white,
            ),
            label: 'Messages',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildHomeTab();
          case 1:
            return const LogsPage();
          case 2:
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.black,
                middle: const Text(
                  'Add Case / Procedure',
                  style: TextStyle(color: CupertinoColors.white, fontSize: 18),
                ),
              ),
              backgroundColor: CupertinoColors.black,
              child: const AddCasePage(),
            );
          case 3:
            return const GoalsPage();
          case 4:
            return const MessagePage();
          default:
            return Container(color: CupertinoColors.black);
        }
      },
    );
  }
}
