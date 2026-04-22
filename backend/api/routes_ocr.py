"""
ColdAI — OCR Fiş Okuma API Route'ları

Endpoint:
  POST /api/v1/ocr/receipt → Market fişi görüntüsünden ürün listesi çıkar
"""

from fastapi import APIRouter, UploadFile, File, HTTPException
from backend.ocr.engine import extract_text
from backend.ocr.receipt_parser import parse_receipt_lines
from backend.ocr.fuzzy_matcher import match_receipt_products
from backend.api.schemas import OCRResponse, OCRMatchItem

router = APIRouter(prefix="/api/v1/ocr", tags=["OCR Receipt Scanning"])

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}


@router.post("/receipt", response_model=OCRResponse)
async def scan_receipt(image: UploadFile = File(...)):
    """
    Market fişi görüntüsünden ürün listesi çıkar.

    **Pipeline:**
    1. **OCR** → Tesseract ile metin çıkarma (TR+EN)
    2. **Parse** → Fiyat, vergi, başlık satırlarını filtrele
    3. **Match** → Fuzzy matching ile TR ürün isimlerini EN sınıflarla eşleştir

    **Yanıtta:**
    - `matched_products`: Eşleşen ürünler (isim, kategori, benzerlik skoru)
    - `unmatched_lines`: Eşleştirilemeyen satırlar
    - `raw_text`: OCR'dan çıkan ham metin (debug için)
    """
    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Desteklenmeyen dosya formatı. Desteklenen: JPEG, PNG, WebP",
        )

    image_bytes = await image.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Boş dosya gönderildi")

    # 1. OCR ile metin çıkar
    raw_text = extract_text(image_bytes)

    if not raw_text.strip():
        return OCRResponse(
            success=False,
            raw_text="",
            matched_products=[],
            unmatched_lines=[],
        )

    # 2. Fiş satırlarını parse et
    lines = parse_receipt_lines(raw_text)

    # 3. Fuzzy matching ile ürün eşleştir
    matches = match_receipt_products(lines)

    # Eşleşmeyen satırları bul
    matched_sources = {m["source"].lower().strip() for m in matches}
    unmatched = [
        line for line in lines
        if line.lower().strip() not in matched_sources
    ]

    return OCRResponse(
        success=True,
        raw_text=raw_text,
        matched_products=[OCRMatchItem(**m) for m in matches],
        unmatched_lines=unmatched,
    )
