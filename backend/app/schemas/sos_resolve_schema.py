from pydantic import BaseModel
from uuid import UUID


class SOSResolveRequest(BaseModel):
    incident_id: UUID

