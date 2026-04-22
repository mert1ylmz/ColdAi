"""
ColdAI — Kimlik Doğrulama API Route'ları

Endpoint'ler:
  POST /api/v1/auth/register  → Yeni kullanıcı kaydı
  POST /api/v1/auth/login     → Giriş yapma (JWT token döner)
  GET  /api/v1/auth/me        → Mevcut kullanıcı bilgisi
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from jose import JWTError, jwt
from datetime import datetime, timedelta, timezone

from backend.db.database import get_db
from backend.db import crud
from backend.api.schemas import (
    UserCreate, UserResponse, LoginRequest, TokenResponse,
)
from backend.config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def create_access_token(data: dict) -> str:
    """JWT access token oluştur."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
):
    """JWT token'dan mevcut kullanıcıyı çöz. Dependency olarak kullanılır."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Geçersiz kimlik bilgileri",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = await crud.get_user_by_id(db, user_id)
    if user is None:
        raise credentials_exception

    return user


# ──────────────────────────────────────────────
# Route'lar
# ──────────────────────────────────────────────

@router.post("/register", response_model=UserResponse, status_code=201)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    """Yeni kullanıcı kaydı oluştur."""
    existing = await crud.get_user_by_email(db, user_data.email)
    if existing:
        raise HTTPException(
            status_code=400,
            detail="Bu e-posta adresi zaten kayıtlı",
        )

    user = await crud.create_user(
        db, user_data.email, user_data.password, user_data.full_name
    )
    return user


@router.post("/login", response_model=TokenResponse)
async def login(login_data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Giriş yap ve JWT token al."""
    user = await crud.get_user_by_email(db, login_data.email)
    if not user:
        raise HTTPException(status_code=401, detail="Geçersiz e-posta veya şifre")

    if not crud.verify_password(login_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Geçersiz e-posta veya şifre")

    token = create_access_token(data={"sub": user.id})
    return TokenResponse(access_token=token)


@router.get("/me", response_model=UserResponse)
async def get_me(current_user=Depends(get_current_user)):
    """Mevcut kullanıcı bilgilerini döndür."""
    return current_user
