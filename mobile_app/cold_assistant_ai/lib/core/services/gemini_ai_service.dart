import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/ai_constants.dart';

class GeminiAIService {
  static final GeminiAIService _instance = GeminiAIService._internal();
  factory GeminiAIService() => _instance;
  GeminiAIService._internal();

  GenerativeModel? _visionModel;

  GenerativeModel get visionModel {
    _visionModel ??= GenerativeModel(
      model: AIConstants.geminiModel,
      apiKey: AIConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    return _visionModel!;
  }

  /// Detects a single product from an image.
  /// Gemini freely identifies whatever it sees — no hardcoded category list.
  Future<Map<String, dynamic>?> detectProduct(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart("""
Bu görseldeki yiyecek veya market ürününü tanımla. 
Eğer ürün paketli bir gıdasa (makarna, fasulye, bisküvi vb.), sadece 'paketli gıda' demekle kalma, ne olduğunu da tam olarak belirt (örn: "Filiz Burgu Makarna" veya "Kuru Fasulye").

Aşağıdaki JSON formatında yanıt ver:
{
  "product": "Ürünün İngilizce adı",
  "product_tr": "Ürünün Türkçe adı (Örn: Domates, Elma, Çubuk Makarna, Siyah Mercimek)",
  "category": "Ürünün kategorisi (Türkçe, örn: Meyve, Sebze, Süt Ürünü, İçecek, Atıştırmalık, Baklagil, Tahıl, Et/Balık, Dondurulmuş, Baharat, Konserve, Temizlik, Diğer)",
  "confidence": 0.95,
  "expiry_days": 7
}

Kurallar:
- "category" alanı ürüne en uygun kategoriyi serbestçe belirle.
- "product_tr" alanı ürünün ne olduğunu net bir şekilde ifade etsin.
- "expiry_days" buzdolabında tahmini raf ömrünü gün olarak belirt.
- "confidence" tanıma güvenini 0-1 arası belirt.
- Eğer görselde yiyecek/market ürünü yoksa: {"product": null, "product_tr": null, "category": null, "confidence": 0, "expiry_days": 0}
"""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await visionModel.generateContent(content);
      final responseText = response.text;

      if (responseText == null) return null;

      return jsonDecode(responseText) as Map<String, dynamic>;
    } catch (e) {
      print("Gemini Vision Error: $e");
      return null;
    }
  }

  /// Extracts multiple products from a grocery receipt image.
  Future<List<Map<String, dynamic>>> extractProductsFromReceipt(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart("""
Bu bir market fişi/alışveriş fişi görseli. Fişteki tüm yiyecek ve market ürünlerini listele.
Yiyecek olmayan kalemleri (poşet, indirim vb.) atla.
Paketli gıdalar için ürünün ne olduğunu (makarna, nohut, mercimek vb.) açıkça belirt.

Aşağıdaki JSON array formatında yanıt ver:
[
  {
    "product": "İngilizce ürün adı",
    "product_tr": "Türkçe ürün adı (Örn: Domates, Salatalık, Pilavlık Pirinç, Yarım Yağlı Süt)",
    "category": "Kategori (Türkçe)",
    "confidence": 1.0,
    "expiry_days": 7
  }
]

Kurallar:
- Her ürün için en uygun kategoriyi serbestçe belirle (Meyve, Sebze, Süt Ürünü, İçecek, Atıştırmalık, Baklagil, Tahıl, Et/Balık, Dondurulmuş, Baharat, Konserve, Temizlik, Diğer vb.).
- "expiry_days" buzdolabında tahmini raf ömrünü gün olarak belirt.
- Fişte ürün bulunamazsa boş array dön: []
"""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await visionModel.generateContent(content);
      final responseText = response.text;

      if (responseText == null) return [];

      final List<dynamic> decoded = jsonDecode(responseText);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("Gemini Receipt Error: $e");
      return [];
    }
  }
}
