from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class IncidentResponse(BaseModel):
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


class IncidentWithUserResponse(IncidentResponse):
    user_name: str
    user_mobile: str


class IncidentUpdate(BaseModel):
    status: Optional[str] = None
    assigned_officer: Optional[str] = None