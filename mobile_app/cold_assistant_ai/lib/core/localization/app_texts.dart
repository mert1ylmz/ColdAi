import 'language.dart';

class AppTexts {
  static const Map<String, Map<Language, String>> _t = {
    // general
    "app_name": {
      Language.tr: "Cold Assistant AI",
      Language.en: "Cold Assistant AI",
    },
    "email": {Language.tr: "E-posta", Language.en: "Email"},
    "password": {Language.tr: "Şifre", Language.en: "Password"},
    "name": {Language.tr: "Ad Soyad", Language.en: "Full Name"},
    "confirm_password": {
      Language.tr: "Şifre (Tekrar)",
      Language.en: "Confirm Password",
    },
    "continue": {Language.tr: "Devam Et", Language.en: "Continue"},
    "select_option": {Language.tr: "Seçiniz", Language.en: "Select"},
    "error_prefix": {
      Language.tr: "Hata oluştu",
      Language.en: "An error occurred",
    },
    "user_not_found": {
      Language.tr: "Kullanıcı bulunamadı",
      Language.en: "User not found",
    },
    "welcome": {Language.tr: "Hoş geldin", Language.en: "Welcome"},

    // auth titles
    "login_subtitle": {
      Language.tr: "Devam etmek için giriş yap.",
      Language.en: "Sign in to continue.",
    },
    "register_subtitle": {
      Language.tr: "Yeni hesap oluştur.",
      Language.en: "Create a new account.",
    },

    // buttons
    "btn_login": {Language.tr: "Giriş Yap", Language.en: "Sign In"},
    "btn_register": {Language.tr: "Kayıt Ol", Language.en: "Sign Up"},

    // switch links
    "no_account": {
      Language.tr: "Hesabın yok mu?",
      Language.en: "Don't have an account?",
    },
    "have_account": {
      Language.tr: "Zaten hesabın var mı?",
      Language.en: "Already have an account?",
    },
    "go_register": {Language.tr: "Kayıt Ol", Language.en: "Sign Up"},
    "go_login": {Language.tr: "Giriş Yap", Language.en: "Sign In"},

    // misc
    "forgot_password": {
      Language.tr: "Şifremi unuttum",
      Language.en: "Forgot password",
    },
    "brand": {Language.tr: "Cold Assistant", Language.en: "Cold Assistant"},
    "login_hint": {
      Language.tr: "Devam etmek için giriş yap.",
      Language.en: "Sign in to continue.",
    },
    "register_hint": {
      Language.tr: "Hesabını oluştur ve devam et.",
      Language.en: "Create your account to continue.",
    },

    // onboarding
    "onboarding_title": {Language.tr: "Kurulum", Language.en: "Setup"},
    "onboarding_subtitle": {
      Language.tr: "Buzdolabınızı tanımamıza yardımcı olun.",
      Language.en: "Help us get to know your refrigerator.",
    },
    "fridge_type": {Language.tr: "Buzdolabı tipi", Language.en: "Fridge Type"},
    "fill_all_fields": {
      Language.tr: "Lütfen tüm alanları doldur.",
      Language.en: "Please fill all fields.",
    },
    "onboarding_done": {
      Language.tr: "Onboarding tamamlandı",
      Language.en: "Onboarding completed",
    },
    "usage_area": {Language.tr: "Kullanım alanı", Language.en: "Usage area"},
    "fridge_size": {
      Language.tr: "Buzdolabı boyutu",
      Language.en: "Fridge size",
    },
    "energy_class": {Language.tr: "Enerji sınıfı", Language.en: "Energy class"},
    "brand_name": {Language.tr: "Marka", Language.en: "Brand"},

    // usage area values
    "usage_home": {Language.tr: "Ev", Language.en: "Home"},
    "usage_workplace": {Language.tr: "İşyeri", Language.en: "Workplace"},
    "usage_office": {Language.tr: "Ofis", Language.en: "Office"},
    "usage_store": {Language.tr: "Mağaza", Language.en: "Store"},
    "usage_warehouse": {Language.tr: "Depo", Language.en: "Warehouse"},
    "usage_restaurant": {
      Language.tr: "Restoran / Kafe",
      Language.en: "Restaurant / Cafe",
    },

    // home page menu
    "profile": {Language.tr: "Profil", Language.en: "Profile"},
    "notifications": {Language.tr: "Bildirimler", Language.en: "Notifications"},
    "settings": {Language.tr: "Ayarlar", Language.en: "Settings"},
    "logout": {Language.tr: "Çıkış", Language.en: "Logout"},
    "profile_coming_soon": {
      Language.tr: "Profil alanı sonra eklenecek",
      Language.en: "Profile section will be added later",
    },
    "notifications_coming_soon": {
      Language.tr: "Bildirimler alanı sonra eklenecek",
      Language.en: "Notifications section will be added later",
    },
    "settings_coming_soon": {
      Language.tr: "Ayarlar alanı sonra eklenecek",
      Language.en: "Settings section will be added later",
    },

    // assistant chat
    "assistant_chat_title": {
      Language.tr: "Cold Assistant Sohbet",
      Language.en: "Cold Assistant Chat",
    },
    "assistant_chat_subtitle": {
      Language.tr: "Buzdolabınla ilgili soru sor, asistan sana yardımcı olsun.",
      Language.en:
          "Ask a question about your refrigerator and let the assistant help you.",
    },
    "assistant_chat_hint": {
      Language.tr: "Örn: Buzdolabım neden çok ses çıkarıyor?",
      Language.en: "E.g. Why is my refrigerator making too much noise?",
    },
    "assistant_first_message": {
      Language.tr:
          "Merhaba! Ben Cold Assistant AI. Buzdolabın hakkında soru sorabilirsin.",
      Language.en:
          "Hello! I am Cold Assistant AI. You can ask questions about your refrigerator.",
    },
    "assistant_demo_reply": {
      Language.tr:
          "Bu alan daha sonra gerçek API ile bağlanacak. Şimdilik sohbet kartı hazır.",
      Language.en:
          "This area will be connected to the real API later. For now, the chat card is ready.",
    },
    "assistant_typing": {
      Language.tr: "Yazıyor...",
      Language.en: "Typing...",
    },
    "assistant_api_missing": {
      Language.tr: "API anahtarı eksik. Lütfen koda ekleyin.",
      Language.en: "API key is missing. Please add it to the code.",
    },

    // info cards
    "smart_suggestion": {
      Language.tr: "Akıllı Öneri",
      Language.en: "Smart Suggestion",
    },
    "smart_suggestion_subtitle": {
      Language.tr: "Yakında tarif ve stok önerileri burada olacak.",
      Language.en: "Recipe and stock suggestions will be shown here soon.",
    },
    "reminders": {Language.tr: "Hatırlatıcılar", Language.en: "Reminders"},
    "reminders_subtitle": {
      Language.tr: "Son kullanma tarihi uyarıları için hazır alan.",
      Language.en: "Reserved area for expiration date alerts.",
    },

    // bottom nav
    "nav_home": {Language.tr: "Home", Language.en: "Home"},
    "nav_pending": {Language.tr: "Askıda", Language.en: "Pending"},
    "nav_recipes": {Language.tr: "Tarifler", Language.en: "Recipes"},
    "nav_my_fridge": {Language.tr: "Dolabım", Language.en: "My Fridge"},

    // hero slogans
    "slogan_1": {
      Language.tr: "Yiyeceklerini daha akıllı yönet.",
      Language.en: "Manage your food more intelligently.",
    },
    "slogan_2": {
      Language.tr: "İsrafı azalt, tazeliği koru.",
      Language.en: "Reduce waste, preserve freshness.",
    },
    "slogan_3": {
      Language.tr: "Buzdolabını senin için düşünen asistan.",
      Language.en: "An assistant that thinks about your fridge for you.",
    },
    "slogan_4": {
      Language.tr: "Malzemelerini takip et, rahat et.",
      Language.en: "Track your ingredients and stay comfortable.",
    },
    "slogan_5": {
      Language.tr:
          "Dünya genelinde üretilen gıdanın yaklaşık %30'u israf ediliyor.",
      Language.en: "Approximately 30% of food produced worldwide is wasted.",
    },
    "slogan_6": {
      Language.tr:
          "Evlerde alınan gıdaların önemli bir kısmı tüketilmeden çöpe gidiyor.",
      Language.en:
          "A significant portion of food bought for homes is thrown away before being consumed.",
    },
    "slogan_7": {
      Language.tr: "Doğru saklama, gıdaların raf ömrünü uzatabilir.",
      Language.en: "Proper storage can extend the shelf life of food.",
    },
    "slogan_8": {
      Language.tr:
          "Buzdolabında unutulan ürünler ev tipi israfın önemli nedenlerinden biridir.",
      Language.en:
          "Products forgotten in the refrigerator are one of the major causes of household waste.",
    },
    "slogan_9": {
      Language.tr:
          "Planlı alışveriş, gereksiz harcamayı azaltmaya yardımcı olur.",
      Language.en: "Planned shopping helps reduce unnecessary spending.",
    },
    "slogan_10": {
      Language.tr: "Soğuk zincirin korunması gıda güvenliği için kritiktir.",
      Language.en: "Maintaining the cold chain is critical for food safety.",
    },
    "slogan_11": {
      Language.tr:
          "Küçük takip alışkanlıkları büyük gıda kayıplarını önleyebilir.",
      Language.en: "Small tracking habits can prevent major food losses.",
    },
    "my_fridge_title": {Language.tr: "Dolabım", Language.en: "My Fridge"},
    "add_with_ai": {Language.tr: "Kamera ile Ekle", Language.en: "Add with AI"},
    "add_manual": {Language.tr: "Manuel Ekle", Language.en: "Add Manually"},
    "detected_product": {
      Language.tr: "Algılanan Ürün",
      Language.en: "Detected Product",
    },
    "product_name": {Language.tr: "Ürün Adı", Language.en: "Product Name"},
    "quantity": {Language.tr: "Miktar", Language.en: "Quantity"},
    "note": {Language.tr: "Not", Language.en: "Note"},
    "added_date": {Language.tr: "Eklenme Tarihi", Language.en: "Added Date"},
    "expiry_date": {
      Language.tr: "Son Kullanma Tarihi",
      Language.en: "Expiry Date",
    },
    "save": {Language.tr: "Kaydet", Language.en: "Save"},
    "cancel": {Language.tr: "İptal", Language.en: "Cancel"},
    "my_fridge_subtitle": {
      Language.tr: "Eklediğin ürünleri burada görebilirsin",
      Language.en: "You can see your added products here",
    },
    "add_product": {Language.tr: "Ürün ekle", Language.en: "Add product"},
    "choose_add_method": {
      Language.tr: "Nasıl eklemek istersin?",
      Language.en: "How would you like to add it?",
    },
    "add_with_camera": {
      Language.tr: "Kamera ile ekle",
      Language.en: "Add with camera",
    },
    "empty_fridge_title": {
      Language.tr: "Henüz ürün eklenmedi",
      Language.en: "No products added yet",
    },
    "empty_fridge_subtitle": {
      Language.tr: "İlk ürününü ekleyerek dolabını oluşturmaya başla",
      Language.en: "Start building your fridge by adding your first product",
    },
    "category": {Language.tr: "Kategori", Language.en: "Category"},
    "camera_coming_soon": {
      Language.tr: "Kamera ile ekleme yakında eklenecek",
      Language.en: "Add with camera will be available soon",
    },
    "manual_add_coming_soon": {
      Language.tr: "Manuel ekleme formu birazdan eklenecek",
      Language.en: "Manual add form will be added next",
    },
    // scan / product detection
    "scan_product": {Language.tr: "Ürün Tara", Language.en: "Scan Product"},
    "camera": {Language.tr: "Kamera", Language.en: "Camera"},
    "gallery": {Language.tr: "Galeri", Language.en: "Gallery"},
    "analyzing_product": {
      Language.tr: "Ürün analiz ediliyor...",
      Language.en: "Analyzing product...",
    },
    "api_connection_failed": {
      Language.tr: "API bağlantısı başarısız. Backend açık mı?",
      Language.en: "API connection failed. Is the backend running?",
    },
    "product": {Language.tr: "Ürün", Language.en: "Product"},
    "confidence": {Language.tr: "Güven", Language.en: "Confidence"},
    "api_error": {
      Language.tr: "API hata verdi",
      Language.en: "API returned an error",
    },
    "connection_error": {
      Language.tr: "Bağlantı hatası",
      Language.en: "Connection error",
    },
    "unknown_product": {Language.tr: "Bilinmiyor", Language.en: "Unknown"},
    "add_to_fridge": {Language.tr: "Dolaba Ekle", Language.en: "Add to Fridge"},
    "edit_detected_product": {
      Language.tr: "Algılanan Ürünü Düzenle",
      Language.en: "Edit Detected Product",
    },
    "product_saved": {
      Language.tr: "Ürün dolaba eklendi",
      Language.en: "Product added to fridge",
    },
    "scan_receipt": {Language.tr: "Fiş Tara", Language.en: "Scan Receipt"},
    "scanning_receipt": {
      Language.tr: "Fiş analiz ediliyor...",
      Language.en: "Scanning receipt...",
    },
    "add_with_receipt": {
      Language.tr: "Fiş tara",
      Language.en: "Scan receipt",
    },

    // ========== NEW STRINGS ==========

    // Expiry reminders
    "reminder_expiry_approaching": {
      Language.tr: "{name} son kullanma tarihi yaklaşıyor",
      Language.en: "{name} expiry date is approaching",
    },
    "reminder_consume_today": {
      Language.tr: "{name} bugün tüketmen iyi olabilir",
      Language.en: "You should consume {name} today",
    },
    "reminder_expired": {
      Language.tr: "{name} son kullanma tarihi geçmiş!",
      Language.en: "{name} has expired!",
    },
    "reminder_no_expiry": {
      Language.tr: "Harika! Yakında son kullanma tarihi dolan ürün yok 🎉",
      Language.en: "Great! No products expiring soon 🎉",
    },
    "reminder_days_left": {
      Language.tr: "{days} gün kaldı",
      Language.en: "{days} days left",
    },
    "reminder_today": {
      Language.tr: "Bugün!",
      Language.en: "Today!",
    },

    // Smart Suggestion Page
    "smart_suggestion_page_title": {
      Language.tr: "Akıllı Öneri",
      Language.en: "Smart Suggestion",
    },
    "smart_suggestion_page_subtitle": {
      Language.tr: "AI destekli öneriler ve tarifler",
      Language.en: "AI-powered suggestions and recipes",
    },
    "smart_suggestion_assistant_title": {
      Language.tr: "Akıllı Asistan",
      Language.en: "Smart Assistant",
    },
    "smart_suggestion_assistant_subtitle": {
      Language.tr: "Dolabındaki ürünlere göre öneriler al",
      Language.en: "Get suggestions based on your fridge items",
    },
    "smart_suggestion_assistant_hint": {
      Language.tr: "Örn: Dolabımdaki malzemelerle ne yapabilirim?",
      Language.en: "E.g. What can I make with ingredients in my fridge?",
    },
    "smart_suggestion_recipes_title": {
      Language.tr: "Tarifleri Keşfet",
      Language.en: "Explore Recipes",
    },
    "smart_suggestion_recipes_subtitle": {
      Language.tr: "Birbirinden lezzetli tariflere göz at",
      Language.en: "Browse delicious recipes",
    },

    // Recipes Page
    "recipes_title": {
      Language.tr: "Tarifler",
      Language.en: "Recipes",
    },
    "recipes_subtitle": {
      Language.tr: "Birbirinden lezzetli tarifleri keşfet",
      Language.en: "Discover delicious recipes",
    },
    "recipe_prep_time": {
      Language.tr: "Süre",
      Language.en: "Time",
    },
    "recipe_difficulty": {
      Language.tr: "Zorluk",
      Language.en: "Difficulty",
    },
    "recipe_ingredients": {
      Language.tr: "Malzemeler",
      Language.en: "Ingredients",
    },
    "recipe_easy": {
      Language.tr: "Kolay",
      Language.en: "Easy",
    },
    "recipe_medium": {
      Language.tr: "Orta",
      Language.en: "Medium",
    },
    "recipe_hard": {
      Language.tr: "Zor",
      Language.en: "Hard",
    },
    "recipe_minutes": {
      Language.tr: "dk",
      Language.en: "min",
    },

    // Default Recipe Names
    "recipe_1_name": {
      Language.tr: "Menemen",
      Language.en: "Turkish Menemen",
    },
    "recipe_1_desc": {
      Language.tr: "Domates, biber ve yumurta ile hazırlanan klasik Türk kahvaltısı",
      Language.en: "Classic Turkish breakfast with tomatoes, peppers and eggs",
    },
    "recipe_2_name": {
      Language.tr: "Mercimek Çorbası",
      Language.en: "Lentil Soup",
    },
    "recipe_2_desc": {
      Language.tr: "Geleneksel kırmızı mercimek çorbası",
      Language.en: "Traditional red lentil soup",
    },
    "recipe_3_name": {
      Language.tr: "Makarna Bolonez",
      Language.en: "Pasta Bolognese",
    },
    "recipe_3_desc": {
      Language.tr: "İtalyan usulü kıymalı makarna sosu",
      Language.en: "Italian-style meat pasta sauce",
    },
    "recipe_4_name": {
      Language.tr: "Tavuk Sote",
      Language.en: "Chicken Sauté",
    },
    "recipe_4_desc": {
      Language.tr: "Sebzeli tavuk sote, ana yemek",
      Language.en: "Chicken sauté with vegetables, main course",
    },
    "recipe_5_name": {
      Language.tr: "Çoban Salatası",
      Language.en: "Shepherd's Salad",
    },
    "recipe_5_desc": {
      Language.tr: "Taze sebzelerle hazırlanan hafif salata",
      Language.en: "Light salad prepared with fresh vegetables",
    },
    "recipe_6_name": {
      Language.tr: "Patates Kızartması",
      Language.en: "French Fries",
    },
    "recipe_6_desc": {
      Language.tr: "Çıtır çıtır patates kızartması",
      Language.en: "Crispy french fries",
    },
    "recipe_7_name": {
      Language.tr: "Omlet",
      Language.en: "Omelette",
    },
    "recipe_7_desc": {
      Language.tr: "Peynirli ve sebzeli omlet",
      Language.en: "Omelette with cheese and vegetables",
    },
    "recipe_8_name": {
      Language.tr: "Pilav",
      Language.en: "Rice Pilaf",
    },
    "recipe_8_desc": {
      Language.tr: "Tereyağlı pirinç pilavı",
      Language.en: "Buttered rice pilaf",
    },
    "recipe_9_name": {
      Language.tr: "Karnıyarık",
      Language.en: "Stuffed Eggplant",
    },
    "recipe_9_desc": {
      Language.tr: "Kıymalı patlıcan yemeği",
      Language.en: "Eggplant stuffed with minced meat",
    },
    "recipe_10_name": {
      Language.tr: "Smoothie Bowl",
      Language.en: "Smoothie Bowl",
    },
    "recipe_10_desc": {
      Language.tr: "Meyveli sağlıklı smoothie kase",
      Language.en: "Healthy fruit smoothie bowl",
    },

    // Pending (Askıda) Page
    "pending_title": {
      Language.tr: "Askıda",
      Language.en: "Pending",
    },
    "pending_subtitle": {
      Language.tr: "İhtiyaç sahiplerine fazla ürünlerini ulaştır",
      Language.en: "Deliver your surplus products to those in need",
    },
    "pending_info_title": {
      Language.tr: "Askıda Ürün Nedir?",
      Language.en: "What is Pending Product?",
    },
    "pending_info_desc": {
      Language.tr: "Fazla veya kullanmayacağın ürünleri askıya bırakarak ihtiyaç sahiplerine ulaştırabilirsin. Haritadan yakınındaki noktaları görebilirsin.",
      Language.en: "You can deliver your surplus or unused products to those in need by leaving them pending. You can see nearby points on the map.",
    },
    "pending_map_title": {
      Language.tr: "Yakındaki Noktalar",
      Language.en: "Nearby Points",
    },
    "pending_map_placeholder": {
      Language.tr: "Harita yakında aktif olacak",
      Language.en: "Map will be active soon",
    },
    "pending_leave_product": {
      Language.tr: "Ürün Askıya Bırak",
      Language.en: "Leave Product Pending",
    },
    "pending_my_items": {
      Language.tr: "Askıdaki Ürünlerim",
      Language.en: "My Pending Items",
    },
    "pending_browse": {
      Language.tr: "Askıdaki Ürünlere Göz At",
      Language.en: "Browse Pending Items",
    },
    "pending_coming_soon": {
      Language.tr: "Bu özellik yakında aktif olacak!",
      Language.en: "This feature will be active soon!",
    },
    "pending_tap_map": {
      Language.tr: "Haritaya dokunarak büyüt",
      Language.en: "Tap the map to expand",
    },

    // Manual Add Page
    "manual_add_title": {
      Language.tr: "Manuel Ürün Ekle",
      Language.en: "Add Product Manually",
    },
    "manual_add_subtitle": {
      Language.tr: "Ürün bilgilerini girerek dolabına ekle",
      Language.en: "Add to your fridge by entering product details",
    },
    "manual_product_details": {
      Language.tr: "Ürün Bilgileri",
      Language.en: "Product Details",
    },
    "manual_select_category": {
      Language.tr: "Kategori seç",
      Language.en: "Select category",
    },
    "manual_quantity_hint": {
      Language.tr: "Örn: 1 kg, 2 adet",
      Language.en: "E.g. 1 kg, 2 pcs",
    },
    "manual_note_hint": {
      Language.tr: "Ürün hakkında not ekle...",
      Language.en: "Add a note about the product...",
    },
    "manual_product_name_hint": {
      Language.tr: "Ürün adını girin",
      Language.en: "Enter product name",
    },

    // Category Filters
    "filter_all": {
      Language.tr: "Tümü",
      Language.en: "All",
    },
    "filter_fruit": {
      Language.tr: "Meyve",
      Language.en: "Fruit",
    },
    "filter_vegetable": {
      Language.tr: "Sebze",
      Language.en: "Vegetable",
    },
    "filter_dairy": {
      Language.tr: "Süt Ürünleri",
      Language.en: "Dairy",
    },
    "filter_meat": {
      Language.tr: "Et/Tavuk/Balık",
      Language.en: "Meat/Poultry/Fish",
    },
    "filter_beverage": {
      Language.tr: "İçecek",
      Language.en: "Beverage",
    },
    "filter_packaged": {
      Language.tr: "Paketli",
      Language.en: "Packaged",
    },
    "filter_other": {
      Language.tr: "Diğer",
      Language.en: "Other",
    },
    "filter_empty": {
      Language.tr: "Bu kategoride ürün bulunamadı",
      Language.en: "No products found in this category",
    },
    "filter_empty_subtitle": {
      Language.tr: "Bu sınıfta henüz ürün eklenmemiş",
      Language.en: "No products have been added to this category yet",
    },

    // Add via camera/manual
    "add_via_camera_or_manual": {
      Language.tr: "Kamera veya elle ekle",
      Language.en: "Add via camera or manually",
    },
    "scan_with_ai": {
      Language.tr: "Yapay zeka ile tara",
      Language.en: "Scan with AI",
    },
    "add_products_via_receipt": {
      Language.tr: "Fiş üzerinden ürünleri ekle",
      Language.en: "Add products via receipt",
    },
    "enter_details_manually": {
      Language.tr: "Bilgileri kendin gir",
      Language.en: "Enter details manually",
    },
    "recipe_add_title": {
      Language.tr: "Tarifi Kaydet",
      Language.en: "Save Recipe",
    },
    "recipe_added_success": {
      Language.tr: "Tarif başarıyla kaydedildi!",
      Language.en: "Recipe successfully saved!",
    },
    "recipe_name": {
      Language.tr: "Tarif Adı",
      Language.en: "Recipe Name",
    },
    "recipe_desc": {
      Language.tr: "Hazırlanışı / Tarif Açıklaması",
      Language.en: "Preparation / Recipe Description",
    },
    "recipe_save_btn": {
      Language.tr: "Tariflerime Ekle",
      Language.en: "Add to My Recipes",
    },
    "recipe_deleted": {
      Language.tr: "Tarif silindi",
      Language.en: "Recipe deleted",
    },
    "go_to_recipes": {
      Language.tr: "Tariflere Git",
      Language.en: "Go to Recipes",
    },
    "recipe_add_to_recipes_tooltip": {
      Language.tr: "Bu öneriyi tarife dönüştür",
      Language.en: "Convert this suggestion into a recipe",
    },
    "recipe_difficulty_label": {
      Language.tr: "Zorluk Derecesi",
      Language.en: "Difficulty Level",
    },
    "recipe_prep_time_label": {
      Language.tr: "Hazırlanış Süresi (dk)",
      Language.en: "Prep Time (min)",
    },
    "recipe_ingredients_hint": {
      Language.tr: "Malzemeler (Virgülle ayırın)",
      Language.en: "Ingredients (Comma-separated)",
    },
  };

  static String of(String key, Language lang) {
    final row = _t[key];
    if (row == null) return key;
    return row[lang] ?? row[Language.en] ?? key;
  }
}
