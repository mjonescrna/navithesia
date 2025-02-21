import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';

class AddCasePage extends StatefulWidget {
  @override
  _AddCasePageState createState() => _AddCasePageState();
}

class _AddCasePageState extends State<AddCasePage> {
  final TextEditingController _caseController = TextEditingController();
  final OCRService _ocrService = OCRService();

  // In a production system, these suggestions would come from processing the Jaffe textbook
  // (via a prebuilt database or AI-based OCR/autocomplete service).
  List<String> _suggestions = ['Procedure A', 'Procedure B', 'Procedure C'];
  String _selectedSuggestion = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Case / Procedure'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Button to capture image from camera for OCR
              CupertinoButton(
                child: Text('Capture Case via Camera'),
                onPressed: () async {
                  // TODO: Integrate actual camera capture using a package like `camera` and process image.
                  // For now, simulate OCR processing.
                  String recognizedText = await _ocrService.processImage(null);
                  setState(() {
                    _caseController.text = recognizedText;
                  });
                },
              ),
              SizedBox(height: 16),
              // Text field with autocomplete functionality.
              CupertinoTextField(
                controller: _caseController,
                placeholder: 'Start typing case/procedure...',
                onChanged: (value) {
                  // TODO: Replace with real autocomplete logic using the AI or prebuilt database.
                },
              ),
              SizedBox(height: 16),
              // Display suggestion list.
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedSuggestion = _suggestions[index];
                          _caseController.text = _selectedSuggestion;
                        });
                      },
                      child: Text(
                        _suggestions[index],
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    );
                  },
                ),
              ),
              // Submit Button to add the case.
              CupertinoButton.filled(
                child: Text('Submit Case'),
                onPressed: () {
                  // TODO: Save the case, update logs and countdown as needed.
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
