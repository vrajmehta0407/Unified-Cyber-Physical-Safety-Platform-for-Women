import secrets
from datetime import datetime, timedelta

import bcrypt
from jose import JWTError, jwt

from app.config import get_settings

settings = get_settings()
ALGORITHM = "HS256"

_otp_store: dict[str, tuple[str, datetime]] = {}


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))


def create_access_token(subject: str) -> str:
    expire = datetime.utcnow() + timedelta(days=7)
    return jwt.encode({"sub": subject, "exp": expire}, settings.SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> str | None:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
        return payload.get("sub")
    except JWTError:
        return None


def generate_otp(mobile: str) -> str:
    otp = f"{secrets.randbelow(900000) + 100000}"
    _otp_store[mobile] = (otp, datetime.utcnow() + timedelta(seconds=settings.OTP_EXPIRY_SECONDS))
    return otp


def verify_otp(mobile: str, otp: str) -> bool:
    stored = _otp_store.get(mobile)
    if not stored:
        return False
    stored_otp, expiry = stored
    if datetime.utcnow() > expiry:
        del _otp_store[mobile]
        return False
    if stored_otp == otp:
        del _otp_store[mobile]
        return True
    return False
