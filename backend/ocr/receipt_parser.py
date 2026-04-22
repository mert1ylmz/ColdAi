"""
ColdAI — Market Fişi Satır Ayıklayıcı

OCR'dan çıkan ham metni temizler, fiyat/vergi/başlık satırlarını
filtreler ve potansiyel ürün isimlerini çıkarır.
"""

import re
import logging

logger = logging.getLogger(__name__)

# Atlanacak satır kalıpları
_SKIP_PATTERNS = [
    r"^\s*$",                                   # Boş satırlar
    r"^\s*[\d.,]+\s*$",                         # Sadece sayı (fiyat)
    r"(?i)toplam|total|ara\s?toplam|subtotal",  # Toplam satırları
    r"(?i)kdv|vergi|tax",                       # Vergi satırları
    r"(?i)fatura|fi[sş]|receipt",               # Fiş başlığı
    r"(?i)tarih|date|saat|time",                # Tarih/saat
    r"(?i)tel|phone|adres|address",             # İletişim
    r"(?i)te[sş]ekk[uü]r|thanks|ho[sş]\s?geldin",  # Teşekkür
    r"(?i)market|ma[gğ]aza|store|[sş]ube",      # Mağaza adı
    r"(?i)kasa|pos|terminal|barkod",             # POS bilgisi
    r"^\s*[-=*_]{3,}\s*$",                       # Ayırıcı çizgiler
    r"(?i)nakit|cash|kart|card|visa|master",     # Ödeme yöntemi
    r"(?i)para\s?üstü|change|iade",              # Para üstü
    r"(?i)kampanya|indirim|discount",            # İndirim
    r"(?i)fiş\s?no|işlem\s?no|ref",              # İşlem numarası
]


def parse_receipt_lines(raw_text: str) -> list[str]:
    """
    Ham OCR metninden potansiyel ürün satırlarını çıkar.

    İşlem adımları:
    1. Satırlara böl
    2. Fiyat, vergi, başlık vb. satırları filtrele
    3. Fiyat ve miktar ek bilgilerini temizle
    4. En az 2 karakter olan satırları döndür

    Args:
        raw_text: OCR'dan çıkan ham metin

    Returns:
        Temizlenmiş potansiyel ürün satırları listesi
    """
    lines = raw_text.strip().split("\n")
    cleaned = []

    for line in lines:
        line = line.strip()
        if not line:
            continue

        # Atlanacak kalıpları kontrol et
        should_skip = False
        for pattern in _SKIP_PATTERNS:
            if re.search(pattern, line):
                should_skip = True
                break

        if should_skip:
            continue

        # Satır sonundaki fiyat bilgilerini temizle
        # "DOMATES 2.50 KG  15.00" → "DOMATES"
        cleaned_line = re.sub(
            r"\s+[\d.,]+\s*(TL|₺|KG|kg|AD|ad|LT|lt|ML|ml|GR|gr)?\s*$",
            "",
            line,
        )

        # Satır başındaki miktar bilgisini temizle
        # "2 x ELMA" → "ELMA"
        cleaned_line = re.sub(r"^\d+\s*[xX*]\s*", "", cleaned_line)

        # Ağırlık/birim eklerini temizle
        cleaned_line = re.sub(
            r"\s+\d+[.,]?\d*\s*(kg|gr|lt|ml|ad)\s*$",
            "",
            cleaned_line,
            flags=re.IGNORECASE,
        )

        # Yıldız (*) ve diğer işaretleri temizle
        cleaned_line = re.sub(r"[*%#]", "", cleaned_line)

        cleaned_line = cleaned_line.strip()

        # En az 2 karakter olmalı
        if len(cleaned_line) >= 2:
            cleaned.append(cleaned_line)

    logger.info(f"Fiş parse: {len(lines)} satırdan {len(cleaned)} ürün adayı çıkarıldı")
    return cleaned
