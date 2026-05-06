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
    "onboarding_title": {Language.tr: "Onboarding", Language.en: "Onboarding"},
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
    "nav_search": {Language.tr: "Ara", Language.en: "Search"},
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
          "Dünya genelinde üretilen gıdanın yaklaşık %30’u israf ediliyor.",
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
  };

  static String of(String key, Language lang) {
    final row = _t[key];
    if (row == null) return key;
    return row[lang] ?? row[Language.en] ?? key;
  }
}
