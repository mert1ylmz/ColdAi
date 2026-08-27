/// On-device TFLite ve OCR servisleri için statik etiketler ve eşikler.
///
/// Kaynak: backend/config.py — sıralama alfabetik olup model çıktı
/// indeksleriyle birebir eşleşir. Backend ile senkron tutulmalı.
class ModelLabels {
  /// Ana model çıktısı (alfabetik).
  static const List<String> mainCategories = ['meyve', 'paketli', 'sebze'];

  /// Alt model sınıfları (alfabetik).
  static const Map<String, List<String>> subClasses = {
    'meyve': [
      'Banana', 'Grape', 'Mandarine', 'Mango',
      'Orange', 'Peach', 'Pear', 'Pineapple', 'Strawberry',
    ],
    'sebze': [
      'Corn', 'Cucumber', 'Eggplant',
      'Onion', 'Pepper', 'Potato', 'Tomato',
    ],
    'paketli': [
      'Chips', 'Chocolate', 'Coffee', 'Juice',
      'Milk', 'Pasta', 'Soda', 'Tea', 'Water',
    ],
  };

  /// Güven eşikleri (backend ile aynı).
  static const double mainThreshold = 0.65;
  static const double subThreshold = 0.70;
  static const double top2GapThreshold = 0.15;

  /// İngilizce ürün adı → kategori anahtarı (meyve/sebze/paketli).
  static final Map<String, String> enToCategory = {
    for (final entry in subClasses.entries)
      for (final product in entry.value) product: entry.key,
  };

  /// İngilizce ürün adı → AppTexts filter_* kategori anahtarı.
  /// `detected_product_mapper`'ın beklediği formatla uyumlu.
  static String filterKeyFor(String category) {
    switch (category) {
      case 'meyve':
        return 'filter_fruit';
      case 'sebze':
        return 'filter_vegetable';
      case 'paketli':
        return 'filter_packaged';
      default:
        return 'filter_other';
    }
  }

  /// Türkçe ürün ismi → İngilizce kanonik isim (OCR için).
  static const Map<String, String> trToEnProduct = {
    // Meyve
    'elma': 'Apple',
    'elmalar': 'Apple',
    'kırmızı elma': 'Apple',
    'yeşil elma': 'Apple',
    'muz': 'Banana',
    'muzlar': 'Banana',
    'üzüm': 'Grape',
    'kara üzüm': 'Grape',
    'beyaz üzüm': 'Grape',
    'mandalina': 'Mandarine',
    'mandarina': 'Mandarine',
    'mango': 'Mango',
    'portakal': 'Orange',
    'şeftali': 'Peach',
    'armut': 'Pear',
    'ananas': 'Pineapple',
    'çilek': 'Strawberry',
    // Sebze
    'havuç': 'Carrot',
    'mısır': 'Corn',
    'salatalık': 'Cucumber',
    'hıyar': 'Cucumber',
    'patlıcan': 'Eggplant',
    'soğan': 'Onion',
    'kuru soğan': 'Onion',
    'biber': 'Pepper',
    'dolmalık biber': 'Pepper',
    'sivri biber': 'Pepper',
    'patates': 'Potato',
    'domates': 'Tomato',
    'salkım domates': 'Tomato',
    'cherry domates': 'Tomato',
    // Paketli
    'bisküvi': 'Biscuit',
    'biskuvi': 'Biscuit',
    'cips': 'Chips',
    'çikolata': 'Chocolate',
    'kahve': 'Coffee',
    'nescafe': 'Coffee',
    'filtre kahve': 'Coffee',
    'meyve suyu': 'Juice',
    'meyvesuyu': 'Juice',
    'süt': 'Milk',
    'günlük süt': 'Milk',
    'makarna': 'Pasta',
    'spagetti': 'Pasta',
    'erişte': 'Pasta',
    'gazoz': 'Soda',
    'kola': 'Soda',
    'meşrubat': 'Soda',
    'çay': 'Tea',
    'siyah çay': 'Tea',
    'su': 'Water',
    'doğal kaynak suyu': 'Water',
    'memba suyu': 'Water',
  };

  /// İngilizce kanonik isim → Türkçe gösterim adı (ilk eşleşme).
  static final Map<String, String> enToTr = () {
    final map = <String, String>{};
    for (final entry in trToEnProduct.entries) {
      map.putIfAbsent(entry.value, () => entry.key);
    }
    return map;
  }();
}
