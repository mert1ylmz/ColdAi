"""
ColdAI — SQLAlchemy Async Veritabanı Bağlantısı

Development: SQLite (aiosqlite)
Production: PostgreSQL (asyncpg) — DATABASE_URL ile değiştirilebilir
"""

from sqlalchemy.ext.asyncio import (
    create_async_engine,
    async_sessionmaker,
    AsyncSession,
)
from sqlalchemy.orm import DeclarativeBase
from backend.config import DATABASE_URL

engine = create_async_engine(DATABASE_URL, echo=False)

async_session = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    """Tüm ORM modelleri için temel sınıf."""
    pass


async def get_db():
    """FastAPI dependency — her istek için yeni session oluştur."""
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()


async def init_db():
    """Veritabanı tablolarını oluştur (yoksa)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
