import 'package:flutter/cupertino.dart';

class CaseCountdownWidget extends StatefulWidget {
  final int initialCount;
  const CaseCountdownWidget({super.key, required this.initialCount});

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
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void decrementCount() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
      if (_currentCount == 0) {
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
    // Build a neat Cupertino-style tile for the case countdown.
    return GestureDetector(
      onTap: decrementCount,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF008B9F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Case Countdown",
              style: TextStyle(fontSize: 16, color: CupertinoColors.white),
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$_currentCount',
                  style: const TextStyle(
                    fontSize: 28,
                    color: CupertinoColors.white,
                  ),
                ),
                SizeTransition(
                  sizeFactor: _animationController,
                  axis: Axis.vertical,
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: CupertinoColors.systemYellow,
                    size: 50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap to add a case",
              style: TextStyle(fontSize: 14, color: CupertinoColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
