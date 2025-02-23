import 'package:flutter/cupertino.dart';
import '../repository/time_log_repository.dart';
import '../models/time_log_entry.dart';

class TimeLogPage extends StatefulWidget {
  final DateTime selectedDate;

  const TimeLogPage({super.key, required this.selectedDate});

  @override
  State<TimeLogPage> createState() => _TimeLogPageState();
}

class _TimeLogPageState extends State<TimeLogPage> {
  final TimeLogRepository _repository = TimeLogRepository();
  final TextEditingController _firstClockInController = TextEditingController();
  final TextEditingController _firstClockOutController =
      TextEditingController();
  final TextEditingController _secondClockInController =
      TextEditingController();
  final TextEditingController _secondClockOutController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isBoardPrepDay = false;
  bool _isCallExperience = false;
  int _totalShiftMinutes = 0;
  int _anesthesiaMinutes = 0;
  int _conferenceMinutes = 0;
  int _dnpProjectMinutes = 0;
  int _presentationMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadExistingTimeLog();
  }

  Future<void> _loadExistingTimeLog() async {
    final logs = _repository.getTimeLogsForDate(widget.selectedDate);
    if (logs.isNotEmpty) {
      final log = logs.first;
      setState(() {
        _firstClockInController.text = log.firstClockIn;
        _firstClockOutController.text = log.firstClockOut;
        _secondClockInController.text = log.secondClockIn ?? '';
        _secondClockOutController.text = log.secondClockOut ?? '';
        _notesController.text = log.notes;
        _isBoardPrepDay = log.isBoardPrepDay;
        _isCallExperience = log.isCallExperience;
        _totalShiftMinutes = log.totalShiftMinutes;
        _anesthesiaMinutes = log.anesthesiaMinutes;
        _conferenceMinutes = log.conferenceMinutes;
        _dnpProjectMinutes = log.dnpProjectMinutes;
        _presentationMinutes = log.presentationMinutes;
      });
    }
  }

  void _updateTotalTime() {
    int total = 0;

    if (_firstClockInController.text.isNotEmpty &&
        _firstClockOutController.text.isNotEmpty) {
      total += _repository.calculateTotalMinutes(
        _firstClockInController.text,
        _firstClockOutController.text,
      );
    }

    if (_secondClockInController.text.isNotEmpty &&
        _secondClockOutController.text.isNotEmpty) {
      total += _repository.calculateTotalMinutes(
        _secondClockInController.text,
        _secondClockOutController.text,
      );
    }

    setState(() {
      _totalShiftMinutes = total;
    });
  }

  Future<void> _saveTimeLog() async {
    if (_firstClockInController.text.isEmpty ||
        _firstClockOutController.text.isEmpty) {
      _showError('Please enter at least one clock in/out pair');
      return;
    }

    final entry = TimeLogEntry.create(
      date: widget.selectedDate,
      firstClockIn: _firstClockInController.text,
      firstClockOut: _firstClockOutController.text,
      secondClockIn:
          _secondClockInController.text.isEmpty
              ? null
              : _secondClockInController.text,
      secondClockOut:
          _secondClockOutController.text.isEmpty
              ? null
              : _secondClockOutController.text,
      totalShiftMinutes: _totalShiftMinutes,
      anesthesiaMinutes: _anesthesiaMinutes,
      conferenceMinutes: _conferenceMinutes,
      dnpProjectMinutes: _dnpProjectMinutes,
      presentationMinutes: _presentationMinutes,
      isBoardPrepDay: _isBoardPrepDay,
      isCallExperience: _isCallExperience,
      notes: _notesController.text,
    );

    await _repository.addTimeLog(entry);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Widget _buildTimeInput(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: CupertinoColors.white, fontSize: 14),
        ),
        const SizedBox(height: 4),
        CupertinoTextField(
          controller: controller,
          enabled: enabled,
          placeholder: '00:00',
          keyboardType: TextInputType.datetime,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          style: const TextStyle(color: CupertinoColors.white),
          onChanged: (_) => _updateTotalTime(),
        ),
      ],
    );
  }

  Widget _buildMinutesInput(String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(color: CupertinoColors.white, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: CupertinoTextField(
            placeholder: '0',
            keyboardType: TextInputType.number,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            style: const TextStyle(color: CupertinoColors.white),
            controller: TextEditingController(text: value.toString()),
            onChanged: (value) => onChanged(int.tryParse(value) ?? 0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'Time Log for ${widget.selectedDate.toString().split(' ')[0]}',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTimeLog,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shift Time',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInput(
                          _firstClockInController,
                          '1st Clock IN',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeInput(
                          _firstClockOutController,
                          '1st Clock OUT',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInput(
                          _secondClockInController,
                          '2nd Clock IN',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeInput(
                          _secondClockOutController,
                          '2nd Clock OUT',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Shift Time: ${_repository.formatMinutesToHours(_totalShiftMinutes)}',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Other Time Activities',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMinutesInput(
                    'Anesthesia Time',
                    _anesthesiaMinutes,
                    (value) => setState(() => _anesthesiaMinutes = value),
                  ),
                  const SizedBox(height: 8),
                  _buildMinutesInput(
                    'Conference Time',
                    _conferenceMinutes,
                    (value) => setState(() => _conferenceMinutes = value),
                  ),
                  const SizedBox(height: 8),
                  _buildMinutesInput(
                    'DNP Project/Meeting',
                    _dnpProjectMinutes,
                    (value) => setState(() => _dnpProjectMinutes = value),
                  ),
                  const SizedBox(height: 8),
                  _buildMinutesInput(
                    'Professional Presentation',
                    _presentationMinutes,
                    (value) => setState(() => _presentationMinutes = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CupertinoSwitch(
                        value: _isBoardPrepDay,
                        onChanged:
                            (value) => setState(() => _isBoardPrepDay = value),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Board Prep Day',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CupertinoSwitch(
                        value: _isCallExperience,
                        onChanged:
                            (value) =>
                                setState(() => _isCallExperience = value),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Call Experience',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _notesController,
                    placeholder: 'Enter any time log notes...',
                    minLines: 3,
                    maxLines: 5,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstClockInController.dispose();
    _firstClockOutController.dispose();
    _secondClockInController.dispose();
    _secondClockOutController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
