from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class UserCreate(BaseModel):
    name: str
    mobile: str
    email: Optional[EmailStr] = None
    password: str = Field(min_length=6)


class UserLogin(BaseModel):
    mobile: str
    password: str


class OTPVerify(BaseModel):
    mobile: str
    otp: str


class OTPSendRequest(BaseModel):
    mobile: str


class UserResponse(BaseModel):
    id: UUID
    name: str
    mobile: str
    email: Optional[str] = None
    role: str
    created_at: datetime

    class Config:
        from_attributes = True


class RegisterResponse(BaseModel):
    user: UserResponse
    message: str = "Registration successful. Please verify OTP."


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
