"""
ColdAI — Görüntü Ön-İşleme (EfficientNetV2B0)

Gelen görüntüyü model inference için hazırlar.

ÖNEMLİ: EfficientNetV2B0, include_preprocessing=True ile eğitildi.
Normalizasyon (rescaling) modelin içindeki ilk katmanda gerçekleşir.
Bu nedenle buradan ham 0-255 uint8 piksel değerleri gönderilmeli;
dışarıda normalizasyon yapılmamalıdır.
"""

import numpy as np
from PIL import Image
from io import BytesIO
from backend.config import IMG_SIZE


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Görüntüyü EfficientNetV2B0 model girişi için hazırla.

    İşlem adımları:
    1. Byte verisinden PIL Image oluştur
    2. RGB'ye dönüştür (RGBA, grayscale vb. desteği)
    3. 224×224 boyutuna resize et
    4. uint8 numpy array'e dönüştür (0-255, normalizasyon YOK)
    5. Batch boyutu ekle: (224,224,3) → (1,224,224,3)

    NOT: EfficientNetV2B0 include_preprocessing=True ile eğitildiğinden
    model kendi içinde rescaling uygular. Burada /255 yapılmamalıdır;
    aksi hâlde model 0-1 aralığını 0-255 olarak yorumlar ve her şeyi
    yanlış sınıflandırır.

    Args:
        image_bytes: Ham görüntü byte verisi (JPEG, PNG, WebP)

    Returns:
        (1, 224, 224, 3) şeklinde uint8 numpy array (0-255 aralığı)
    """
    image = Image.open(BytesIO(image_bytes))
    image = image.convert("RGB")
    image = image.resize(IMG_SIZE, Image.Resampling.LANCZOS)

    # uint8 olarak tut — normalizasyon modelin içinde yapılır
    img_array = np.array(image, dtype=np.uint8)

    # Batch boyutu ekle
    img_array = np.expand_dims(img_array, axis=0)

    return img_array
