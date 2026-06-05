import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../features/my_fridge/data/model_labels.dart';
import '../../features/my_fridge/data/shelf_life_table.dart';

/// Cihaz-üstü fiş tarama. Google ML Kit ile metin çıkarır, satırları
/// `ModelLabels.trToEnProduct` sözlüğüyle eşleştirir.
///
/// Dönüş formatı `GeminiAIService.extractProductsFromReceipt` ile aynı:
/// `{product_tr, product, confidence, category, expiry_days}`.
class OcrReceiptService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<Map<String, dynamic>>> scanReceipt(File imageFile) async {
    final input = InputImage.fromFile(imageFile);
    final result = await _recognizer.processImage(input);

    final lines = <String>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        lines.add(line.text);
      }
    }

    final seenEn = <String>{};
    final matches = <Map<String, dynamic>>[];

    for (final raw in lines) {
      final normalized = _normalize(raw);
      if (normalized.isEmpty) continue;

      final match = _matchLine(normalized);
      if (match == null) continue;
      if (!seenEn.add(match.en)) continue;

      final category = ModelLabels.enToCategory[match.en];
      final filterKey = category != null
          ? ModelLabels.filterKeyFor(category)
          : 'filter_other';

      matches.add({
        'product': match.en,
        'product_tr': match.tr,
        'confidence': match.score,
        'category': filterKey,
        'expiry_days': ShelfLifeTable.defaultDaysFor(filterKey),
      });
    }

    return matches;
  }

  void dispose() {
    _recognizer.close();
  }

  // ─── Eşleştirme ─────────────────────────────────────────

  _MatchResult? _matchLine(String normalizedLine) {
    _MatchResult? best;

    for (final entry in ModelLabels.trToEnProduct.entries) {
      final keyword = _normalize(entry.key);
      if (keyword.isEmpty) continue;

      double score = 0;
      if (normalizedLine == keyword) {
        score = 1.0;
      } else if (_containsWord(normalizedLine, keyword)) {
        // Anahtar kelime tek başına eşleştiyse skor onun satıra oranı.
        score = (keyword.length / normalizedLine.length).clamp(0.4, 0.95);
      } else {
        continue;
      }

      if (best == null || score > best.score) {
        best = _MatchResult(
          en: entry.value,
          tr: entry.key,
          score: score,
        );
      }
    }

    return best;
  }

  bool _containsWord(String haystack, String needle) {
    final pattern = RegExp(r'(^|\s)' + RegExp.escape(needle) + r'(\s|$)');
    return pattern.hasMatch(haystack);
  }

  String _normalize(String input) {
    var s = input.toLowerCase().trim();
    // ML Kit Latin betiği TR diakritiklerini koruyabilir — TR_TO_EN sözlüğü
    // diakritikli yazıldığı için sadece sayıları ve fazla boşlukları temizle.
    s = s.replaceAll(RegExp(r'[0-9]+([.,][0-9]+)?'), ' ');
    s = s.replaceAll(RegExp(r'[^a-zçğıöşüâîû\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

class _MatchResult {
  final String en;
  final String tr;
  final double score;

  _MatchResult({required this.en, required this.tr, required this.score});
}
