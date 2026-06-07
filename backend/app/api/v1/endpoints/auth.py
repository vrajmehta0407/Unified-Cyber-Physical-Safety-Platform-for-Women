from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import User
from app.schemas.user_schema import (
    OTPSendRequest,
    OTPVerify,
    RegisterResponse,
    TokenResponse,
    UserCreate,
    UserLogin,
    UserResponse,
)
from app.services.auth_service import (
    create_access_token,
    generate_otp,
    hash_password,
    verify_otp,
    verify_password,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
def register(data: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.mobile == data.mobile).first():
        raise HTTPException(status_code=400, detail="Mobile already registered")
    if data.email and db.query(User).filter(User.email == data.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    user = User(
        name=data.name,
        mobile=data.mobile,
        email=data.email,
        password_hash=hash_password(data.password),
        role="user",
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    generate_otp(data.mobile)
    return RegisterResponse(user=user)


@router.post("/login", response_model=TokenResponse)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.mobile == data.mobile).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(str(user.id))
    return TokenResponse(access_token=token, user=user)


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.post("/otp/send")
def send_otp(data: OTPSendRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.mobile == data.mobile).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    otp = generate_otp(data.mobile)
    return {"message": "OTP sent successfully", "otp_dev_only": otp}


@router.post("/otp/verify", response_model=TokenResponse)
def verify_otp_endpoint(data: OTPVerify, db: Session = Depends(get_db)):
    if not verify_otp(data.mobile, data.otp):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    user = db.query(User).filter(User.mobile == data.mobile).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    token = create_access_token(str(user.id))
    return TokenResponse(access_token=token, user=user)
