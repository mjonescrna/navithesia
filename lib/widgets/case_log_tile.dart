import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CaseLogTile extends StatelessWidget {
  final String category;
  final int currentCount;

  const CaseLogTile({required this.category, required this.currentCount});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // TODO: Navigate to a detailed view for this clinical experience category.
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            Text(
              '$currentCount',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
