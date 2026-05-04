import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../models/detected_product_model.dart';

class DetectedProductCard extends StatelessWidget {
  final DetectedProductModel product;
  final Language lang;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const DetectedProductCard({
    super.key,
    required this.product,
    required this.lang,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: product.name);
    final quantityController = TextEditingController();
    final noteController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppTexts.of("detected_product", lang)),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: AppTexts.of("product_name", lang),
            ),
          ),

          TextField(
            controller: quantityController,
            decoration: InputDecoration(
              labelText: AppTexts.of("quantity", lang),
            ),
          ),

          TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: AppTexts.of("note", lang)),
          ),

          Text(
            "${AppTexts.of("added_date", lang)}: ${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}",
          ),

          Text(
            "${AppTexts.of("expiry_date", lang)}: ${product.expiryDate.day}/${product.expiryDate.month}/${product.expiryDate.year}",
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSave,
                  child: Text(AppTexts.of("save", lang)),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text(AppTexts.of("cancel", lang)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
