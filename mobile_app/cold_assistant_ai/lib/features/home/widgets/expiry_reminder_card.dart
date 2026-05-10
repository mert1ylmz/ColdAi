import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/database_service.dart';
import '../../my_fridge/models/fridge_item_model.dart';

/// Expiry reminder card that cycles through products approaching expiry.
class ExpiryReminderCard extends StatefulWidget {
  final Language lang;

  const ExpiryReminderCard({super.key, required this.lang});

  @override
  State<ExpiryReminderCard> createState() => _ExpiryReminderCardState();
}

class _ExpiryReminderCardState extends State<ExpiryReminderCard> {
  List<_ExpiryAlert> _alerts = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    final items = await DatabaseService().getItems();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<_ExpiryAlert> alerts = [];

    for (final item in items) {
      final expiryDay = DateTime(
        item.expiryDate.year,
        item.expiryDate.month,
        item.expiryDate.day,
      );
      final diff = expiryDay.difference(today).inDays;

      if (diff < 0) {
        // Expired
        alerts.add(_ExpiryAlert(
          item: item,
          message: AppTexts.of("reminder_expired", widget.lang)
              .replaceAll("{name}", item.name),
          daysLeft: diff,
          type: _AlertType.expired,
        ));
      } else if (diff == 0) {
        // Today
        alerts.add(_ExpiryAlert(
          item: item,
          message: AppTexts.of("reminder_consume_today", widget.lang)
              .replaceAll("{name}", item.name),
          daysLeft: 0,
          type: _AlertType.today,
        ));
      } else if (diff <= 3) {
        // Approaching (within 3 days)
        alerts.add(_ExpiryAlert(
          item: item,
          message: AppTexts.of("reminder_expiry_approaching", widget.lang)
              .replaceAll("{name}", item.name),
          daysLeft: diff,
          type: _AlertType.approaching,
        ));
      }
    }

    // Sort: expired first, then today, then approaching
    alerts.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });

      if (alerts.length > 1) {
        _timer = Timer.periodic(const Duration(seconds: 4), (_) {
          if (mounted && _alerts.isNotEmpty) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % _alerts.length;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppTexts.of("reminders", lang),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_alerts.isEmpty)
            _buildEmptyState(lang)
          else
            _buildAlertContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Language lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppTexts.of("reminder_no_expiry", lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertContent() {
    if (_alerts.isEmpty) return const SizedBox.shrink();

    final alert = _alerts[_currentIndex];
    final lang = widget.lang;

    Color alertColor;
    IconData alertIcon;
    switch (alert.type) {
      case _AlertType.expired:
        alertColor = AppColors.error;
        alertIcon = Icons.error_rounded;
        break;
      case _AlertType.today:
        alertColor = AppColors.warning;
        alertIcon = Icons.warning_amber_rounded;
        break;
      case _AlertType.approaching:
        alertColor = AppColors.accent;
        alertIcon = Icons.schedule_rounded;
        break;
    }

    String daysText;
    if (alert.daysLeft < 0) {
      daysText = AppTexts.of("reminder_expired", lang).replaceAll("{name}", "");
    } else if (alert.daysLeft == 0) {
      daysText = AppTexts.of("reminder_today", lang);
    } else {
      daysText = AppTexts.of("reminder_days_left", lang)
          .replaceAll("{days}", alert.daysLeft.toString());
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('alert_$_currentIndex'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alertColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: alertColor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(alertIcon, color: alertColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: alertColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_alerts.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_alerts.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: alertColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _AlertType { expired, today, approaching }

class _ExpiryAlert {
  final FridgeItemModel item;
  final String message;
  final int daysLeft;
  final _AlertType type;

  const _ExpiryAlert({
    required this.item,
    required this.message,
    required this.daysLeft,
    required this.type,
  });
}
