import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
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
  State<DetectedProductEditPage> createState() => _DetectedProductEditPageState();
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
    categoryController = TextEditingController(text: widget.detectedProduct.category);
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppTexts.of("edit_detected_product", lang),
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(lang == Language.tr ? "Ürün Bilgileri" : "Product Details"),
                  const SizedBox(height: 20),
                  _buildInput(
                    label: AppTexts.of("product_name", lang),
                    controller: nameController,
                    icon: Icons.shopping_bag_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    label: AppTexts.of("category", lang),
                    controller: categoryController,
                    icon: Icons.category_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    label: AppTexts.of("quantity", lang),
                    controller: quantityController,
                    icon: Icons.numbers_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    label: AppTexts.of("note", lang),
                    controller: noteController,
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(AppTexts.of("expiry_date", lang)),
                  const SizedBox(height: 12),
                  _buildExpiryPicker(lang),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButtons(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildExpiryPicker(Language lang) {
    return InkWell(
      onTap: _pickExpiryDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.fieldFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${expiryDate.day}.${expiryDate.month}.${expiryDate.year}",
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Language lang) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                foregroundColor: AppColors.text,
              ),
              child: Text(AppTexts.of("cancel", lang), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(AppTexts.of("save", lang), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }
}
