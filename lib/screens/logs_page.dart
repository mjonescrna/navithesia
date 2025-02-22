// logs_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'case_log_repository.dart';
import 'coa_guidelines.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final CaseLogRepository _repository = CaseLogRepository();

  @override
  void initState() {
    super.initState();
    // Initialize the repository with all COA categories.
    _repository.initializeCOACategories();
  }

  @override
  Widget build(BuildContext context) {
    // Build a list tile for each COA category.
    List<Widget> logTiles = [];
    for (var category in COAGuidelines.categories) {
      int current = _repository.currentCounts[category.name] ?? 0;
      logTiles.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              Text(
                '$current / ${category.requiredCount}',
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          "Logs",
          style: TextStyle(color: CupertinoColors.white, fontSize: 16),
        ),
      ),
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logTiles.length,
          separatorBuilder:
              (context, index) =>
                  const Divider(color: CupertinoColors.systemGrey, height: 1),
          itemBuilder: (context, index) {
            return logTiles[index];
          },
        ),
      ),
    );
  }
}
