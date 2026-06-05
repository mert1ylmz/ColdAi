/// Kategori anahtarı → varsayılan raf ömrü (gün).
/// `AppTexts` filter_* keylerine birebir karşılık gelir.
class ShelfLifeTable {
  static const Map<String, int> defaultDaysByCategoryKey = {
    'filter_fruit': 7,
    'filter_vegetable': 5,
    'filter_dairy': 7,
    'filter_meat': 3,
    'filter_beverage': 30,
    'filter_packaged': 120,
    'filter_other': 14,
  };

  /// Ürün durumu açıldıysa raf ömrü genelde kısalır.
  static const Map<String, int> openedDaysByCategoryKey = {
    'filter_fruit': 3,
    'filter_vegetable': 3,
    'filter_dairy': 3,
    'filter_meat': 2,
    'filter_beverage': 5,
    'filter_packaged': 14,
    'filter_other': 5,
  };

  static int defaultDaysFor(String? categoryKey) {
    if (categoryKey == null) return 14;
    return defaultDaysByCategoryKey[categoryKey] ?? 14;
  }

  static int openedDaysFor(String? categoryKey) {
    if (categoryKey == null) return 5;
    return openedDaysByCategoryKey[categoryKey] ?? 5;
  }
}
