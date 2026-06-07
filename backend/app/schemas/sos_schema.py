from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class SOSTriggerRequest(BaseModel):
    lat: float
    lng: float
    is_silent: bool = False


class SOSCancelRequest(BaseModel):
    incident_id: UUID


class SOSResponse(BaseModel):
    id: UUID
    user_id: UUID
    type: str
    status: str
    lat: Optional[float]
    lng: Optional[float]
    is_silent: bool
    created_at: datetime

    class Config:
        from_attributes = True
