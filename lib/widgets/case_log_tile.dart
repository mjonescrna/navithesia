import 'package:flutter/cupertino.dart';

class CaseLogTile extends StatelessWidget {
  final String category;
  final int currentCount;

  const CaseLogTile({
    super.key,
    required this.category,
    required this.currentCount,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder:
                (context) => CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text(category)),
                  child: SafeArea(
                    child: Center(
                      child: Text(
                        'Details for $category\nCurrent Count: $currentCount',
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
              ),
            ),
            Text(
              '$currentCount',
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
}
