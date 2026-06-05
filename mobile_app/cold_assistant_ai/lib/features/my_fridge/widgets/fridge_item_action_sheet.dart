import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fridge_item_model.dart';

enum FridgeItemAction { consumeAll, consumePartial, wasted, share, edit, delete }

class FridgeItemActionSheet extends StatelessWidget {
  final FridgeItemModel item;
  final Language lang;
  final ValueChanged<FridgeItemAction> onSelected;

  const FridgeItemActionSheet({
    super.key,
    required this.item,
    required this.lang,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tr = lang == Language.tr;
    final options = <(FridgeItemAction, IconData, Color, String, String)>[
      (
        FridgeItemAction.consumeAll,
        Icons.restaurant_rounded,
        AppColors.primary,
        tr ? "Tamamını tükettim" : "Consumed all",
        tr ? "Ürünü dolaptan tamamen çıkar" : "Remove from fridge",
      ),
      (
        FridgeItemAction.consumePartial,
        Icons.remove_circle_rounded,
        const Color(0xFF0EA5E9),
        tr ? "Bir kısmını tükettim" : "Partially consumed",
        tr ? "Miktarı güncelle" : "Update quantity",
      ),
      (
        FridgeItemAction.wasted,
        Icons.delete_rounded,
        AppColors.error,
        tr ? "Bozuldu / Attım" : "Wasted",
        tr ? "Çöpe gitti, log'a kaydet" : "Discarded, mark in log",
      ),
      (
        FridgeItemAction.share,
        Icons.volunteer_activism_rounded,
        const Color(0xFF8B5CF6),
        tr ? "Askıya bırak" : "Share (pending)",
        tr ? "İhtiyacı olana bağışla" : "Donate to someone in need",
      ),
      (
        FridgeItemAction.edit,
        Icons.edit_rounded,
        const Color(0xFFCA8A04),
        tr ? "Düzenle" : "Edit",
        tr ? "Ürün bilgilerini güncelle" : "Update product details",
      ),
      (
        FridgeItemAction.delete,
        Icons.delete_outline_rounded,
        AppColors.textMuted,
        tr ? "Sessizce sil" : "Silent delete",
        tr ? "Log'a yazmadan kaldır" : "Remove without logging",
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr ? "Bu ürün için bir aksiyon seç" : "Pick an action for this item",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((o) => _tile(context, o)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    (FridgeItemAction, IconData, Color, String, String) o,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            onSelected(o.$1);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: o.$3.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(o.$2, color: o.$3, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.$4,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        o.$5,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
