class OCRService {
  // Simulate OCR processing and return dummy recognized text.
  Future<String> processImage(dynamic image) async {
    await Future.delayed(const Duration(seconds: 2));
    return "Detected Procedure from OCR";
  }
}
