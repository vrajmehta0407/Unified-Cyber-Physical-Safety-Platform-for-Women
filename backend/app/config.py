from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://cybershield:cybershield@localhost:5432/cybershield"
    SECRET_KEY: str = "dev-secret-key"
    OTP_EXPIRY_SECONDS: int = 300
    AI_ENGINE_URL: str = "http://localhost:8001"
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_S3_BUCKET: str = "cybershield-evidence"
    AWS_REGION: str = "ap-south-1"
    FIREBASE_CREDENTIALS_PATH: str = ""
    FIREBASE_DATABASE_URL: str = ""
    ERSS_WEBHOOK_URL: str = "http://localhost:9000/erss/alert"
    EVIDENCE_ENCRYPTION_KEY: str = "32-byte-aes-key-change-in-prod!!"
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:5173"
    GOOGLE_MAPS_API_KEY: str = "2c80c85112844ac39395276829d3937d"
    FCM_SERVER_KEY: str = ""
    FIREBASE_PROJECT_ID: str = "cybershield-ahmedabad"
    EVIDENCE_STORAGE: str = "local"  # "local" | "s3" | "cloudinary"


    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

    class Config:
        env_file = ".env"
        extra = "ignore"


@lru_cache
def get_settings() -> Settings:
    return Settings()


# Convenient module-level alias
settings = get_settings()

