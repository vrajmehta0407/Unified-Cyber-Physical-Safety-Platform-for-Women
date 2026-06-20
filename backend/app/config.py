from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # ── Database ─────────────────────────────────────────────────────────────
    DATABASE_URL: str = "sqlite:///./cybershield.db"
    SECRET_KEY: str = "dev-secret-key-change-in-production"

    # ── OTP ──────────────────────────────────────────────────────────────────
    OTP_EXPIRY_SECONDS: int = 300

    # ── AI Engine ────────────────────────────────────────────────────────────
    AI_ENGINE_URL: str = "http://localhost:8001"

    # ── AWS S3 Evidence Storage ───────────────────────────────────────────────
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_S3_BUCKET: str = "cybershield-evidence"
    AWS_REGION: str = "ap-south-1"
    EVIDENCE_STORAGE: str = "local"   # local | s3 | cloudinary
    EVIDENCE_ENCRYPTION_KEY: str = "32-byte-aes-key-change-in-prod!!"

    # ── Firebase ─────────────────────────────────────────────────────────────
    FIREBASE_CREDENTIALS_PATH: str = ""
    FIREBASE_DATABASE_URL: str = ""
    FIREBASE_PROJECT_ID: str = "cybershield-ahmedabad"
    FCM_SERVER_KEY: str = ""

    # ── Twilio SMS / WhatsApp ─────────────────────────────────────────────────
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_PHONE_NUMBER: str = ""
    TWILIO_WHATSAPP_NUMBER: str = ""            # e.g. +14155238886

    # ── External ─────────────────────────────────────────────────────────────
    ERSS_WEBHOOK_URL: str = "http://localhost:9000/erss/alert"
    GOOGLE_MAPS_API_KEY: str = ""

    # ── CORS ─────────────────────────────────────────────────────────────────
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:5173"

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

    model_config = {"env_file": ".env", "extra": "ignore"}


@lru_cache
def get_settings() -> Settings:
    return Settings()


# Convenient module-level alias
settings = get_settings()
