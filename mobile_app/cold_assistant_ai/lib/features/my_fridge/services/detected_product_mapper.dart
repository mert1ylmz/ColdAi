import '../../../core/localization/language.dart';
import '../models/detected_product_model.dart';

/// Maps a Gemini detection result directly to a DetectedProductModel.
/// No longer relies on a hardcoded product catalog — Gemini provides all info.
DetectedProductModel mapDetectionToProduct({
  required String label,
  required Language lang,
  String? category,
  int? expiryDays,
}) {
  final now = DateTime.now();

  return DetectedProductModel(
    name: label,
    category: category ?? 'Diğer',
    createdAt: now,
    expiryDate: now.add(Duration(days: expiryDays ?? 7)),
  );
}
