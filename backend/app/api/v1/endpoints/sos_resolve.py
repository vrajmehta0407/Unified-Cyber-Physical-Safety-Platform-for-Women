"""
CyberShield — SOS Resolve Endpoint
────────────────────────────────────
POST /sos/resolve/{incident_id}  → Victim or police can mark SOS as resolved.
                                    Sends guardian SMS confirming victim is safe.
"""
import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import User
from app.schemas.sos_schema import SOSResponse
from app.services.sos_service_resolve import resolve_sos

logger = logging.getLogger("cybershield.sos")
router = APIRouter(prefix="/sos", tags=["SOS"])


@router.post("/resolve/{incident_id}", response_model=SOSResponse)
def resolve_sos_endpoint(
    incident_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Mark an SOS incident as resolved.
    - The victim (incident owner) can call this to say "I'm Safe".
    - Police / admin can also resolve any incident.
    Sends SMS to all guardians confirming the victim is safe.
    """
    from uuid import UUID
    try:
        uid = UUID(incident_id)
    except ValueError:
        raise HTTPException(status_code=422, detail="Invalid incident ID format")

    incident = resolve_sos(db, uid, current_user)
    if not incident:
        raise HTTPException(
            status_code=404,
            detail="Incident not found or you do not have permission to resolve it",
        )
    logger.info(f"[SOS] Incident {incident.case_id or incident_id} resolved by {current_user.name} (role={current_user.role})")
    return incident
