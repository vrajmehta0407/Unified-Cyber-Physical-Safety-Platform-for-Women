from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import CyberReport, Incident, User
from app.schemas.incident_schema import IncidentResponse, IncidentUpdate, IncidentWithUserResponse

router = APIRouter(prefix="/incidents", tags=["Incidents"])


def _require_police(user: User) -> None:
    if user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")


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

    incidents = db.query(Incident).filter(Incident.user_id == current_user.id).all()
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
            user_name=current_user.name,
            user_mobile=current_user.mobile,
        )
        for inc in incidents
    ]


@router.get("/{incident_id}", response_model=IncidentWithUserResponse)
def get_incident(incident_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    row = (
        db.query(Incident, User)
        .join(User, Incident.user_id == User.id)
        .filter(Incident.id == incident_id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="Incident not found")
    inc, user = row
    if current_user.role not in ("admin", "police") and inc.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
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


@router.patch("/{incident_id}", response_model=IncidentResponse)
def update_incident(
    incident_id: str,
    data: IncidentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_police(current_user)
    incident = db.query(Incident).filter(Incident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    if data.status:
        incident.status = data.status
    db.commit()
    db.refresh(incident)
    return incident
