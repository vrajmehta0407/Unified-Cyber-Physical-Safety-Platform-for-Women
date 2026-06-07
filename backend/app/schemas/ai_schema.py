from typing import Optional

from pydantic import BaseModel


class PhishingRequest(BaseModel):
    url: str
    text: Optional[str] = None


class FakeProfileRequest(BaseModel):
    username: str
    platform: str = "instagram"
    profile_data: Optional[dict] = None


class DeepfakeRequest(BaseModel):
    file_hash: str
    mime_type: str


class AIResultResponse(BaseModel):
    scan_type: str
    risk_score: float
    verdict: str
    details: dict
    message: str
