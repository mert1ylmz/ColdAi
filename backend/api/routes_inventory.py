"""
ColdAI — Envanter Yönetimi API Route'ları

Endpoint'ler:
  GET    /api/v1/products           → Tüm tanınan ürünleri listele (28 ürün)
  GET    /api/v1/inventory          → Kullanıcı envanterini listele
  POST   /api/v1/inventory          → Envantere ürün ekle
  PUT    /api/v1/inventory/{id}     → Envanter öğesi güncelle
  DELETE /api/v1/inventory/{id}     → Envanter öğesi sil
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from backend.db.database import get_db
from backend.db import crud
from backend.db.models import User
from backend.api.routes_auth import get_current_user
from backend.api.schemas import (
    InventoryItemCreate,
    InventoryItemUpdate,
    InventoryItemResponse,
    ProductResponse,
)

router = APIRouter(prefix="/api/v1", tags=["Inventory Management"])


def _item_to_response(item) -> InventoryItemResponse:
    """ORM InventoryItem → Pydantic InventoryItemResponse dönüşümü."""
    return InventoryItemResponse(
        id=item.id,
        product_name=item.product.name,
        product_name_tr=item.product.name_tr,
        category=item.product.category,
        quantity=item.quantity,
        added_date=item.added_date,
        expiry_date=item.expiry_date,
        source=item.source,
        confidence_score=item.confidence_score,
        created_at=item.created_at,
        updated_at=item.updated_at,
    )


# ──────────────────────────────────────────────
# Ürün Listesi (Public)
# ──────────────────────────────────────────────

@router.get("/products", response_model=list[ProductResponse])
async def list_products(db: AsyncSession = Depends(get_db)):
    """
    Tüm tanınan ürünleri listele.

    Toplam 28 ürün: 10 meyve, 8 sebze, 10 paketli.
    Auth gerektirmez.
    """
    return await crud.get_all_products(db)


# ──────────────────────────────────────────────
# Envanter CRUD (Auth Required)
# ──────────────────────────────────────────────

@router.get("/inventory", response_model=list[InventoryItemResponse])
async def get_inventory(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Kullanıcının buzdolabı envanterini listele."""
    items = await crud.get_user_inventory(db, current_user.id)
    return [_item_to_response(item) for item in items]


@router.post("/inventory", response_model=InventoryItemResponse, status_code=201)
async def add_to_inventory(
    item_data: InventoryItemCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Envantere ürün ekle.

    `product_name` İngilizce ürün adı olmalıdır (ör: "Tomato", "Milk").
    AI predict veya OCR sonucundaki `product` değerini kullanın.
    """
    product = await crud.get_product_by_name(db, item_data.product_name)
    if not product:
        raise HTTPException(
            status_code=404,
            detail=f"Tanınmayan ürün: '{item_data.product_name}'. "
                   f"GET /api/v1/products ile geçerli ürün listesine bakın.",
        )

    item = await crud.add_inventory_item(
        db,
        user_id=current_user.id,
        product_id=product.id,
        quantity=item_data.quantity,
        expiry_date=item_data.expiry_date,
        source=item_data.source,
        confidence_score=item_data.confidence_score,
    )

    # Relationship'i yükle
    await db.refresh(item, ["product"])
    return _item_to_response(item)


@router.put("/inventory/{item_id}", response_model=InventoryItemResponse)
async def update_inventory_item(
    item_id: int,
    update_data: InventoryItemUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Envanter öğesinin miktarını veya son kullanma tarihini güncelle."""
    item = await crud.update_inventory_item(
        db,
        item_id,
        current_user.id,
        quantity=update_data.quantity,
        expiry_date=update_data.expiry_date,
    )
    if not item:
        raise HTTPException(
            status_code=404,
            detail="Envanter öğesi bulunamadı veya size ait değil",
        )

    await db.refresh(item, ["product"])
    return _item_to_response(item)


@router.delete("/inventory/{item_id}")
async def delete_inventory_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Envanter öğesini sil."""
    success = await crud.delete_inventory_item(db, item_id, current_user.id)
    if not success:
        raise HTTPException(
            status_code=404,
            detail="Envanter öğesi bulunamadı veya size ait değil",
        )
    return {"success": True, "message": "Ürün envanterden silindi"}
