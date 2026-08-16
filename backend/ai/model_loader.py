"""
ColdAI — TFLite Model Loader

Singleton pattern ile TFLite modellerini belleğe yükler ve cache'ler.
İlk istek geldiğinde lazy loading yapar, sonraki isteklerde
cache'ten döndürür. Uygulama başlangıcında preload_all() ile
tüm modeller önceden yüklenebilir.
"""

import numpy as np
import logging

try:
    # Önce hafif tflite-runtime paketini dene
    import tflite_runtime.interpreter as tflite
    Interpreter = tflite.Interpreter
except ImportError:
    # Yoksa tam TensorFlow'dan TFLite interpreter'ı al
    import tensorflow as tf
    Interpreter = tf.lite.Interpreter

from backend.config import MODEL_PATHS

logger = logging.getLogger(__name__)


class TFLiteModel:
    """Tek bir TFLite modelini saran wrapper sınıf."""

    def __init__(self, model_path: str, model_key: str):
        self.model_key = model_key
        self.interpreter = Interpreter(model_path=str(model_path))
        self.interpreter.allocate_tensors()

        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

        input_shape = self.input_details[0]['shape']
        output_shape = self.output_details[0]['shape']

        logger.info(
            f"TFLite model yüklendi: {model_key} — "
            f"giriş: {input_shape}, çıkış: {output_shape}"
        )

    def predict(self, img_array: np.ndarray) -> np.ndarray:
        """
        TFLite modeli ile tahmin yap.

        Args:
            img_array: (1, 224, 224, 3) şeklinde float32 numpy array

        Returns:
            Softmax çıktı vektörü (1D array)
        """
        # Giriş verisinin dtype'ını modelin beklediğiyle eşle
        input_dtype = self.input_details[0]['dtype']
        if img_array.dtype != input_dtype:
            img_array = img_array.astype(input_dtype)

        self.interpreter.set_tensor(self.input_details[0]['index'], img_array)
        self.interpreter.invoke()

        output = self.interpreter.get_tensor(self.output_details[0]['index'])
        return output[0]  # Batch boyutunu kaldır


class ModelCache:
    """Singleton cache for loaded TFLite models."""

    _instance = None
    _models: dict[str, TFLiteModel] = {}

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._models = {}
        return cls._instance

    def get_model(self, model_key: str) -> TFLiteModel:
        """
        Modeli cache'ten döndür. Yüklenmemişse yükle.

        Args:
            model_key: "main", "meyve", "sebze" veya "paketli"

        Returns:
            Yüklenmiş TFLiteModel instance

        Raises:
            FileNotFoundError: Model dosyası bulunamazsa
            ValueError: Geçersiz model anahtarı
        """
        if model_key not in self._models:
            path = MODEL_PATHS.get(model_key)
            if path is None:
                raise ValueError(
                    f"Geçersiz model anahtarı: '{model_key}'. "
                    f"Geçerli anahtarlar: {list(MODEL_PATHS.keys())}"
                )
            if not path.exists():
                raise FileNotFoundError(
                    f"Model dosyası bulunamadı: {path}"
                )

            logger.info(f"TFLite model yükleniyor: {model_key} — {path}")
            self._models[model_key] = TFLiteModel(str(path), model_key)

        return self._models[model_key]

    def preload_all(self) -> None:
        """Tüm modelleri başlangıçta belleğe yükle."""
        for key in MODEL_PATHS:
            self.get_model(key)
        logger.info(
            f"Tüm modeller yüklendi: {list(MODEL_PATHS.keys())} "
            f"(toplam {len(self._models)} model)"
        )

    def is_loaded(self, model_key: str) -> bool:
        """Model cache'te mevcut mu?"""
        return model_key in self._models


# Global singleton instance
model_cache = ModelCache()
