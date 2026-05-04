import '../../../core/localization/language.dart';
import '../data/product_catalog.dart';
import '../models/detected_product_model.dart';
import '../models/product_template_model.dart';

DetectedProductModel mapDetectionToProduct({
  required String label,
  required Language lang,
}) {
  final template = productCatalog.firstWhere(
    (e) => e.label == label,
    orElse: () => ProductTemplateModel(
      label: label,
      nameTr: label,
      nameEn: label,
      category: "Other",
      expiryDays: 3,
    ),
  );

  final now = DateTime.now();

  return DetectedProductModel(
    name: lang == Language.tr ? template.nameTr : template.nameEn,
    category: template.category,
    createdAt: now,
    expiryDate: now.add(Duration(days: template.expiryDays)),
  );
}
