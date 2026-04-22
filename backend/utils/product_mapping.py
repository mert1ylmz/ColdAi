"""
ColdAI — Ürün Yardımcı Fonksiyonları

Ürün adı → kategori çözümleme, ürün listesi sorgulama vb.
"""

from backend.config import PRODUCT_CLASSES, EN_TO_CATEGORY, EN_TO_TR


def get_all_products_flat() -> list[dict]:
    """
    Tüm 28 ürünü düz liste olarak döndür.

    Returns:
        [{"name": "Apple", "name_tr": "elma", "category": "meyve"}, ...]
    """
    products = []
    for category, names in PRODUCT_CLASSES.items():
        for name in names:
            products.append({
                "name": name,
                "name_tr": EN_TO_TR.get(name),
                "category": category,
            })
    return products


def get_category(product_name: str) -> str | None:
    """Ürün adından kategori bul."""
    return EN_TO_CATEGORY.get(product_name)


def is_known_product(product_name: str) -> bool:
    """Ürünün 28 tanınan üründen biri olup olmadığını kontrol et."""
    return product_name in EN_TO_CATEGORY


def get_products_by_category(category: str) -> list[str]:
    """Kategoriye göre ürün listesi döndür."""
    return PRODUCT_CLASSES.get(category, [])
