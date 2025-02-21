import 'package:flutter/cupertino.dart';
import 'screens/login_page.dart';

void main() {
  runApp(NaviThesiaApp());
}

class NaviThesiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'NaviThesia',
      theme: CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
      // Start with the login page.
      home: LoginPage(),
    );
  }
}
