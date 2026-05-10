import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fridge_item_model.dart';

class ManualAddProductPage extends StatefulWidget {
  final Language lang;

  const ManualAddProductPage({super.key, required this.lang});

  @override
  State<ManualAddProductPage> createState() => _ManualAddProductPageState();
}

class _ManualAddProductPageState extends State<ManualAddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = '';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  static const List<String> _categoryKeys = [
    'filter_fruit',
    'filter_vegetable',
    'filter_dairy',
    'filter_meat',
    'filter_beverage',
    'filter_packaged',
    'filter_other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
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
        _expiryDate = selected;
      });
    }
  }

  void _saveProduct() {
    final lang = widget.lang;
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.of("fill_all_fields", lang)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final category = _selectedCategory.isNotEmpty
        ? AppTexts.of(_selectedCategory, lang)
        : AppTexts.of("filter_other", lang);

    final item = FridgeItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      quantity: _quantityController.text.trim(),
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
      expiryDate: _expiryDate,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          AppTexts.of("manual_add_title", lang),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
              Color(0xFFF0F9FF),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              AppTexts.of("manual_add_subtitle", lang),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Product Card Style Form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 2),
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
                  // Product Icon & Title area
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTexts.of("manual_product_details", lang),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTexts.of("manual_add_subtitle", lang),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Product Name
                  _buildInput(
                    label: AppTexts.of("product_name", lang),
                    controller: _nameController,
                    icon: Icons.shopping_bag_rounded,
                    hint: AppTexts.of("manual_product_name_hint", lang),
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  _buildCategorySelector(lang),
                  const SizedBox(height: 16),

                  // Quantity
                  _buildInput(
                    label: AppTexts.of("quantity", lang),
                    controller: _quantityController,
                    icon: Icons.numbers_rounded,
                    hint: AppTexts.of("manual_quantity_hint", lang),
                  ),
                  const SizedBox(height: 16),

                  // Note
                  _buildInput(
                    label: AppTexts.of("note", lang),
                    controller: _noteController,
                    icon: Icons.notes_rounded,
                    hint: AppTexts.of("manual_note_hint", lang),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Expiry Date
                  Text(
                    AppTexts.of("expiry_date", lang),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildExpiryPicker(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(lang),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted.withOpacity(0.5),
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
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

  Widget _buildCategorySelector(Language lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              AppTexts.of("category", lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categoryKeys.map((key) {
            final isSelected = _selectedCategory == key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = isSelected ? '' : key;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  AppTexts.of(key, lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpiryPicker() {
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
                "${_expiryDate.day.toString().padLeft(2, '0')}.${_expiryDate.month.toString().padLeft(2, '0')}.${_expiryDate.year}",
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                foregroundColor: AppColors.text,
              ),
              child: Text(
                AppTexts.of("cancel", lang),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: Text(
                AppTexts.of("save", lang),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
