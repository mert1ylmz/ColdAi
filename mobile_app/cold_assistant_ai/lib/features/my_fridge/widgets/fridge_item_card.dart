import 'package:flutter/material.dart';

import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fridge_item_model.dart';

class FridgeItemCard extends StatelessWidget {
  final FridgeItemModel item;
  final Language lang;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FridgeItemCard({
    super.key,
    required this.item,
    required this.lang,
    this.onTap,
    this.onLongPress,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  ({Color color, String label, IconData icon}) _expiryBadge(Language lang) {
    final d = item.daysToExpiry;
    final level = item.expiryLevel;
    final tr = lang == Language.tr;
    switch (level) {
      case ExpiryLevel.expired:
        return (
          color: AppColors.error,
          label: tr ? "Süresi geçti" : "Expired",
          icon: Icons.error_rounded,
        );
      case ExpiryLevel.critical:
        return (
          color: const Color(0xFFEA580C),
          label: d == 0
              ? (tr ? "Bugün" : "Today")
              : (tr ? "$d gün kaldı" : "$d days left"),
          icon: Icons.warning_amber_rounded,
        );
      case ExpiryLevel.soon:
        return (
          color: const Color(0xFFCA8A04),
          label: tr ? "$d gün kaldı" : "$d days left",
          icon: Icons.schedule_rounded,
        );
      case ExpiryLevel.fresh:
        return (
          color: AppColors.success,
          label: tr ? "$d gün kaldı" : "$d days left",
          icon: Icons.check_circle_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _expiryBadge(lang);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
                      Icons.inventory_2_rounded,
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
                          item.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.status == FreshnessStatus.opened) ...[
                              const SizedBox(width: 8),
                              _statusChip(
                                lang == Language.tr ? "Açılmış" : "Opened",
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _expiryBadgeWidget(badge),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.shopping_basket_outlined,
                    item.quantity.isEmpty ? "-" : item.quantity,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.calendar_today_outlined,
                    _formatDate(item.expiryDate),
                    accent: badge.color,
                  ),
                ],
              ),
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.note,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFFB45309),
        ),
      ),
    );
  }

  Widget _expiryBadgeWidget(({Color color, String label, IconData icon}) b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: b.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: b.color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(b.icon, color: b.color, size: 14),
          const SizedBox(width: 4),
          Text(
            b.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: b.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? accent}) {
    final color = accent ?? AppColors.textMuted;
    final hasAccent = accent != null;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: hasAccent
              ? color.withOpacity(0.05)
              : AppColors.fieldFill.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasAccent ? color.withOpacity(0.15) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: hasAccent ? color : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
