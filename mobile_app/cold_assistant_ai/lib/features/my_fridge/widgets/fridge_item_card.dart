import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fridge_item_model.dart';

class FridgeItemCard extends StatelessWidget {
  final FridgeItemModel item;
  final Language lang;

  const FridgeItemCard({super.key, required this.item, required this.lang});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = item.expiryDate.isBefore(DateTime.now());

    return Container(
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
                child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 26),
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
                    Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoChip(Icons.shopping_basket_outlined, item.quantity.isEmpty ? "-" : item.quantity),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.calendar_today_outlined, _formatDate(item.expiryDate), 
                  isAlert: isExpired),
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
                  const Icon(Icons.sticky_note_2_outlined, size: 18, color: AppColors.textMuted),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isAlert ? AppColors.error.withOpacity(0.05) : AppColors.fieldFill.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAlert ? AppColors.error.withOpacity(0.1) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isAlert ? AppColors.error : AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isAlert ? AppColors.error : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
