import 'package:flutter/material.dart';
import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/database_service.dart';

class NotificationsPage extends StatefulWidget {
  final Language lang;

  const NotificationsPage({super.key, required this.lang});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = NotificationService();
  late int _selectedInterval;
  late int _selectedWarningDays;
  late bool _notificationsEnabled;
  List<ExpiryNotificationData> _upcomingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedInterval = _notificationService.notificationIntervalHours;
    _selectedWarningDays = _notificationService.expiryWarningDays;
    _notificationsEnabled = _notificationService.notificationsEnabled;
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final fridgeItems = await DatabaseService().getItems();
    final recipes = await DatabaseService().getRecipes();

    setState(() {
      _upcomingNotifications =
          _notificationService.getUpcomingExpiryNotifications(fridgeItems, recipes);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppTexts.of("notifications", lang)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == Language.tr
                                  ? "Bildirimleri Etkinleştir"
                                  : "Enable Notifications",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lang == Language.tr
                                  ? "Son kullanma tarihi yaklaşan ürünler"
                                  : "Products with expiring dates",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                            _notificationService.setNotificationsEnabled(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notification interval
                  Text(
                    lang == Language.tr ? "Bildirim Sıklığı" : "Notification Frequency",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedInterval,
                      items: [1, 2, 3, 6, 12, 24]
                          .map((hours) => DropdownMenuItem(
                                value: hours,
                                child: Text(
                                  hours == 1
                                      ? (lang == Language.tr
                                          ? "Saatte bir"
                                          : "Every hour")
                                      : (lang == Language.tr
                                          ? "$hours saatte bir"
                                          : "Every $hours hours"),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedInterval = value);
                          _notificationService
                              .setNotificationIntervalHours(value);
                        }
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Warning days
                  Text(
                    lang == Language.tr
                        ? "Uyarı Süresi (Gün)"
                        : "Warning Period (Days)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedWarningDays,
                      items: [1, 2, 3, 5, 7, 14]
                          .map((days) => DropdownMenuItem(
                                value: days,
                                child: Text(
                                  lang == Language.tr
                                      ? "$days gün öncesinden"
                                      : "$days days before",
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedWarningDays = value);
                          _notificationService.setExpiryWarningDays(value);
                          _loadNotifications();
                        }
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Upcoming notifications
                  Text(
                    lang == Language.tr ? "Yaklaşan Uyarılar" : "Upcoming Alerts",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_upcomingNotifications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          lang == Language.tr
                              ? "Yaklaşan son kullanma tarihi yok 🎉"
                              : "No upcoming expiry dates 🎉",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _upcomingNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _upcomingNotifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: notification.daysLeft <= 1
                                    ? AppColors.error
                                    : AppColors.warning,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      notification.daysLeft <= 1
                                          ? Icons.warning_rounded
                                          : Icons.info_rounded,
                                      color: notification.daysLeft <= 1
                                          ? AppColors.error
                                          : AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        notification.itemName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      lang == Language.tr
                                          ? "${notification.daysLeft} gün"
                                          : "${notification.daysLeft} days",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: notification.daysLeft <= 1
                                            ? AppColors.error
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (notification.recipe != null)
                                  Text(
                                    notification.getNotificationMessage(
                                      lang == Language.tr ? 'tr' : 'en',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
