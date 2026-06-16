"""
ColdAI — AI Görüntü Tahmin API Route'ları

Endpoint:
  POST /api/v1/predict → Görüntüden ürün tanıma (EfficientNetV2B0 tek geçiş)
"""

from fastapi import APIRouter, UploadFile, File, HTTPException
from backend.ai.inference import predict_product
from backend.api.schemas import PredictResponse

router = APIRouter(prefix="/api/v1", tags=["AI Prediction"])

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


@router.post("/predict", response_model=PredictResponse)
async def predict(image: UploadFile = File(...)):
    """
    Görüntüden ürün tanıma.

    **EfficientNetV2B0 tek geçiş pipeline:**
    - Tek model 25 sınıfı doğrudan tahmin eder.
    - Kategori bilgisi (meyve / sebze / paketli) `config.EN_TO_CATEGORY`'den türetilir.

    **Güvenlik katmanı:**
    - Güven skoru eşik değerinin altındaysa `is_known=false` döner.

    **Desteklenen formatlar:** JPEG, PNG, WebP (maks. 10MB)
    """
    # Dosya formatı kontrolü
    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Desteklenmeyen dosya formatı: {image.content_type}. "
                f"Desteklenen: JPEG, PNG, WebP"
            ),
        )

    # Dosya boyutu kontrolü
    image_bytes = await image.read()
    if len(image_bytes) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail="Dosya boyutu 10MB'dan büyük olamaz",
        )

    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Boş dosya gönderildi")

    # Inference pipeline
    result = await predict_product(image_bytes)
    return PredictResponse(**result)
