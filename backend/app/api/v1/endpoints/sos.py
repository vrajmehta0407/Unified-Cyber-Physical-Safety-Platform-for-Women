from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import Incident, User
from app.schemas.incident_schema import IncidentWithUserResponse
from app.schemas.sos_schema import SOSCancelRequest, SOSResponse, SOSTriggerRequest
from app.services.erss_service import dispatch_erss_alert
from app.services.sos_service import cancel_sos, trigger_sos

router = APIRouter(prefix="/sos", tags=["SOS"])


@router.get("/active", response_model=list[IncidentWithUserResponse])
def list_active_sos(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role not in ("admin", "police"):
        return []
    rows = (
        db.query(Incident, User)
        .join(User, Incident.user_id == User.id)
        .filter(Incident.type == "sos", Incident.status == "active")
        .order_by(Incident.created_at.desc())
        .all()
    )
    return [
        IncidentWithUserResponse(
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
        for inc, user in rows
    ]


@router.post("/trigger", response_model=SOSResponse)
def trigger_sos_endpoint(
    data: SOSTriggerRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = trigger_sos(db, current_user.id, data.lat, data.lng, data.is_silent)
    dispatch_erss_alert(data.lat, data.lng)
    return incident


@router.post("/cancel", response_model=SOSResponse)
def cancel_sos_endpoint(
    data: SOSCancelRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = cancel_sos(db, data.incident_id, current_user.id)
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return incident


@router.get("/status/{incident_id}", response_model=SOSResponse)
def get_sos_status(
    incident_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    from app.models import Incident
    incident = db.query(Incident).filter(
        Incident.id == incident_id, Incident.user_id == current_user.id
    ).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return incident
