import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CaseCountdownWidget extends StatefulWidget {
  final int initialCount;

  CaseCountdownWidget({required this.initialCount});

  @override
  _CaseCountdownWidgetState createState() => _CaseCountdownWidgetState();
}

class _CaseCountdownWidgetState extends State<CaseCountdownWidget>
    with SingleTickerProviderStateMixin {
  late int _currentCount;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.initialCount;
    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
  }

  void decrementCount() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
      if (_currentCount == 0) {
        // When countdown reaches 0, trigger a celebration animation.
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        decrementCount();
      },
      child: Column(
        children: [
          Text(
            'Case Countdown: $_currentCount',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          SizeTransition(
            sizeFactor: _animationController,
            axis: Axis.vertical,
            child: Icon(
              CupertinoIcons.sparkles,
              color: CupertinoColors.systemYellow,
              size: 50,
            ),
          ),
          Text(
            'Tap to simulate adding a case',
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
        ],
      ),
    );
  }
}
