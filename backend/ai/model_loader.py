"""
ColdAI — Keras Model Loader

Singleton pattern ile modelleri belleğe yükler ve cache'ler.
İlk istek geldiğinde lazy loading yapar, sonraki isteklerde
cache'ten döndürür. Uygulama başlangıcında preload_all() ile
tüm modeller önceden yüklenebilir.
"""

import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

import tensorflow as tf
from backend.config import MODEL_PATHS, MAIN_CATEGORIES, PRODUCT_CLASSES
import logging

logger = logging.getLogger(__name__)

def build_coldai_model(model_key: str, num_classes: int) -> tf.keras.Model:
    """
    Modelleri kod ile yeniden inşa eder.
    Her modelin eğitim adımındaki spesifik Dense ve Dropout oranlarını uygular.
    """
    # Base model: MobileNetV2 (weights=None kullanıyoruz, pretrained indirmesin)
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(224, 224, 3), 
        include_top=False, 
        weights=None
    )
    base_model.trainable = False
    
    # 🔥 Modele göre mimariyi belirle
    if model_key == "main":
        dense_units = 128
        dropout_rate = 0.2
    elif model_key == "meyve":
        dense_units = 256
        dropout_rate = 0.3
    elif model_key == "sebze":
        dense_units = 256
        dropout_rate = 0.4
    elif model_key == "paketli":
        dense_units = 512
        dropout_rate = 0.5
    else:
        raise ValueError(f"Bilinmeyen model tipi: {model_key}")
        
    model = tf.keras.Sequential([
        tf.keras.layers.Rescaling(1./255, input_shape=(224, 224, 3)),
        base_model,
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.Dense(dense_units, activation='relu'),
        tf.keras.layers.Dropout(dropout_rate),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    return model


class ModelCache:
    """Singleton cache for loaded Keras models."""

    _instance = None
    _models: dict[str, tf.keras.Model] = {}

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._models = {}
        return cls._instance

    def get_model(self, model_key: str) -> tf.keras.Model:
        """
        Modeli cache'ten döndür. Yüklenmemişse yükle.

        Args:
            model_key: "main", "meyve", "sebze" veya "paketli"

        Returns:
            Yüklenmiş Keras modeli

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

            # Kaç sınıflı model yükleyeceğimizi bulalım
            if model_key == "main":
                num_classes = len(MAIN_CATEGORIES)
            else:
                num_classes = len(PRODUCT_CLASSES.get(model_key, []))

            # Sınıf sayısını config'den al
            if model_key == "main":
                num_classes_config = len(MAIN_CATEGORIES)
            else:
                num_classes_config = len(PRODUCT_CLASSES.get(model_key, []))

            logger.info(f"Model inşa ediliyor: {model_key} (Config beklenen: {num_classes_config} sınıf) — {path}")
            
            try:
                # Önce config'deki sayıyla dene
                model = build_coldai_model(model_key, num_classes_config)
                model.load_weights(str(path))
            except ValueError as e:
                error_msg = str(e)
                # Gelen tensor hatasından actual class sayısını (eğitilmiş ağırlıktaki gerçek sayıyı) çek
                # Örnek: "variable.shape=(256, 10), Received: value.shape=(256, 9)"
                import re
                match = re.search(r"Received: value\.shape=\(\d+, (\d+)\)", error_msg)
                if match:
                    actual_classes = int(match.group(1))
                    logger.critical(
                        f"🚨 KRİTİK UYARI 🚨\n"
                        f"{model_key} modeli için config.py'de {num_classes_config} sınıf tanımlı, "
                        f"ANCAK model {actual_classes} sınıfla eğitilmiş!\n"
                        f"Çökmeyi önlemek için {actual_classes} sınıfla çalıştırılıyor. "
                        f"Klasörlerden biri eksik olabilir. Lütfen config.py veya dataset'ini eşitle!"
                    )
                    # Gerçek sayıyla yeniden inşa et
                    model = build_coldai_model(model_key, actual_classes)
                    model.load_weights(str(path))
                else:
                    raise e
            
            self._models[model_key] = model
            logger.info(f"Model ağırlıkları başarıyla yüklendi: {model_key}")

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
