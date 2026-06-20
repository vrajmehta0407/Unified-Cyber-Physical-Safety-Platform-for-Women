from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class IncidentResponse(BaseModel):
    id: UUID
    user_id: UUID
    case_id: Optional[str] = None
    type: str
    status: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    address: Optional[str] = None
    is_silent: bool
    assigned_officer_name: Optional[str] = None
    created_at: datetime
    resolved_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class IncidentWithUserResponse(IncidentResponse):
    user_name: str
    user_mobile: str


class IncidentUpdate(BaseModel):
    status: Optional[str] = None
    assigned_officer: Optional[str] = None