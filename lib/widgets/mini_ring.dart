import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MiniRing extends StatelessWidget {
  final int current;
  final int required;
  final double size;

  const MiniRing({
    Key? key,
    required this.current,
    required this.required,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percent = required > 0 ? current / required : 0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent > 1 ? 1 : percent,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            backgroundColor: Colors.grey[800],
          ),
          Text(
            '$current/$required',
            style: const TextStyle(fontSize: 10, color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }
}
