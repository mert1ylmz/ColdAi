import '../../features/my_fridge/models/fridge_item_model.dart';
import '../../features/recipes/models/recipe_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _notificationsEnabled = true;
  int _notificationIntervalHours = 1;
  int _expiryWarningDays = 3;

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationIntervalHours => _notificationIntervalHours;
  int get expiryWarningDays => _expiryWarningDays;

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  void setNotificationIntervalHours(int hours) {
    _notificationIntervalHours = hours;
  }

  void setExpiryWarningDays(int days) {
    _expiryWarningDays = days;
  }

  List<ExpiryNotificationData> getUpcomingExpiryNotifications(
    List<FridgeItemModel> fridgeItems,
    List<RecipeModel> recipes,
  ) {
    final now = DateTime.now();
    final warningDate = now.add(Duration(days: _expiryWarningDays));

    final notifications = <ExpiryNotificationData>[];

    for (var item in fridgeItems) {
      if (item.expiryDate == null) continue;

      final expiryDate = item.expiryDate;
      if (expiryDate == null) continue;

      if (expiryDate.isBefore(warningDate) && expiryDate.isAfter(now)) {
        final matchingRecipes = _findMatchingRecipes(item.name, recipes);
        final daysLeft = expiryDate.difference(now).inDays;

        if (matchingRecipes.isNotEmpty) {
          notifications.add(ExpiryNotificationData(
            itemName: item.name,
            daysLeft: daysLeft,
            recipe: matchingRecipes.first,
            allMatchingRecipes: matchingRecipes,
          ));
        } else {
          notifications.add(ExpiryNotificationData(
            itemName: item.name,
            daysLeft: daysLeft,
            recipe: null,
            allMatchingRecipes: [],
          ));
        }
      }
    }

    return notifications;
  }

  List<RecipeModel> _findMatchingRecipes(
    String itemName,
    List<RecipeModel> recipes,
  ) {
    final lowerItemName = itemName.toLowerCase();
    return recipes
        .where((recipe) => recipe.ingredients.any(
              (ingredient) => ingredient.toLowerCase().contains(lowerItemName),
            ))
        .toList();
  }
}

class ExpiryNotificationData {
  final String itemName;
  final int daysLeft;
  final RecipeModel? recipe;
  final List<RecipeModel> allMatchingRecipes;

  ExpiryNotificationData({
    required this.itemName,
    required this.daysLeft,
    required this.recipe,
    required this.allMatchingRecipes,
  });

  String getNotificationMessage(String language) {
    if (recipe == null) {
      return language == 'tr'
          ? '$itemName tüketilmesini bekliyor (${daysLeft} gün kaldı)'
          : '$itemName waiting to be consumed ($daysLeft days left)';
    }

    final recipeName = recipe!.nameKey;
    return language == 'tr'
        ? '$itemName adlı ürünle $recipeName yemeği yapabilirsin'
        : 'You can make $recipeName with $itemName';
  }
}
