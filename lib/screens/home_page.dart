import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../repository/case_log_repository.dart';
import 'add_case_page.dart';
import 'logs_page.dart';
import 'goals_page.dart';
import 'message_page.dart';
import '../widgets/mini_ring.dart';

class HomePage extends StatefulWidget {
  final String residentName;
  final String schoolName;

  const HomePage({
    Key? key,
    required this.residentName,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Main total case countdown: starts at 600.
  int _totalCaseCountdown = 600;
  late ConfettiController _confettiController;
  final CaseLogRepository _repository = CaseLogRepository();

  // The four key categories to display (these can be made configurable)
  final List<String> keyCategories = [
    "Total Clinical Hours",
    "Special Cases - Geriatric 65+ years",
    "Special Cases - Pediatric 2 to 12 years",
    "Obstetrical Management - Analgesia for labor",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // For demonstration, simulate logging a case. In a real app, this method
  // would be called after a successful log.
  void _simulateLogCase() {
    setState(() {
      // Suppose that if a physical status is provided then total countdown updates.
      // For this demo, we assume the case qualifies.
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
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentComplete,
            strokeWidth: 12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            backgroundColor: Colors.grey[800],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_totalCaseCountdown',
                style: const TextStyle(
                  fontSize: 32,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Case Countdown',
                style: TextStyle(fontSize: 16, color: CupertinoColors.white),
              ),
            ],
          ),
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.red,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a tile for a key category: grey rectangle with white text on the left and a mini ring on the right.
  Widget _buildKeyTile(String category) {
    int current = _repository.getCountForCategory(category);
    int required = _repository.getRequiredForCategory(category);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
              ),
            ),
          ),
          MiniRing(current: current, required: required, size: 50),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'Home',
          style: const TextStyle(color: CupertinoColors.white, fontSize: 18),
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
              // Grid of four key category tiles.
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 5,
                children:
                    keyCategories
                        .map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildKeyTile(cat),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              // For demonstration, a button to simulate logging a case.
              CupertinoButton.filled(
                child: const Text('Simulate Log Case'),
                onPressed: _simulateLogCase,
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
