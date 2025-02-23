import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_page.dart';
import 'models/time_log_entry.dart';
import 'models/case_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TimeLogEntryAdapter());
  Hive.registerAdapter(CaseEntryAdapter());

  runApp(const NaviThesiaApp());
}

class NaviThesiaApp extends StatelessWidget {
  const NaviThesiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'NaviThesia',
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: LoginPage(),
    );
  }
}
