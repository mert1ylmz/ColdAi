import 'dart:io';
import '../../../core/services/local_ai_service.dart';

class ProductDetectionService {
  final _localAIService = LocalAIService();

  Future<Map<String, dynamic>?> detectProduct(File image) async {
    try {
      final result = await _localAIService.predict(image);

      if (result["success"] == true) {
        return {
          "label": result["product_tr"] ?? result["product"] ?? "Bilinmiyor",
          "confidence": result["confidence"] ?? 0.0,
        };
      }

      return {
        "label": result["message"] ?? "Bilinmiyor",
        "confidence": 0.0,
      };
    } catch (e) {
      print("LOCAL AI ERROR: $e");
      return {
        "label": "Hata oluştu",
        "confidence": 0.0,
        "error": e.toString(),
      };
    }
  }
}
