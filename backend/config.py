"""
ColdAI — Merkezi Konfigürasyon

Bu dosya tüm sistemin TEK DOĞRULUK KAYNAĞI (Single Source of Truth) dosyasıdır.
Ürün sınıfları, model yolları, eşik değerleri ve TR↔EN eşleştirmeleri
burada tanımlanır. Diğer tüm modüller bu dosyayı referans alır.

ÖNEMLİ: Sınıf listeleri ALFABETİK SIRALI olmalıdır.
Keras image_dataset_from_directory klasörleri alfbetik sıralar ve
model çıktı indeksleri bu sıraya göre eşleşir.
"""

import os
from pathlib import Path

# ──────────────────────────────────────────────
# Dizin Yolları
# ──────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = BASE_DIR.parent
MODELS_DIR = PROJECT_ROOT / "models"

# ──────────────────────────────────────────────
# Model Dosya Yolları
# ──────────────────────────────────────────────
MODEL_PATHS = {
    "main": MODELS_DIR / "ana_model_yenilenen (1).keras",
    "meyve": MODELS_DIR / "meyve_modeli_yeni (1).keras",
    "sebze": MODELS_DIR / "sebze_modeli_yeni (1).keras",
    "paketli": MODELS_DIR / "paketli_modeli_yeni (1).keras",
}

# ──────────────────────────────────────────────
# Görüntü Ön-İşleme
# ──────────────────────────────────────────────
IMG_SIZE = (224, 224)
# NOT: Modellerin içinde Rescaling(1./255) katmanı var.
# Inference sırasında görüntüleri ayrıca normalize ETMEYİN.
# Ham piksel değerleri (0-255 float32) doğrudan modele verilir.

# ──────────────────────────────────────────────
# Ürün Sınıfları (Alfabetik — Model çıktı indeksleriyle birebir eşleşir)
# ──────────────────────────────────────────────
PRODUCT_CLASSES = {
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
}

# Ana model kategorileri (alfabetik — image_dataset_from_directory sırası)
MAIN_CATEGORIES = sorted(PRODUCT_CLASSES.keys())  # ['meyve', 'paketli', 'sebze']

# ──────────────────────────────────────────────
# Güven Skoru Eşikleri
# ──────────────────────────────────────────────
MAIN_MODEL_THRESHOLD = 0.65   # Ana model kategori eşiği
SUB_MODEL_THRESHOLD = 0.70    # Alt model ürün eşiği
TOP2_GAP_THRESHOLD = 0.15     # İlk iki tahmin arası minimum fark

# ──────────────────────────────────────────────
# Türkçe → İngilizce Ürün Eşleştirme Sözlüğü (OCR için)
# ──────────────────────────────────────────────
TR_TO_EN_PRODUCT_MAP = {
    # ── Meyve ──
    "elma": "Apple",
    "elmalar": "Apple",
    "kırmızı elma": "Apple",
    "yeşil elma": "Apple",
    "muz": "Banana",
    "muzlar": "Banana",
    "üzüm": "Grape",
    "kara üzüm": "Grape",
    "beyaz üzüm": "Grape",
    "mandalina": "Mandarine",
    "mandarina": "Mandarine",
    "mango": "Mango",
    "portakal": "Orange",
    "şeftali": "Peach",
    "armut": "Pear",
    "ananas": "Pineapple",
    "çilek": "Strawberry",
    # ── Sebze ──
    "havuç": "Carrot",
    "mısır": "Corn",
    "salatalık": "Cucumber",
    "hıyar": "Cucumber",
    "patlıcan": "Eggplant",
    "soğan": "Onion",
    "kuru soğan": "Onion",
    "biber": "Pepper",
    "dolmalık biber": "Pepper",
    "sivri biber": "Pepper",
    "patates": "Potato",
    "domates": "Tomato",
    "salkım domates": "Tomato",
    "cherry domates": "Tomato",
    # ── Paketli ──
    "bisküvi": "Biscuit",
    "biskuvi": "Biscuit",
    "cips": "Chips",
    "çikolata": "Chocolate",
    "kahve": "Coffee",
    "nescafe": "Coffee",
    "filtre kahve": "Coffee",
    "meyve suyu": "Juice",
    "meyvesuyu": "Juice",
    "süt": "Milk",
    "günlük süt": "Milk",
    "makarna": "Pasta",
    "spagetti": "Pasta",
    "erişte": "Pasta",
    "gazoz": "Soda",
    "kola": "Soda",
    "meşrubat": "Soda",
    "çay": "Tea",
    "siyah çay": "Tea",
    "su": "Water",
    "doğal kaynak suyu": "Water",
    "memba suyu": "Water",
}

# ──────────────────────────────────────────────
# Ters Eşleştirme Tabloları (Otomatik Üretilir)
# ──────────────────────────────────────────────

# İngilizce ad → Kategori
EN_TO_CATEGORY: dict[str, str] = {}
for _category, _products in PRODUCT_CLASSES.items():
    for _product in _products:
        EN_TO_CATEGORY[_product] = _category

# İngilizce ad → Türkçe ad (ilk eşleşme)
EN_TO_TR: dict[str, str] = {}
for _tr, _en in TR_TO_EN_PRODUCT_MAP.items():
    if _en not in EN_TO_TR:
        EN_TO_TR[_en] = _tr

# ──────────────────────────────────────────────
# Veritabanı
# ──────────────────────────────────────────────
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    f"sqlite+aiosqlite:///{BASE_DIR / 'coldai.db'}"
)

# ──────────────────────────────────────────────
# Kimlik Doğrulama (JWT)
# ──────────────────────────────────────────────
SECRET_KEY = os.getenv("SECRET_KEY", "coldai-dev-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 saat

# ──────────────────────────────────────────────
# OCR Ayarları
# ──────────────────────────────────────────────
TESSERACT_CMD = os.getenv("TESSERACT_CMD", None)  # Tesseract yolu (PATH'te değilse)
OCR_LANG = "tur+eng"  # Türkçe + İngilizce
FUZZY_MATCH_THRESHOLD = 80  # Minimum benzerlik skoru (0-100)
