import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../constants/ai_constants.dart';

class LocalOCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<Map<String, dynamic>>> scanReceipt(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    List<String> lines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        lines.add(line.text.toLowerCase().trim());
      }
    }

    return _matchProducts(lines);
  }

  List<Map<String, dynamic>> _matchProducts(List<String> lines) {
    List<Map<String, dynamic>> matches = [];
    Set<String> seenProducts = {};

    for (String line in lines) {
      final match = _matchSingleProduct(line);
      if (match != null && !seenProducts.contains(match['product'])) {
        matches.add(match);
        seenProducts.add(match['product']);
      }
    }

    return matches;
  }

  Map<String, dynamic>? _matchSingleProduct(String text) {
    if (text.isEmpty) return null;

    // 1. Exact match with TR map
    // Note: We need the full TR map from Python for better results
    // For now using the enToTr map keys reversed or similar logic
    
    // 2. Fuzzy match
    double bestScore = 0;
    String? bestProduct;
    String? bestProductTr;

    AIConstants.trToEn.forEach((tr, en) {
      double scoreTr = _calculateSimilarity(text, tr.toLowerCase());
      
      if (scoreTr > bestScore) {
        bestScore = scoreTr;
        bestProduct = en;
        bestProductTr = AIConstants.enToTr[en] ?? tr;
      }
    });

    if (bestScore >= 0.8) { // 80% threshold
      return {
        "product": bestProduct,
        "product_tr": bestProductTr,
        "confidence": bestScore,
        "source": text,
      };
    }

    return null;
  }

  // Simple Levenshtein distance based similarity
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int distance = _levenshteinDistance(s1, s2);
    int maxLen = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLen);
  }

  int _levenshteinDistance(String s1, String s2) {
    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[s2.length];
  }

  int _min3(int a, int b, int c) {
    int res = a < b ? a : b;
    return res < c ? res : c;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
