"""
ColdAI — Tesseract OCR Motor Wrapper

Market fişi görüntülerinden metin çıkarır.
Türkçe + İngilizce dil desteği ile çalışır.
"""

import pytesseract
from PIL import Image, ImageFilter
from io import BytesIO
import logging

from backend.config import TESSERACT_CMD, OCR_LANG

logger = logging.getLogger(__name__)

# Tesseract yolunu ayarla (PATH'te değilse)
if TESSERACT_CMD:
    pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD


def extract_text(image_bytes: bytes) -> str:
    """
    Görüntüden metin çıkar.

    Ön-işleme adımları:
    1. RGB'ye dönüştür
    2. Gri tonlamaya çevir (OCR doğruluğu için)
    3. Hafif keskinleştirme uygula
    4. Tesseract ile metin çıkar

    Args:
        image_bytes: Ham görüntü byte verisi

    Returns:
        Çıkarılan ham metin
    """
    image = Image.open(BytesIO(image_bytes))
    image = image.convert("RGB")

    # OCR doğruluğunu artırmak için gri tonlama + keskinleştirme
    gray = image.convert("L")
    sharpened = gray.filter(ImageFilter.SHARPEN)

    text = pytesseract.image_to_string(sharpened, lang=OCR_LANG)
    logger.info(f"OCR: {len(text)} karakter çıkarıldı")

    return text
