import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../models/fridge_item_model.dart';
import '../widgets/add_product_options_sheet.dart';
import '../widgets/empty_fridge_view.dart';
import '../widgets/fridge_item_card.dart';
import 'scan_product_page.dart';
import 'scan_product_page.dart';

class MyFridgePage extends StatefulWidget {
  final Language lang;

  const MyFridgePage({super.key, required this.lang});

  @override
  State<MyFridgePage> createState() => _MyFridgePageState();
}

class _MyFridgePageState extends State<MyFridgePage> {
  final List<FridgeItemModel> _items = [
    FridgeItemModel(
      id: '1',
      name: 'Süt',
      category: 'Dairy',
      quantity: '1 L',
      note: 'Laktozsuz',
      createdAt: DateTime(2026, 4, 19),
      expiryDate: DateTime(2026, 4, 24),
    ),
    FridgeItemModel(
      id: '2',
      name: 'Domates',
      category: 'Vegetable',
      quantity: '4',
      note: '',
      createdAt: DateTime(2026, 4, 18),
      expiryDate: DateTime(2026, 4, 25),
    ),
  ];

  void _showAddProductOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8FBFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
              setState(() {
                _items.add(result);
              });

              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(AppTexts.of("product_saved", widget.lang)),
                ),
              );
            }
          },
          onManualTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTexts.of("manual_add_coming_soon", widget.lang),
                ),
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
          colors: [Color(0xFFEAF4FF), Color(0xFFF8FBFF), Color(0xFFEFFAF6)],
        ),
      ),
      child: SafeArea(
        top: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            Text(
              AppTexts.of("my_fridge_title", lang),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.of("my_fridge_subtitle", lang),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: _showAddProductOptions,
              borderRadius: BorderRadius.circular(26),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E40AF), // daha koyu mavi
                      Color(0xFF1D4ED8), // güçlü mavi
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withOpacity(0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4ED8), // KOYU ARKA PLAN
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppTexts.of("add_product", lang),
                        style: const TextStyle(
                          color: const Color(0xFF1D4ED8),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (_items.isEmpty)
              EmptyFridgeView(lang: lang)
            else
              ..._items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FridgeItemCard(item: item, lang: lang),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
