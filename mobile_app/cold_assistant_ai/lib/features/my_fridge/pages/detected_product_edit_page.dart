import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../models/detected_product_model.dart';
import '../models/fridge_item_model.dart';

class DetectedProductEditPage extends StatefulWidget {
  final Language lang;
  final DetectedProductModel detectedProduct;

  const DetectedProductEditPage({
    super.key,
    required this.lang,
    required this.detectedProduct,
  });

  @override
  State<DetectedProductEditPage> createState() =>
      _DetectedProductEditPageState();
}

class _DetectedProductEditPageState extends State<DetectedProductEditPage> {
  late final TextEditingController nameController;
  late final TextEditingController categoryController;
  late final TextEditingController quantityController;
  late final TextEditingController noteController;

  late DateTime expiryDate;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.detectedProduct.name);
    categoryController = TextEditingController(
      text: widget.detectedProduct.category,
    );
    quantityController = TextEditingController(text: "1");
    noteController = TextEditingController();

    expiryDate = widget.detectedProduct.expiryDate;
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() {
        expiryDate = selected;
      });
    }
  }

  void _saveProduct() {
    final item = FridgeItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      category: categoryController.text.trim(),
      quantity: quantityController.text.trim(),
      note: noteController.text.trim(),
      createdAt: DateTime.now(),
      expiryDate: expiryDate,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: Text(AppTexts.of("edit_detected_product", lang)),
        backgroundColor: const Color(0xFFF8FBFF),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _input(
                  label: AppTexts.of("product_name", lang),
                  controller: nameController,
                  icon: Icons.shopping_bag_outlined,
                ),
                const SizedBox(height: 14),
                _input(
                  label: AppTexts.of("category", lang),
                  controller: categoryController,
                  icon: Icons.category_outlined,
                ),
                const SizedBox(height: 14),
                _input(
                  label: AppTexts.of("quantity", lang),
                  controller: quantityController,
                  icon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 14),
                _input(
                  label: AppTexts.of("note", lang),
                  controller: noteController,
                  icon: Icons.note_alt_outlined,
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickExpiryDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${AppTexts.of("expiry_date", lang)}: "
                            "${expiryDate.day}.${expiryDate.month}.${expiryDate.year}",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: Text(AppTexts.of("cancel", lang)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.check),
                  label: Text(AppTexts.of("save", lang)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
