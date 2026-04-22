"""
ColdAI — ORM Modelleri

Tablolar:
  - users: Kullanıcı hesapları
  - products: 28 tanınan ürün (seed data ile doldurulur)
  - inventory_items: Kullanıcı buzdolabı envanteri
"""

import enum
from sqlalchemy import (
    Column, Integer, String, Float, Date, DateTime, ForeignKey,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.db.database import Base


class SourceType(str, enum.Enum):
    """Ürünün envantere eklenme kaynağı."""
    CAMERA = "camera"
    RECEIPT = "receipt"
    MANUAL = "manual"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    inventory_items = relationship("InventoryItem", back_populates="user")

    def __repr__(self):
        return f"<User(id={self.id}, email='{self.email}')>"


class Product(Base):
    """
    28 tanınan ürün.
    Uygulama başlangıcında PRODUCT_CLASSES sözlüğünden seed edilir.
    """
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)      # "Tomato"
    name_tr = Column(String, nullable=True)                              # "domates"
    category = Column(String, nullable=False)                            # "sebze"
    default_shelf_life_days = Column(Integer, nullable=True)

    inventory_items = relationship("InventoryItem", back_populates="product")

    def __repr__(self):
        return f"<Product(id={self.id}, name='{self.name}', category='{self.category}')>"


class InventoryItem(Base):
    """Kullanıcının buzdolabındaki bir ürün kaydı."""
    __tablename__ = "inventory_items"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    quantity = Column(Integer, default=1)
    added_date = Column(Date, server_default=func.current_date())
    expiry_date = Column(Date, nullable=True)
    source = Column(String, default=SourceType.MANUAL.value)
    confidence_score = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="inventory_items")
    product = relationship("Product", back_populates="inventory_items")

    def __repr__(self):
        return (
            f"<InventoryItem(id={self.id}, user={self.user_id}, "
            f"product={self.product_id}, qty={self.quantity})>"
        )
