import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/case_log_model.dart'; // Make sure the path is correct.
import 'screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and Hive Flutter.
  await Hive.initFlutter();

  // Register the adapter for CaseLog.
  Hive.registerAdapter(CaseLogAdapter());

  // Open the Hive box to store case logs.
  await Hive.openBox<CaseLog>('caseLogs');

  runApp(const NaviThesiaApp());
}

class NaviThesiaApp extends StatelessWidget {
  const NaviThesiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'NaviThesia',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: CupertinoColors.black,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            inherit: true,
            fontSize: 14,
            color: CupertinoColors.white,
          ),
          navTitleTextStyle: TextStyle(
            inherit: true,
            fontSize: 16,
            color: CupertinoColors.white,
          ),
          navLargeTitleTextStyle: TextStyle(
            inherit: true,
            fontSize: 28,
            color: CupertinoColors.white,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
