import 'ocr_engine_interface.dart';

/// Service implementing OCREngineInterface for receipt scanning
class OCRService implements OCREngineInterface {
  @override
  Future<Map<String, dynamic>> scanReceiptFromImagePath(String imagePath) async {
    throw UnimplementedError('OCRService.scanReceiptFromImagePath is an infrastructure boundary for future implementation.');
  }
}
