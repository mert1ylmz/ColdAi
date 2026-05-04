import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ProductDetectionService {
  static const String baseUrl = "http://192.168.1.132:8000";

  Future<Map<String, dynamic>?> detectProduct(File image) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/predict');

      print("API URL: $uri");
      print("IMAGE PATH: ${image.path}");

      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      print("STATUS CODE: ${streamedResponse.statusCode}");
      print("RESPONSE BODY: $responseBody");

      if (streamedResponse.statusCode == 200) {
        final jsonData = jsonDecode(responseBody);

        return {
          "label":
              jsonData["product_tr"] ?? jsonData["product"] ?? "Bilinmiyor",
          "confidence": jsonData["confidence"] ?? 0.0,
        };
      }

      return {
        "label": "API hata verdi",
        "confidence": 0.0,
        "error": responseBody,
      };
    } catch (e) {
      print("API ERROR DETAIL: $e");

      return {
        "label": "Bağlantı hatası",
        "confidence": 0.0,
        "error": e.toString(),
      };
    }
  }
}
