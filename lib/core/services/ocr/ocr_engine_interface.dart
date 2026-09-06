/// Isolated abstraction interface for OCR Scanning Engines
/// Allows swapping between Google ML Kit, Tesseract, or Cloud Vision APIs seamlessly.
abstract class OCREngineInterface {
  Future<Map<String, dynamic>> scanReceiptFromImagePath(String imagePath);
}
