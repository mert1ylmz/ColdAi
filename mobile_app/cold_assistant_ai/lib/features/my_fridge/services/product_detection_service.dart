import 'dart:io';
import '../../../core/services/gemini_ai_service.dart';

class ProductDetectionService {
  final _geminiAIService = GeminiAIService();

  Future<Map<String, dynamic>?> detectProduct(File image) async {
    try {
      final result = await _geminiAIService.detectProduct(image);

      if (result != null) {
        return {
          "label": result["product_tr"] ?? result["product"] ?? "Bilinmiyor",
          "confidence": result["confidence"] ?? 0.0,
          "category": result["category"],
          "expiry_days": result["expiry_days"] ?? 7,
        };
      }

      return {
        "label": "Bilinmiyor",
        "confidence": 0.0,
      };
    } catch (e) {
      print("GEMINI AI ERROR: $e");
      return {
        "label": "Hata oluştu",
        "confidence": 0.0,
        "error": e.toString(),
      };
    }
  }
}
