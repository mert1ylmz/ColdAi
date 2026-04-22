"""
ColdAI — Veritabanı CRUD Operasyonları
"""

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from passlib.context import CryptContext
from datetime import date

from backend.db.models import User, Product, InventoryItem

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ════════════════════════════════════════════
# USER CRUD
# ════════════════════════════════════════════

async def create_user(
    db: AsyncSession,
    email: str,
    password: str,
    full_name: str | None = None,
) -> User:
    """Yeni kullanıcı oluştur."""
    hashed = pwd_context.hash(password)
    user = User(email=email, hashed_password=hashed, full_name=full_name)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    """E-posta ile kullanıcı bul."""
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def get_user_by_id(db: AsyncSession, user_id: int) -> User | None:
    """ID ile kullanıcı bul."""
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Şifre doğrulama (senkron — bcrypt CPU-bound)."""
    return pwd_context.verify(plain_password, hashed_password)


# ════════════════════════════════════════════
# PRODUCT CRUD
# ════════════════════════════════════════════

async def get_all_products(db: AsyncSession) -> list[Product]:
    """Tüm 28 ürünü listele."""
    result = await db.execute(
        select(Product).order_by(Product.category, Product.name)
    )
    return list(result.scalars().all())


async def get_product_by_name(db: AsyncSession, name: str) -> Product | None:
    """İngilizce isim ile ürün bul."""
    result = await db.execute(select(Product).where(Product.name == name))
    return result.scalar_one_or_none()


async def seed_products(
    db: AsyncSession,
    product_classes: dict[str, list[str]],
    tr_map: dict[str, str],
) -> None:
    """
    PRODUCT_CLASSES sözlüğündeki 28 ürünü veritabanına ekle.
    Zaten mevcutsa atla.
    """
    # EN → TR ters eşleştirme (ilk eşleşmeyi al)
    en_to_tr: dict[str, str] = {}
    for tr_name, en_name in tr_map.items():
        if en_name not in en_to_tr:
            en_to_tr[en_name] = tr_name

    for category, products in product_classes.items():
        for product_name in products:
            existing = await get_product_by_name(db, product_name)
            if existing is None:
                product = Product(
                    name=product_name,
                    name_tr=en_to_tr.get(product_name),
                    category=category,
                )
                db.add(product)

    await db.commit()


# ════════════════════════════════════════════
# INVENTORY CRUD
# ════════════════════════════════════════════

async def get_user_inventory(
    db: AsyncSession,
    user_id: int,
) -> list[InventoryItem]:
    """Kullanıcının buzdolabı envanterini listele (ürün detaylarıyla)."""
    result = await db.execute(
        select(InventoryItem)
        .where(InventoryItem.user_id == user_id)
        .options(selectinload(InventoryItem.product))
        .order_by(InventoryItem.created_at.desc())
    )
    return list(result.scalars().all())


async def add_inventory_item(
    db: AsyncSession,
    user_id: int,
    product_id: int,
    quantity: int = 1,
    expiry_date: date | None = None,
    source: str = "manual",
    confidence_score: float | None = None,
) -> InventoryItem:
    """Envantere yeni ürün ekle."""
    item = InventoryItem(
        user_id=user_id,
        product_id=product_id,
        quantity=quantity,
        expiry_date=expiry_date,
        source=source,
        confidence_score=confidence_score,
    )
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


async def update_inventory_item(
    db: AsyncSession,
    item_id: int,
    user_id: int,
    **kwargs,
) -> InventoryItem | None:
    """Envanter öğesi güncelle. Sadece sahibi güncelleyebilir."""
    result = await db.execute(
        select(InventoryItem).where(
            InventoryItem.id == item_id,
            InventoryItem.user_id == user_id,
        )
    )
    item = result.scalar_one_or_none()
    if item is None:
        return None

    for key, value in kwargs.items():
        if hasattr(item, key) and value is not None:
            setattr(item, key, value)

    await db.commit()
    await db.refresh(item)
    return item


async def delete_inventory_item(
    db: AsyncSession,
    item_id: int,
    user_id: int,
) -> bool:
    """Envanter öğesi sil. Sadece sahibi silebilir."""
    result = await db.execute(
        select(InventoryItem).where(
            InventoryItem.id == item_id,
            InventoryItem.user_id == user_id,
        )
    )
    item = result.scalar_one_or_none()
    if item is None:
        return False

    await db.delete(item)
    await db.commit()
    return True
