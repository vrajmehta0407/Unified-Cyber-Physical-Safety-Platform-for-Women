from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class EvidenceResponse(BaseModel):
    id: UUID
    incident_id: Optional[UUID] = None
    user_id: UUID
    file_path: str
    original_filename: Optional[str] = None
    hash: str
    mime_type: Optional[str] = None
    file_size: Optional[int] = None
    court_admissible: Optional[bool] = False
    verified: Optional[bool] = True
    timestamp: datetime

    class Config:
        from_attributes = True


class EvidenceUploadResponse(BaseModel):
    evidence: EvidenceResponse
    message: str


class EvidenceReviewRequest(BaseModel):
    court_admissible: Optional[bool] = None
    verified: Optional[bool] = None
    custody_action: Optional[str] = None
    custody_actor: Optional[str] = None


class ChainOfCustodyResponse(BaseModel):
    id: UUID
    evidence_id: UUID
    action: str
    actor: str
    timestamp: datetime

    class Config:
        from_attributes = True
