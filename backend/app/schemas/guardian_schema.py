from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class GuardianCreate(BaseModel):
    name: str
    phone: str
    relation: Optional[str] = None


class GuardianResponse(BaseModel):
    id: UUID
    user_id: UUID
    name: str
    phone: str
    relation: Optional[str]

    class Config:
        from_attributes = True
