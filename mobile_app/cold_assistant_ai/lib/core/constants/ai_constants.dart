class AIConstants {
  static const int imgSize = 224;
  
  static const String mainModelPath = 'assets/models/ana_model.tflite';
  static const String fruitModelPath = 'assets/models/meyve_modeli_yeni.tflite';
  static const String vegetableModelPath = 'assets/models/sebze_modeli_yeni.tflite';
  static const String packagedModelPath = 'assets/models/paketli_modeli_yeni.tflite';

  static const double mainModelThreshold = 0.65;
  static const double subModelThreshold = 0.70;
  static const double top2GapThreshold = 0.15;

  static const List<String> mainCategories = ['meyve', 'paketli', 'sebze'];

  static const Map<String, List<String>> productClasses = {
    "meyve": [
      "Banana", "Grape", "Mandarine", "Mango",
      "Orange", "Peach", "Pear", "Pineapple", "Strawberry",
    ],
    "sebze": [
      "Corn", "Cucumber", "Eggplant",
      "Onion", "Pepper", "Potato", "Tomato",
    ],
    "paketli": [
      "Chips", "Chocolate", "Coffee", "Juice",
      "Milk", "Pasta", "Soda", "Tea", "Water",
    ],
  };

  static const Map<String, String> trToEn = {
    "elma": "Apple", "elmalar": "Apple", "kırmızı elma": "Apple", "yeşil elma": "Apple",
    "muz": "Banana", "muzlar": "Banana",
    "üzüm": "Grape", "kara üzüm": "Grape", "beyaz üzüm": "Grape",
    "mandalina": "Mandarine", "mandarina": "Mandarine",
    "mango": "Mango",
    "portakal": "Orange",
    "şeftali": "Peach",
    "armut": "Pear",
    "ananas": "Pineapple",
    "çilek": "Strawberry",
    "havuç": "Carrot",
    "mısır": "Corn",
    "salatalık": "Cucumber", "hıyar": "Cucumber",
    "patlıcan": "Eggplant",
    "soğan": "Onion", "kuru soğan": "Onion",
    "biber": "Pepper", "dolmalık biber": "Pepper", "sivri biber": "Pepper",
    "patates": "Potato",
    "domates": "Tomato", "salkım domates": "Tomato", "cherry domates": "Tomato",
    "bisküvi": "Biscuit", "biskuvi": "Biscuit",
    "cips": "Chips",
    "çikolata": "Chocolate",
    "kahve": "Coffee", "nescafe": "Coffee", "filtre kahve": "Coffee",
    "meyve suyu": "Juice", "meyvesuyu": "Juice",
    "süt": "Milk", "günlük süt": "Milk",
    "makarna": "Pasta", "spagetti": "Pasta", "erişte": "Pasta",
    "gazoz": "Soda", "kola": "Soda", "meşrubat": "Soda",
    "çay": "Tea", "siyah çay": "Tea",
    "su": "Water", "doğal kaynak suyu": "Water", "memba suyu": "Water",
  };

  static const Map<String, String> enToTr = {
    "Apple": "elma", "Banana": "muz", "Grape": "üzüm", "Mandarine": "mandalina",
    "Mango": "mango", "Orange": "portakal", "Peach": "şeftali", "Pear": "armut",
    "Pineapple": "ananas", "Strawberry": "çilek", "Carrot": "havuç", "Corn": "mısır",
    "Cucumber": "salatalık", "Eggplant": "patlıcan", "Onion": "soğan", "Pepper": "biber",
    "Potato": "patates", "Tomato": "domates", "Biscuit": "bisküvi", "Chips": "cips",
    "Chocolate": "çikolata", "Coffee": "kahve", "Juice": "meyve suyu", "Milk": "süt",
    "Pasta": "makarna", "Soda": "gazoz", "Tea": "çay", "Water": "su",
  };
}
