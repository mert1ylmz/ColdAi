"""
ColdAI — Fuzzy Text Matching (Bulanık Metin Eşleştirme)

Fiş satırlarındaki ürün isimlerini tutulacaklar listesiyle eşleştirir.
İki aşamalı eşleştirme:
  1. Direkt eşleşme: TR_TO_EN_PRODUCT_MAP'te birebir arama
  2. Fuzzy eşleşme: rapidfuzz ile Levenshtein mesafesi (≥80% benzerlik)

Örnek:
  "domates" → {"product": "Tomato", "match_score": 100}
  "domats"  → {"product": "Tomato", "match_score": 85}
  "xyz123"  → None (eşleşme yok)
"""

from rapidfuzz import fuzz, process
import logging

from backend.config import (
    TR_TO_EN_PRODUCT_MAP,
    EN_TO_CATEGORY,
    FUZZY_MATCH_THRESHOLD,
)

logger = logging.getLogger(__name__)

# İngilizce ürün listesi (büyük-harfli → orijinal eşleştirme için)
_ALL_EN_PRODUCTS = list(EN_TO_CATEGORY.keys())
_ALL_EN_LOWER = [p.lower() for p in _ALL_EN_PRODUCTS]


def match_product(
    text: str,
    threshold: int | None = None,
) -> dict | None:
    """
    Tek bir metin satırını bilinen ürünlerle eşleştir.

    Args:
        text: Eşleştirilecek metin (fiş satırı)
        threshold: Minimum benzerlik skoru (0-100), varsayılan 80

    Returns:
        Eşleşme bulunursa:
          {product, product_tr, category, match_score, source}
        Bulunamazsa: None
    """
    if threshold is None:
        threshold = FUZZY_MATCH_THRESHOLD

    normalized = text.lower().strip()
    if not normalized:
        return None

    # ── 1. Direkt eşleşme (Türkçe sözlük) ──
    if normalized in TR_TO_EN_PRODUCT_MAP:
        product = TR_TO_EN_PRODUCT_MAP[normalized]
        return {
            "product": product,
            "product_tr": normalized,
            "category": EN_TO_CATEGORY.get(product),
            "match_score": 100,
            "source": text,
        }

    # ── 2. Fuzzy eşleşme (Türkçe sözlük) ──
    tr_result = process.extractOne(
        normalized,
        TR_TO_EN_PRODUCT_MAP.keys(),
        scorer=fuzz.ratio,
        score_cutoff=threshold,
    )

    if tr_result:
        matched_key, score, _ = tr_result
        product = TR_TO_EN_PRODUCT_MAP[matched_key]
        return {
            "product": product,
            "product_tr": matched_key,
            "category": EN_TO_CATEGORY.get(product),
            "match_score": int(score),
            "source": text,
        }

    # ── 3. Fuzzy eşleşme (İngilizce isimler — çift dilli fişler için) ──
    en_result = process.extractOne(
        normalized,
        _ALL_EN_LOWER,
        scorer=fuzz.ratio,
        score_cutoff=threshold,
    )

    if en_result:
        _, score, idx = en_result
        product = _ALL_EN_PRODUCTS[idx]
        return {
            "product": product,
            "product_tr": None,
            "category": EN_TO_CATEGORY.get(product),
            "match_score": int(score),
            "source": text,
        }

    logger.debug(f"Eşleşme bulunamadı: '{text}'")
    return None


def match_receipt_products(lines: list[str]) -> list[dict]:
    """
    Birden fazla fiş satırını eşleştir.
    Aynı ürün birden fazla satırda geçiyorsa sadece ilk eşleşmeyi al.

    Args:
        lines: Temizlenmiş fiş satırları listesi

    Returns:
        Eşleşen ürünlerin listesi
    """
    matches = []
    seen_products: set[str] = set()

    for line in lines:
        result = match_product(line)
        if result and result["product"] not in seen_products:
            matches.append(result)
            seen_products.add(result["product"])

    logger.info(
        f"Fuzzy match: {len(lines)} satırdan {len(matches)} ürün eşleştirildi"
    )
    return matches
