"""
ColdAI — FastAPI Uygulama Entry Point

Uygulama başlangıcında:
  1. Veritabanı tablolarını oluşturur
  2. 28 ürünü seed eder
  3. Tüm AI modellerini belleğe yükler

Çalıştırma:
  uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

Swagger UI:
  http://localhost:8000/docs
"""

import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.db.database import init_db, async_session
from backend.db.crud import seed_products
from backend.config import CLASS_NAMES, TR_TO_EN_PRODUCT_MAP
from backend.ai.model_loader import model_cache

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Uygulama başlangıç ve kapanış olayları."""

    # ── Startup ──
    logger.info("🚀 ColdAI Backend başlatılıyor...")

    # 1. Veritabanı
    await init_db()
    logger.info("✅ Veritabanı tabloları oluşturuldu")

    # 2. Ürün seed
    async with async_session() as db:
        await seed_products(db, CLASS_NAMES, TR_TO_EN_PRODUCT_MAP)
    logger.info("✅ Ürünler veritabanına eklendi")

    # 3. AI modeli
    logger.info("⏳ EfficientNetV2B0 yükleniyor (bu biraz sürebilir)...")
    model_cache.preload()
    logger.info("✅ Model hazır")

    logger.info("🟢 ColdAI Backend çalışıyor — http://localhost:8000/docs")

    yield

    # ── Shutdown ──
    logger.info("👋 ColdAI Backend kapatılıyor...")


# ──────────────────────────────────────────────
# FastAPI Uygulaması
# ──────────────────────────────────────────────

app = FastAPI(
    title="ColdAI — Buzdolabı Asistanı API",
    description=(
        "Akıllı buzdolabı stok yönetimi.\n\n"
        "**Özellikler:**\n"
        "- 📸 Kamera ile ürün tanıma (EfficientNetV2B0, 25 sınıf — tek geçiş)\n"
        "- 🧾 Fiş okuma (Tesseract OCR + Fuzzy Matching)\n"
        "- 📦 Envanter yönetimi (CRUD)\n"
        "- 🔐 JWT kimlik doğrulama\n\n"
        "**Desteklenen Ürünler:** 9 meyve, 7 sebze, 9 paketli ürün"
    ),
    version="1.0.0",
    lifespan=lifespan,
)

# CORS — Frontend'in erişebilmesi için
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Production'da spesifik origin'ler kullanın
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ──────────────────────────────────────────────
# Router Kaydı
# ──────────────────────────────────────────────

from backend.api.routes_auth import router as auth_router        # noqa: E402
from backend.api.routes_image import router as image_router      # noqa: E402
from backend.api.routes_ocr import router as ocr_router          # noqa: E402
from backend.api.routes_inventory import router as inventory_router  # noqa: E402

app.include_router(auth_router)
app.include_router(image_router)
app.include_router(ocr_router)
app.include_router(inventory_router)


# ──────────────────────────────────────────────
# Health Check
# ──────────────────────────────────────────────

@app.get("/", tags=["Health"])
async def root():
    """API durum kontrolü."""
    return {
        "service": "ColdAI Backend",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "endpoints": {
            "predict": "POST /api/v1/predict",
            "ocr": "POST /api/v1/ocr/receipt",
            "products": "GET /api/v1/products",
            "inventory": "GET /api/v1/inventory",
            "auth": "POST /api/v1/auth/register",
        },
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Basit sağlık kontrolü."""
    return {"status": "healthy"}
