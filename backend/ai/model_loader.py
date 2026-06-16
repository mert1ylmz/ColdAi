"""
ColdAI — Keras Model Loader

Singleton pattern ile EfficientNetV2B0 modelini belleğe yükler.
Uygulama başlangıcında preload() çağrılır; sonraki tüm istekler
cache'ten model alır — her istekte disk okuması yapılmaz.
"""

import numpy as np
import logging
import tensorflow as tf

from backend.config import MODEL_PATH, IMG_SIZE

logger = logging.getLogger(__name__)


class KerasModel:
    """EfficientNetV2B0 Keras modelini saran wrapper."""

    def __init__(self, model_path):
        if not model_path.exists():
            raise FileNotFoundError(f"Model dosyası bulunamadı: {model_path}")

        logger.info(f"Keras model yükleniyor: {model_path}")
        self.model = tf.keras.models.load_model(str(model_path), compile=False)

        logger.info(
            f"Model yüklendi — "
            f"giriş: {self.model.input_shape}, çıkış: {self.model.output_shape}"
        )

    def predict(self, img_array: np.ndarray) -> np.ndarray:
        """
        Tek görüntü için softmax olasılık vektörü döndürür.

        Args:
            img_array: (1, 224, 224, 3) uint8 veya float32 numpy array.
                       Model include_preprocessing=True ile eğitildiğinden
                       ham 0-255 değerleri gönderilebilir.

        Returns:
            25 elemanlı softmax çıktı vektörü (1D array).
        """
        probs = self.model.predict(img_array, verbose=0)
        return probs[0]


class ModelCache:
    """Singleton: tek model instance'ı uygulama boyunca paylaşılır."""

    _instance = None
    _model: KerasModel | None = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def preload(self) -> None:
        """Uygulamanın başlangıcında modeli yükle."""
        if self._model is None:
            self._model = KerasModel(MODEL_PATH)
            logger.info("✅ EfficientNetV2B0 belleğe yüklendi")

    def get_model(self) -> KerasModel:
        """Yüklenmiş model instance'ını döndür."""
        if self._model is None:
            self.preload()
        return self._model

    @property
    def is_loaded(self) -> bool:
        return self._model is not None


# Global singleton instance
model_cache = ModelCache()
