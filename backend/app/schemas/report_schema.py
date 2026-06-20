from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class ReportCreate(BaseModel):
    category: str
    description: str
    priority: Optional[str] = "medium"
    accused_platform: Optional[str] = None
    accused_username: Optional[str] = None
    accused_phone: Optional[str] = None
    accused_profile_url: Optional[str] = None
    witness_name: Optional[str] = None
    witness_contact: Optional[str] = None


class ReportUpdateRequest(BaseModel):
    status: Optional[str] = None
    priority: Optional[str] = None
    assigned_officer: Optional[str] = None
    notes: Optional[str] = None
    fir_status: Optional[str] = None


class ReportResponse(BaseModel):
    id: UUID
    user_id: UUID
    complaint_number: Optional[str] = None
    category: str
    description: str
    status: str
    priority: Optional[str] = "medium"
    assigned_officer: Optional[str] = None
    accused_platform: Optional[str] = None
    accused_username: Optional[str] = None
    accused_phone: Optional[str] = None
    accused_profile_url: Optional[str] = None
    nccrp_submitted: Optional[bool] = False
    fir_status: Optional[str] = "none"
    resolved_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class ReportUpdateCreate(BaseModel):
    message: str
    updated_by: str


class ReportStatsResponse(BaseModel):
    total: int
    by_status: dict
    by_category: dict
    by_priority: dict
