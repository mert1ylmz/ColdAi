"""
ColdAI — İki Aşamalı Expert Model Inference Pipeline

Akış:
  Görüntü → Ön-İşleme → Ana Model → Kategori (meyve/sebze/paketli)
                                        ↓
                          Güven ≥ 0.65?  → Hayır → "Bilinmeyen Kategori"
                                        ↓ Evet
                          Alt Model → Ürün Tahmini
                                        ↓
                          Güven ≥ 0.70?  → Hayır → "Bilinmeyen Ürün"
                                        ↓ Evet
                          Sonuç: {kategori, ürün, skor}
"""

import asyncio
import numpy as np
import logging

from backend.ai.model_loader import model_cache
from backend.ai.preprocessing import preprocess_image
from backend.ai.confidence import check_confidence
from backend.config import (
    PRODUCT_CLASSES,
    MAIN_CATEGORIES,
    MAIN_MODEL_THRESHOLD,
    SUB_MODEL_THRESHOLD,
    TOP2_GAP_THRESHOLD,
    EN_TO_TR,
)

logger = logging.getLogger(__name__)


def _run_inference(model_key: str, img_array: np.ndarray) -> np.ndarray:
    """
    Senkron model inference.
    TensorFlow predict() CPU-bound olduğundan ayrı thread'de çalıştırılır.
    """
    model = model_cache.get_model(model_key)
    predictions = model.predict(img_array, verbose=0)
    return predictions[0]  # Batch boyutunu kaldır


async def predict_product(image_bytes: bytes) -> dict:
    """
    İki aşamalı Expert Model inference pipeline.

    Args:
        image_bytes: Ham görüntü byte verisi

    Returns:
        dict: {
            success, category, product, product_tr,
            confidence, is_known, message, stage_failed
        }
    """
    # ── Ön-İşleme ──
    img_array = preprocess_image(image_bytes)

    # ══════════════════════════════════════════
    # AŞAMA 1: Kategori Tahmini (Ana Model)
    # ══════════════════════════════════════════
    main_probs = await asyncio.to_thread(_run_inference, "main", img_array)

    is_confident, main_confidence, reason = check_confidence(
        main_probs, MAIN_MODEL_THRESHOLD, TOP2_GAP_THRESHOLD
    )

    if not is_confident:
        logger.warning(f"Ana model güvensiz: {reason}")
        return {
            "success": True,
            "category": None,
            "product": None,
            "product_tr": None,
            "confidence": round(main_confidence, 4),
            "is_known": False,
            "message": "Ürün kategorisi yeterli güvenle belirlenemedi. Lütfen tekrar deneyin.",
            "stage_failed": "category",
        }

    category_idx = int(np.argmax(main_probs))
    category = MAIN_CATEGORIES[category_idx]
    logger.info(
        f"Aşama 1 — Kategori: {category} "
        f"(güven: {main_confidence:.3f}, indeks: {category_idx})"
    )

    # ══════════════════════════════════════════
    # AŞAMA 2: Ürün Tahmini (Alt Model)
    # ══════════════════════════════════════════
    sub_probs = await asyncio.to_thread(_run_inference, category, img_array)

    is_confident, sub_confidence, reason = check_confidence(
        sub_probs, SUB_MODEL_THRESHOLD, TOP2_GAP_THRESHOLD
    )

    if not is_confident:
        logger.warning(f"Alt model ({category}) güvensiz: {reason}")
        return {
            "success": True,
            "category": category,
            "product": None,
            "product_tr": None,
            "confidence": round(sub_confidence, 4),
            "is_known": False,
            "message": (
                f"Kategori '{category}' olarak belirlendi "
                f"ancak ürün yeterli güvenle tanınamadı."
            ),
            "stage_failed": "product",
        }

    product_idx = int(np.argmax(sub_probs))
    product_name = PRODUCT_CLASSES[category][product_idx]
    product_tr = EN_TO_TR.get(product_name, product_name)

    logger.info(
        f"Aşama 2 — Ürün: {product_name} ({product_tr}) "
        f"(güven: {sub_confidence:.3f}, indeks: {product_idx})"
    )

    return {
        "success": True,
        "category": category,
        "product": product_name,
        "product_tr": product_tr,
        "confidence": round(sub_confidence, 4),
        "is_known": True,
        "message": None,
        "stage_failed": None,
    }
