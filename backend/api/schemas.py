"""
ColdAI — Pydantic Request/Response Şemaları

Tüm API endpoint'leri için giriş/çıkış veri doğrulama modelleri.
Swagger /docs üzerinde otomatik dökümantasyon sağlar.
"""

from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional


# ════════════════════════════════════════════
# AUTH — Kimlik Doğrulama
# ════════════════════════════════════════════

class UserCreate(BaseModel):
    """Yeni kullanıcı kayıt isteği."""
    email: str
    password: str
    full_name: Optional[str] = None


class UserResponse(BaseModel):
    """Kullanıcı bilgi yanıtı."""
    id: int
    email: str
    full_name: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class LoginRequest(BaseModel):
    """Giriş yapma isteği."""
    email: str
    password: str


class TokenResponse(BaseModel):
    """JWT token yanıtı."""
    access_token: str
    token_type: str = "bearer"


# ════════════════════════════════════════════
# PRODUCT — Ürün Bilgisi
# ════════════════════════════════════════════

class ProductResponse(BaseModel):
    """Tanınan ürün bilgisi."""
    id: int
    name: str
    name_tr: Optional[str]
    category: str
    default_shelf_life_days: Optional[int]

    class Config:
        from_attributes = True


# ════════════════════════════════════════════
# PREDICT — AI Tahmin Sonucu
# ════════════════════════════════════════════

class PredictResponse(BaseModel):
    """
    İki aşamalı AI tahmin yanıtı.

    is_known=True  → Ürün başarıyla tanındı
    is_known=False → Düşük güven veya bilinmeyen nesne
    """
    success: bool
    category: Optional[str] = None
    product: Optional[str] = None
    product_tr: Optional[str] = None
    confidence: Optional[float] = None
    is_known: bool
    message: Optional[str] = None
    stage_failed: Optional[str] = None


# ════════════════════════════════════════════
# OCR — Fiş Okuma Sonucu
# ════════════════════════════════════════════

class OCRMatchItem(BaseModel):
    """Fişte eşleşen tek bir ürün."""
    product: str
    product_tr: Optional[str]
    category: Optional[str]
    match_score: int
    source: str


class OCRResponse(BaseModel):
    """Fiş okuma ve eşleştirme sonucu."""
    success: bool
    raw_text: str
    matched_products: list[OCRMatchItem]
    unmatched_lines: list[str]


# ════════════════════════════════════════════
# INVENTORY — Envanter Yönetimi
# ════════════════════════════════════════════

class InventoryItemCreate(BaseModel):
    """Envantere ürün ekleme isteği."""
    product_name: str
    quantity: int = 1
    expiry_date: Optional[date] = None
    source: str = "manual"
    confidence_score: Optional[float] = None


class InventoryItemUpdate(BaseModel):
    """Envanter öğesi güncelleme isteği."""
    quantity: Optional[int] = None
    expiry_date: Optional[date] = None


class InventoryItemResponse(BaseModel):
    """Envanter öğesi yanıtı."""
    id: int
    product_name: str
    product_name_tr: Optional[str]
    category: str
    quantity: int
    added_date: Optional[date]
    expiry_date: Optional[date]
    source: str
    confidence_score: Optional[float]
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True
