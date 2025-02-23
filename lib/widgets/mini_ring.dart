import 'package:flutter/material.dart';

class MiniRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final double strokeWidth;

  const MiniRing({
    super.key,
    required this.progress,
    this.size = 40,
    required this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
