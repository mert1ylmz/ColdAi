"""
ColdAI — EfficientNetV2B0 Tek Geçiş Inference Pipeline

Eski iki aşamalı mimari (ana model → alt model) iptal edildi.
Tek model 25 sınıfı doğrudan tahmin eder; kategori bilgisi
config.py'deki EN_TO_CATEGORY tablosundan türetilir.

Akış:
    Görüntü → Ön-İşleme → EfficientNetV2B0 → Softmax → Sonuç
"""

import asyncio
import numpy as np
import logging

from backend.ai.model_loader import model_cache
from backend.ai.preprocessing import preprocess_image
from backend.config import CLASS_NAMES, EN_TO_CATEGORY, CONFIDENCE_THRESHOLD, EN_TO_TR

logger = logging.getLogger(__name__)


def _run_inference(img_array: np.ndarray) -> np.ndarray:
    """
    Senkron Keras model inference.
    model.predict() CPU-bound olduğundan ayrı thread'de çalıştırılır;
    böylece FastAPI'nin async event loop'u bloklanmaz.
    """
    model = model_cache.get_model()
    return model.predict(img_array)


async def predict_product(image_bytes: bytes) -> dict:
    """
    Tek geçiş inference pipeline.

    Args:
        image_bytes: Ham görüntü byte verisi (JPEG/PNG/WebP)

    Returns:
        dict: {
            success, category, product, product_tr,
            confidence, is_known, message
        }
    """
    img_array = preprocess_image(image_bytes)

    probs = await asyncio.to_thread(_run_inference, img_array)

    top_idx      = int(np.argmax(probs))
    confidence   = float(probs[top_idx])
    product_name = CLASS_NAMES[top_idx]
    category     = EN_TO_CATEGORY.get(product_name, "bilinmeyen")
    product_tr   = EN_TO_TR.get(product_name, product_name)

    logger.info(
        f"Tahmin: {product_name} ({product_tr}) | "
        f"kategori: {category} | güven: {confidence:.3f}"
    )

    if confidence < CONFIDENCE_THRESHOLD:
        logger.warning(f"Düşük güven ({confidence:.3f}) — eşik: {CONFIDENCE_THRESHOLD}")
        return {
            "success": True,
            "category": None,
            "product": None,
            "product_tr": None,
            "confidence": round(confidence, 4),
            "is_known": False,
            "message": "Ürün yeterli güvenle tanınamadı. Lütfen tekrar deneyin.",
        }

    return {
        "success": True,
        "category": category,
        "product": product_name,
        "product_tr": product_tr,
        "confidence": round(confidence, 4),
        "is_known": True,
        "message": None,
    }
