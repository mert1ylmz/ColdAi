import 'dart:io';
import 'gemini_ai_service.dart';

class ReceiptRecognitionService {
  final _geminiAIService = GeminiAIService();

  Future<List<Map<String, dynamic>>> scanReceipt(File imageFile) async {
    return await _geminiAIService.extractProductsFromReceipt(imageFile);
  }

  void dispose() {
    // No-op for Gemini
  }
}
