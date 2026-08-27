"""
ColdAI — Merkezi Konfigürasyon

Bu dosya tüm sistemin TEK DOĞRULUK KAYNAĞI (Single Source of Truth) dosyasıdır.
Ürün sınıfları, model yolu, eşik değerleri ve TR↔EN eşleştirmeleri
burada tanımlanır. Diğer tüm modüller bu dosyayı referans alır.

ÖNEMLİ: CLASS_NAMES listesi eğitim sırasında üretilen
training/output/efficientnet_v2b0_classes.json ile birebir aynı olmalıdır.
image_dataset_from_directory alfabetik sıralar; sıra bozulursa tahminler yanlış eşleşir.
"""

import os
from pathlib import Path

# ──────────────────────────────────────────────
# Dizin Yolları
# ──────────────────────────────────────────────
BASE_DIR     = Path(__file__).resolve().parent
PROJECT_ROOT = BASE_DIR.parent
MODELS_DIR   = PROJECT_ROOT / "training" / "output"

# ──────────────────────────────────────────────
# Model Dosya Yolu — tek model, 25 sınıf
# ──────────────────────────────────────────────
MODEL_PATH = MODELS_DIR / "efficientnet_v2b0.keras"

# ──────────────────────────────────────────────
# Görüntü Ön-İşleme
# ──────────────────────────────────────────────
IMG_SIZE = (224, 224)
# EfficientNetV2B0, include_preprocessing=True ile eğitildi;
# ham 0-255 piksel gönderilmeli, preprocessing.py'de normalizasyon yapılmamalı.

# ──────────────────────────────────────────────
# Sınıf Listesi — eğitimden çıkan alfabetik sıra (değiştirme)
# ──────────────────────────────────────────────
CLASS_NAMES = [
    "Banana", "Chips", "Chocolate", "Coffee", "Corn",
    "Cucumber", "Eggplant", "Grape", "Juice", "Mandarine",
    "Mango", "Milk", "Onion", "Orange", "Pasta",
    "Peach", "Pear", "Pepper", "Pineapple", "Potato",
    "Soda", "Strawberry", "Tea", "Tomato", "Water",
]

# Kategori eşlemesi — her ürünün hangi gruba ait olduğunu gösterir
EN_TO_CATEGORY: dict[str, str] = {
    "Banana": "meyve", "Grape": "meyve", "Mandarine": "meyve", "Mango": "meyve",
    "Orange": "meyve", "Peach": "meyve", "Pear": "meyve",
    "Pineapple": "meyve", "Strawberry": "meyve",
    "Corn": "sebze", "Cucumber": "sebze", "Eggplant": "sebze",
    "Onion": "sebze", "Pepper": "sebze", "Potato": "sebze", "Tomato": "sebze",
    "Chips": "paketli", "Chocolate": "paketli", "Coffee": "paketli",
    "Juice": "paketli", "Milk": "paketli", "Pasta": "paketli",
    "Soda": "paketli", "Tea": "paketli", "Water": "paketli",
}

# ──────────────────────────────────────────────
# Güven Skoru Eşiği
# ──────────────────────────────────────────────
CONFIDENCE_THRESHOLD = 0.70   # Altındaysa "bilinmeyen ürün" döner

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

# İngilizce ad → Türkçe ad (TR_TO_EN_PRODUCT_MAP'ten otomatik üretilir)
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
