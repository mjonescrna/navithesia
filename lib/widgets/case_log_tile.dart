import 'package:flutter/cupertino.dart';

class CaseLogTile extends StatelessWidget {
  final String category;
  final int currentCount;

  const CaseLogTile({
    Key? key,
    required this.category,
    required this.currentCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // TODO: Navigate to detailed view for this clinical experience category.
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
                inherit: true,
              ),
            ),
            Text(
              '$currentCount',
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
                inherit: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
