import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fridge_item_model.dart';
import '../widgets/add_product_options_sheet.dart';
import '../widgets/empty_fridge_view.dart';
import '../widgets/fridge_item_card.dart';
import 'scan_product_page.dart';
import 'scan_receipt_page.dart';
import '../../../core/services/database_service.dart';

class MyFridgePage extends StatefulWidget {
  final Language lang;

  const MyFridgePage({super.key, required this.lang});

  @override
  State<MyFridgePage> createState() => _MyFridgePageState();
}

class _MyFridgePageState extends State<MyFridgePage> {
  List<FridgeItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseService().getItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _showAddProductOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AddProductOptionsSheet(
          lang: widget.lang,
          onCameraTap: () async {
            Navigator.pop(context);

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanProductPage(lang: widget.lang),
              ),
            );

            if (result != null && result is FridgeItemModel) {
              await DatabaseService().insertItem(result);
              _loadItems(); // Listeyi yenile

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppTexts.of("product_saved", widget.lang)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          onReceiptTap: () async {
            Navigator.pop(context);

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanReceiptPage(lang: widget.lang),
              ),
            );

            if (result == true) {
              _loadItems(); // Listeyi yenile
            }
          },
          onManualTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.of("manual_add_coming_soon", widget.lang)),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC), // Slate 50
            Color(0xFFF1F5F9), // Slate 100
            Color(0xFFEFF6FF), // Blue 50
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              AppTexts.of("my_fridge_title", lang),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.of("my_fridge_subtitle", lang),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _buildAddButton(lang),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_items.isEmpty)
              EmptyFridgeView(lang: lang)
            else
              ..._items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FridgeItemCard(item: item, lang: lang),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(Language lang) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: _showAddProductOptions,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.of("add_product", lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        lang == Language.tr ? "Kamera veya elle ekle" : "Add via camera or manually",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
