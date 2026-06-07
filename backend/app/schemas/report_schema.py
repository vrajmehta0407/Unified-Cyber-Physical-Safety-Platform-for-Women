from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class ReportCreate(BaseModel):
    category: str
    description: str


class ReportResponse(BaseModel):
    id: UUID
    user_id: UUID
    category: str
    description: str
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class ReportUpdateCreate(BaseModel):
    message: str
    updated_by: str
