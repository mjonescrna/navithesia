import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Initialize result map
      Map<String, dynamic> result = {
        'procedure': '',
        'age': null,
        'asa': '',
        'anatomicalLocation': '',
        'anesthesiaType': '',
        'duration': 0,
        'techniques': <String>[],
      };

      // Process each block of text
      for (TextBlock block in recognizedText.blocks) {
        String text = block.text.toLowerCase();

        // Look for procedure name
        if (text.contains('procedure') || text.contains('surgery')) {
          result['procedure'] = _extractProcedure(block.text);
        }

        // Look for age
        if (text.contains('age') || text.contains('yo')) {
          result['age'] = _extractAge(block.text);
        }

        // Look for ASA status
        if (text.contains('asa')) {
          result['asa'] = _extractASA(block.text);
        }

        // Look for anatomical location
        if (text.contains('location') || text.contains('site')) {
          result['anatomicalLocation'] = _extractLocation(block.text);
        }

        // Look for anesthesia type
        if (text.contains('anesthesia') || text.contains('anesthetic')) {
          result['anesthesiaType'] = _extractAnesthesiaType(block.text);
        }

        // Look for duration
        if (text.contains('duration') || text.contains('time')) {
          result['duration'] = _extractDuration(block.text);
        }

        // Look for techniques
        if (text.contains('technique') || text.contains('method')) {
          result['techniques'].addAll(_extractTechniques(block.text));
        }
      }

      return result;
    } catch (e) {
      print('OCR Error: $e');
      return {};
    } finally {
      _textRecognizer.close();
    }
  }

  String _extractProcedure(String text) {
    // Remove common prefixes and clean up the text
    final cleanText =
        text
            .replaceAll(
              RegExp(r'procedure:|surgery:', caseSensitive: false),
              '',
            )
            .trim();
    return cleanText;
  }

  int? _extractAge(String text) {
    // Look for numbers followed by y, yo, year, years
    final ageRegex = RegExp(r'(\d+)\s*(?:y|yo|year|years)');
    final match = ageRegex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  String _extractASA(String text) {
    // Look for ASA classification
    final asaRegex = RegExp(r'ASA\s*[I|V|X]+(?:-E)?', caseSensitive: false);
    final match = asaRegex.firstMatch(text);
    return match?.group(0)?.toUpperCase() ?? '';
  }

  String _extractLocation(String text) {
    // Remove common prefixes and clean up
    return text
        .replaceAll(RegExp(r'location:|site:', caseSensitive: false), '')
        .trim();
  }

  String _extractAnesthesiaType(String text) {
    // Remove common prefixes and clean up
    return text
        .replaceAll(
          RegExp(r'anesthesia:|anesthetic:', caseSensitive: false),
          '',
        )
        .trim();
  }

  int _extractDuration(String text) {
    // Look for numbers followed by min, minutes, hr, hours
    final durationRegex = RegExp(r'(\d+)\s*(?:min|minutes|hr|hours)');
    final match = durationRegex.firstMatch(text);
    if (match != null) {
      final value = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (text.contains('hr') || text.contains('hours')) {
        return value * 60; // Convert hours to minutes
      }
      return value;
    }
    return 0;
  }

  List<String> _extractTechniques(String text) {
    // Split by common delimiters and clean up
    return text
        .replaceAll(RegExp(r'techniques:|methods:', caseSensitive: false), '')
        .split(RegExp(r'[,;]'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}
