import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/pending_item_model.dart';

class PendingCard extends StatelessWidget {
  final PendingItemModel item;
  final Language lang;
  final VoidCallback? onTap;

  const PendingCard({
    super.key,
    required this.item,
    required this.lang,
    this.onTap,
  });

  ({Color color, String label, IconData icon}) _statusVisual(bool tr) {
    switch (item.status) {
      case PendingStatus.active:
        return (
          color: const Color(0xFF8B5CF6),
          label: tr ? "Aktif" : "Active",
          icon: Icons.bolt_rounded,
        );
      case PendingStatus.requested:
        return (
          color: const Color(0xFFCA8A04),
          label: tr ? "Talep var" : "Requested",
          icon: Icons.front_hand_rounded,
        );
      case PendingStatus.completed:
        return (
          color: AppColors.success,
          label: tr ? "Tamamlandı" : "Completed",
          icon: Icons.check_circle_rounded,
        );
      case PendingStatus.cancelled:
        return (
          color: AppColors.textMuted,
          label: tr ? "İptal" : "Cancelled",
          icon: Icons.close_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = lang == Language.tr;
    final s = _statusVisual(tr);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        if (item.category.isNotEmpty)
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, color: s.color, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: s.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.quantity.isNotEmpty) ...[
                    _chip(Icons.shopping_basket_outlined, item.quantity),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _chip(
                      Icons.location_on_rounded,
                      item.locationLabel,
                    ),
                  ),
                ],
              ),
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  item.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fieldFill.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
