"""
CyberShield — Incident Endpoints
──────────────────────────────────
GET    /incidents/              → List incidents (police=all, user=own)
GET    /incidents/{id}          → Single incident detail
PATCH  /incidents/{id}          → Update status
PUT    /incidents/{id}/assign   → Assign officer + generate case_id
PUT    /incidents/{id}/resolve  → Resolve with officer note
"""

import logging
import random
import string
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import CyberReport, Incident, Officer, User
from app.schemas.incident_schema import IncidentResponse, IncidentUpdate, IncidentWithUserResponse
from app.services.notification_service import notify_sos_resolved
from app.utils.db_helpers import _id

logger = logging.getLogger("cybershield.incidents")
router = APIRouter(prefix="/incidents", tags=["Incidents"])


# ─── Inline schemas ──────────────────────────────────────────────────────────
class AssignOfficerRequest(BaseModel):
    officer_id: str | None = None
    officer_name: str | None = None       # fallback if no officer_id


class ResolveRequest(BaseModel):
    resolution_note: str | None = None
    status: str = "resolved"              # resolved | false_alarm | cancelled


# ─── Helpers ─────────────────────────────────────────────────────────────────
def _require_police(user: User) -> None:
    if user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")


def _generate_case_id() -> str:
    """Generate AHM-SOS-XXXXX style case ID."""
    suffix = "".join(random.choices(string.digits, k=5))
    return f"AHM-SOS-{suffix}"


def _build_incident_response(inc: Incident, user: User) -> IncidentWithUserResponse:
    return IncidentWithUserResponse(
        id=inc.id,
        user_id=inc.user_id,
        type=inc.type,
        status=inc.status,
        lat=inc.lat,
        lng=inc.lng,
        is_silent=inc.is_silent,
        created_at=inc.created_at,
        user_name=user.name,
        user_mobile=user.mobile,
    )


# ─── GET /incidents/ ─────────────────────────────────────────────────────────
@router.get("/", response_model=list[IncidentWithUserResponse])
def list_incidents(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role in ("admin", "police"):
        rows = (
            db.query(Incident, User)
            .join(User, Incident.user_id == User.id)
            .order_by(Incident.created_at.desc())
            .limit(100)
            .all()
        )
        return [_build_incident_response(inc, user) for inc, user in rows]

    incidents = (
        db.query(Incident)
        .filter(Incident.user_id == current_user.id)
        .order_by(Incident.created_at.desc())
        .all()
    )
    return [_build_incident_response(inc, current_user) for inc in incidents]


# ─── GET /incidents/{incident_id} ────────────────────────────────────────────
@router.get("/{incident_id}", response_model=IncidentWithUserResponse)
def get_incident(
    incident_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    row = (
        db.query(Incident, User)
        .join(User, Incident.user_id == User.id)
        .filter(Incident.id == _id(incident_id))
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Incident not found")
    inc, user = row
    if current_user.role not in ("admin", "police") and inc.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    return _build_incident_response(inc, user)


# ─── PATCH /incidents/{incident_id} ──────────────────────────────────────────
@router.patch("/{incident_id}", response_model=IncidentResponse)
def update_incident(
    incident_id: str,
    data: IncidentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_police(current_user)
    incident = db.query(Incident).filter(Incident.id == _id(incident_id)).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    if data.status:
        incident.status = data.status
        if data.status in ("resolved", "false_alarm", "cancelled"):
            incident.resolved_at = datetime.utcnow()
    db.commit()
    db.refresh(incident)
    return incident


# ─── PUT /incidents/{incident_id}/assign ─────────────────────────────────────
@router.put("/{incident_id}/assign")
def assign_officer(
    incident_id: str,
    data: AssignOfficerRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Dispatch an officer to an active SOS. Generates case_id if not set."""
    _require_police(current_user)
    incident = db.query(Incident).filter(Incident.id == _id(incident_id)).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Resolve officer name
    officer_name = data.officer_name or current_user.name
    if data.officer_id:
        officer = db.query(Officer).filter(Officer.id == _id(data.officer_id)).first()
        if officer:
            officer_name = officer.full_name
            incident.assigned_officer_id = officer.id
            officer.cases_assigned = (officer.cases_assigned or 0) + 1

    incident.assigned_officer_name = officer_name
    incident.status = "responding"

    # Generate case_id on first assignment

    if not incident.case_id:
        incident.case_id = _generate_case_id()

    db.commit()
    db.refresh(incident)
    logger.info(f"[INCIDENT] {incident.case_id} assigned to {officer_name}")

    return {
        "success": True,
        "case_id": incident.case_id,
        "status": incident.status,
        "assigned_officer": officer_name,
        "message": f"Officer {officer_name} dispatched to incident {incident.case_id}",
    }


# ─── PUT /incidents/{incident_id}/resolve ────────────────────────────────────
@router.put("/{incident_id}/resolve")
def resolve_incident(
    incident_id: str,
    data: ResolveRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Resolve an SOS. Sends guardian SMS confirming victim is safe."""
    _require_police(current_user)
    incident = db.query(Incident).filter(Incident.id == _id(incident_id)).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    incident.status = data.status
    incident.resolved_at = datetime.utcnow()
    db.commit()

    # Notify guardians that victim is safe
    try:
        notify_sos_resolved(db, incident)
    except Exception as exc:
        logger.warning(f"[NOTIFY] resolve notification failed: {exc}")

    logger.info(f"[INCIDENT] {incident.case_id or incident_id} resolved by {current_user.name}")
    return {
        "success": True,
        "status": data.status,
        "case_id": incident.case_id,
        "resolved_at": incident.resolved_at.isoformat(),
        "message": f"Incident closed as '{data.status}'",
    }
