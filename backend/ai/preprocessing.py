"""
ColdAI — Görüntü Ön-İşleme (TFLite)

Gelen görüntüyü model inference için hazırlar.

ÖNEMLİ: TFLite modelleri, Keras modellerindeki Rescaling(1./255) katmanını
İÇERMEZ. Bu nedenle piksel değerleri burada 0-1 aralığına normalize
edilir (float32). Eğer modelleriniz uint8 giriş bekliyorsa,
normalizasyon adımını kaldırın.
"""

import numpy as np
from PIL import Image
from io import BytesIO
from backend.config import IMG_SIZE


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Görüntüyü TFLite model girişi için hazırla.

    İşlem adımları:
    1. Byte verisinden PIL Image oluştur
    2. RGB'ye dönüştür (RGBA, grayscale vb. desteği)
    3. 224×224 boyutuna resize et
    4. float32 numpy array'e dönüştür
    5. 0-1 aralığına normalize et (Rescaling 1./255)
    6. Batch boyutu ekle: (224,224,3) → (1,224,224,3)

    NOT: TFLite modelleri Rescaling katmanı içermez,
    bu yüzden normalizasyon burada yapılır.

    Args:
        image_bytes: Ham görüntü byte verisi (JPEG, PNG, WebP)

    Returns:
        (1, 224, 224, 3) şeklinde float32 numpy array (0-1 aralığı)
    """
    image = Image.open(BytesIO(image_bytes))
    image = image.convert("RGB")
    image = image.resize(IMG_SIZE, Image.Resampling.LANCZOS)

    # float32'ye dönüştür ve 0-1 aralığına normalize et
    img_array = np.array(image, dtype=np.float32) / 255.0

    # Batch boyutu ekle
    img_array = np.expand_dims(img_array, axis=0)

    return img_array
