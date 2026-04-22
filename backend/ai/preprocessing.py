"""
ColdAI — Görüntü Ön-İşleme

Gelen görüntüyü model inference için hazırlar.

ÖNEMLİ: Modeller Rescaling(1./255) katmanını içerdiğinden
burada normalizasyon YAPILMAZ. Ham piksel değerleri (0-255)
float32 olarak modele verilir.
"""

import numpy as np
from PIL import Image
from io import BytesIO
from backend.config import IMG_SIZE


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Görüntüyü model girişi için hazırla.

    İşlem adımları:
    1. Byte verisinden PIL Image oluştur
    2. RGB'ye dönüştür (RGBA, grayscale vb. desteği)
    3. 224×224 boyutuna resize et
    4. float32 numpy array'e dönüştür (0-255 aralığı korunur)
    5. Batch boyutu ekle: (224,224,3) → (1,224,224,3)

    NOT: Normalizasyon YAPILMAZ — model içinde Rescaling(1./255) var.

    Args:
        image_bytes: Ham görüntü byte verisi (JPEG, PNG, WebP)

    Returns:
        (1, 224, 224, 3) şeklinde float32 numpy array
    """
    image = Image.open(BytesIO(image_bytes))
    image = image.convert("RGB")
    image = image.resize(IMG_SIZE, Image.Resampling.LANCZOS)

    # float32'ye dönüştür — Rescaling katmanı 0-255 aralığını bekler
    img_array = np.array(image, dtype=np.float32)

    # Batch boyutu ekle
    img_array = np.expand_dims(img_array, axis=0)

    return img_array
