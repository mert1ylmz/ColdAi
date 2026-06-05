import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fridge_item_model.dart';
import '../widgets/add_product_options_sheet.dart';
import '../widgets/empty_fridge_view.dart';
import '../widgets/fridge_item_card.dart';
import '../widgets/fridge_item_action_sheet.dart';
import 'scan_product_page.dart';
import 'scan_receipt_page.dart';
import 'manual_add_product_page.dart';
import '../../../core/services/database_service.dart';
import '../../activity/models/activity_log_model.dart';
import '../../activity/services/activity_log_service.dart';
import '../../pending/pages/leave_pending_page.dart';

class MyFridgePage extends StatefulWidget {
  final Language lang;

  const MyFridgePage({super.key, required this.lang});

  @override
  State<MyFridgePage> createState() => _MyFridgePageState();
}

class _MyFridgePageState extends State<MyFridgePage> {
  List<FridgeItemModel> _items = [];
  bool _isLoading = true;
  String _selectedFilter = 'filter_all';

  static const List<String> _filterKeys = [
    'filter_all',
    'filter_fruit',
    'filter_vegetable',
    'filter_dairy',
    'filter_meat',
    'filter_beverage',
    'filter_packaged',
    'filter_other',
  ];

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

  void _showItemActions(FridgeItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FridgeItemActionSheet(
        item: item,
        lang: widget.lang,
        onSelected: (action) => _handleItemAction(item, action),
      ),
    );
  }

  Future<void> _handleItemAction(
    FridgeItemModel item,
    FridgeItemAction action,
  ) async {
    final lang = widget.lang;
    final tr = lang == Language.tr;
    switch (action) {
      case FridgeItemAction.consumeAll:
        await DatabaseService().deleteItem(item.id);
        await ActivityLogService.instance.log(
          itemId: item.id,
          itemName: item.name,
          action: ActivityAction.consumed,
          quantity: item.quantity.isEmpty ? null : item.quantity,
        );
        _toast(tr ? "Tüketildi olarak kaydedildi" : "Marked as consumed",
            AppColors.success);
        break;

      case FridgeItemAction.consumePartial:
        final newQty = await _askQuantity(item);
        if (newQty == null) return;
        if (newQty.trim().isEmpty) {
          await DatabaseService().deleteItem(item.id);
          await ActivityLogService.instance.log(
            itemId: item.id,
            itemName: item.name,
            action: ActivityAction.consumed,
          );
        } else {
          final updated = item.copyWith(quantity: newQty.trim());
          await DatabaseService().updateItem(updated);
          await ActivityLogService.instance.log(
            itemId: item.id,
            itemName: item.name,
            action: ActivityAction.partiallyConsumed,
            quantity: newQty.trim(),
          );
        }
        _toast(tr ? "Miktar güncellendi" : "Quantity updated", AppColors.primary);
        break;

      case FridgeItemAction.wasted:
        await DatabaseService().deleteItem(item.id);
        await ActivityLogService.instance.log(
          itemId: item.id,
          itemName: item.name,
          action: ActivityAction.wasted,
          quantity: item.quantity.isEmpty ? null : item.quantity,
        );
        _toast(tr ? "Atıldı olarak kaydedildi" : "Marked as wasted",
            AppColors.error);
        break;

      case FridgeItemAction.share:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeavePendingPage(lang: lang, source: item),
          ),
        );
        if (result != null) {
          await DatabaseService().deleteItem(item.id);
          await ActivityLogService.instance.log(
            itemId: item.id,
            itemName: item.name,
            action: ActivityAction.shared,
          );
          _toast(
            tr ? "Askıya bırakıldı" : "Shared (pending)",
            const Color(0xFF8B5CF6),
          );
        }
        break;

      case FridgeItemAction.edit:
        _toast(tr ? "Düzenleme yakında" : "Edit coming soon", AppColors.primary);
        break;

      case FridgeItemAction.delete:
        await DatabaseService().deleteItem(item.id);
        await ActivityLogService.instance.log(
          itemId: item.id,
          itemName: item.name,
          action: ActivityAction.deleted,
        );
        _toast(tr ? "Silindi" : "Deleted", AppColors.textMuted);
        break;
    }
    _loadItems();
  }

  Future<String?> _askQuantity(FridgeItemModel item) async {
    final tr = widget.lang == Language.tr;
    final controller = TextEditingController(text: item.quantity);
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr ? "Yeni miktar" : "New quantity"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: tr ? "Örn: 250 g" : "e.g. 250 g",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(tr ? "Vazgeç" : "Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: Text(tr ? "Kaydet" : "Save"),
          ),
        ],
      ),
    );
  }

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<FridgeItemModel> get _filteredItems {
    if (_selectedFilter == 'filter_all') return _items;
    final filterText = AppTexts.of(_selectedFilter, widget.lang);
    return _items.where((item) =>
      item.category.toLowerCase() == filterText.toLowerCase()
    ).toList();
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
              await ActivityLogService.instance.log(
                itemId: result.id,
                itemName: result.name,
                action: ActivityAction.added,
                quantity: result.quantity.isEmpty ? null : result.quantity,
              );
              _loadItems();

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
              _loadItems();
            }
          },
          onManualTap: () async {
            Navigator.pop(context);

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManualAddProductPage(lang: widget.lang),
              ),
            );

            if (result != null && result is FridgeItemModel) {
              await DatabaseService().insertItem(result);
              await ActivityLogService.instance.log(
                itemId: result.id,
                itemName: result.name,
                action: ActivityAction.added,
                quantity: result.quantity.isEmpty ? null : result.quantity,
              );
              _loadItems();

              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(AppTexts.of("product_saved", widget.lang)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
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
            const SizedBox(height: 24),
            _buildAddButton(lang),
            const SizedBox(height: 24),

            // Category Filter Chips
            _buildFilterChips(lang),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_items.isEmpty)
              EmptyFridgeView(lang: lang)
            else if (_filteredItems.isEmpty)
              _buildFilterEmptyState(lang)
            else
              ..._filteredItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FridgeItemCard(
                    item: item,
                    lang: lang,
                    onTap: () => _showItemActions(item),
                    onLongPress: () => _showItemActions(item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(Language lang) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final key = _filterKeys[index];
          final isSelected = _selectedFilter == key;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = key;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  AppTexts.of(key, lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterEmptyState(Language lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
            ),
            child: const Icon(
              Icons.filter_list_off_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppTexts.of("filter_empty", lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppTexts.of("filter_empty_subtitle", lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                        AppTexts.of("add_via_camera_or_manual", lang),
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
