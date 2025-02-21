import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_case_page.dart';
import '../widgets/case_countdown.dart';
import '../widgets/case_log_tile.dart';

class HomePage extends StatelessWidget {
  // This page shows resident info, a countdown widget, and a scrollable list of clinical experience categories.
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Home')),
      child: SafeArea(
        child: Column(
          children: [
            // Resident information, styled according to Apple guidelines.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '[Resident\'s Name]',
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '[School Name]',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              ),
            ),
            // Case Countdown widget (tappable – following a simple Apple-style interaction)
            CaseCountdownWidget(initialCount: 600),
            // Scrollable list of clinical experience categories
            Expanded(
              child: ListView(
                children: [
                  // Each tile uses a custom widget that conforms to Cupertino styling.
                  CaseLogTile(category: 'Special Cases', currentCount: 0),
                  CaseLogTile(
                    category: 'Anatomical Categories',
                    currentCount: 0,
                  ),
                  CaseLogTile(
                    category: 'Methods of Anesthesia',
                    currentCount: 0,
                  ),
                  CaseLogTile(category: 'Pharm Agents', currentCount: 0),
                  // Add additional categories as needed.
                ],
              ),
            ),
            // Add Case/Procedure Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                child: Text('Add Case / Procedure'),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => AddCasePage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
