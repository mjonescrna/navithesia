import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/case_log.dart';
import '../services/admin_service.dart';

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  // For demonstration, we use a simple in-memory list of logs.
  // In a real app, these would be loaded from a local database.
  List<CaseLog> _logs = [
    CaseLog(category: 'Special Cases', count: 5),
    CaseLog(category: 'Anatomical Categories', count: 10),
    CaseLog(category: 'Methods of Anesthesia', count: 15),
    CaseLog(category: 'Pharm Agents', count: 3),
  ];

  bool _isPushing = false;
  String _pushStatus = '';

  Future<void> _pushLogs() async {
    setState(() {
      _isPushing = true;
      _pushStatus = 'Pushing logs...';
    });
    try {
      // Convert logs to JSON format.
      List<Map<String, dynamic>> logsJson =
          _logs.map((log) => log.toJson()).toList();
      // Call the AdminService to push logs.
      bool success = await AdminService.pushLogs(
        jsonEncode({'logs': logsJson}),
      );
      setState(() {
        _pushStatus =
            success ? 'Logs successfully pushed!' : 'Failed to push logs.';
      });
    } catch (e) {
      setState(() {
        _pushStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isPushing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Clinical Experience Logs'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.separator),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.category,
                          style: CupertinoTheme.of(context).textTheme.textStyle,
                        ),
                        Text(
                          '${log.count}',
                          style: CupertinoTheme.of(context).textTheme.textStyle,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isPushing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoActivityIndicator(),
              ),
            if (_pushStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _pushStatus,
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
              ),
            // Button to push logs to the school admin website.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                child: Text('Push Logs to Admin Website'),
                onPressed: _isPushing ? null : _pushLogs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
