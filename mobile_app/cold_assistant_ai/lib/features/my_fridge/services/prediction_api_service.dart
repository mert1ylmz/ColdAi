import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/constants/ai_constants.dart';
import '../data/model_labels.dart';
import '../data/shelf_life_table.dart';

/// ColdAI Python backend ile konuşan ürün tanıma servisi.
///
/// Backend: `POST {baseUrl}/api/v1/predict` (multipart/form-data, field: `image`).
/// Yanıt şeması `backend.api.schemas.PredictResponse` ile aynıdır:
///   { success, category, product, product_tr, confidence, is_known, message }
class PredictionApiService {
  PredictionApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AIConstants.backendBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>?> detectProduct(File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/predict');
      final mimeType =
          lookupMimeType(imageFile.path, headerBytes: null) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeParts.first, mimeParts.last),
        ));

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('PREDICT API ${response.statusCode}: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      // Düşük güven / bilinmeyen ürün → UI için açık mesaj.
      if (body['is_known'] != true) {
        return {
          'label': body['message'] ?? 'Bilinmiyor',
          'confidence': (body['confidence'] as num?)?.toDouble() ?? 0.0,
        };
      }

      final productEn = body['product'] as String?;
      final productTr = body['product_tr'] as String?;
      final categoryRaw = body['category'] as String?;
      final filterKey = categoryRaw != null
          ? ModelLabels.filterKeyFor(categoryRaw)
          : 'filter_other';

      return {
        'label': productTr ?? productEn ?? 'Bilinmiyor',
        'confidence': (body['confidence'] as num?)?.toDouble() ?? 0.0,
        'category': filterKey,
        'expiry_days': ShelfLifeTable.defaultDaysFor(filterKey),
      };
    } catch (e, st) {
      // ignore: avoid_print
      print('PREDICT API ERROR: $e\n$st');
      return null;
    }
  }

  void dispose() => _client.close();
}
