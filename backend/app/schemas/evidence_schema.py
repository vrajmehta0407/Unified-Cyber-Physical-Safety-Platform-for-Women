from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class EvidenceResponse(BaseModel):
    id: UUID
    incident_id: Optional[UUID]
    user_id: UUID
    file_path: str
    hash: str
    mime_type: Optional[str]
    timestamp: datetime

    class Config:
        from_attributes = True


class EvidenceUploadResponse(BaseModel):
    evidence: EvidenceResponse
    message: str
