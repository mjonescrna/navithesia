import 'package:flutter/cupertino.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'Messages',
          style: TextStyle(color: CupertinoColors.white, fontSize: 16),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'Messages from your school will appear here.\n\n(Reply functionality coming soon.)',
            style: TextStyle(color: CupertinoColors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
