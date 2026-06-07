from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import LocationLog, User

router = APIRouter(prefix="/tracking", tags=["Tracking"])


@router.post("/live")
def update_live_location(
    incident_id: UUID,
    lat: float,
    lng: float,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    log = LocationLog(incident_id=incident_id, lat=lat, lng=lng)
    db.add(log)
    db.commit()
    return {"message": "Location updated"}


@router.get("/history/{incident_id}")
def get_tracking_history(
    incident_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    logs = (
        db.query(LocationLog)
        .filter(LocationLog.incident_id == incident_id)
        .order_by(LocationLog.timestamp)
        .all()
    )
    return [{"lat": l.lat, "lng": l.lng, "timestamp": l.timestamp.isoformat()} for l in logs]
