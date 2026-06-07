from uuid import UUID

from sqlalchemy.orm import Session

from app.models import Incident, LocationLog, Notification
from app.services.notification_service import notify_sos_alert


def trigger_sos(db: Session, user_id: UUID, lat: float, lng: float, is_silent: bool = False) -> Incident:
    incident = Incident(
        user_id=user_id,
        type="sos",
        status="active",
        lat=lat,
        lng=lng,
        is_silent=is_silent,
    )
    db.add(incident)
    db.flush()

    location_log = LocationLog(incident_id=incident.id, lat=lat, lng=lng)
    db.add(location_log)

    db.commit()
    db.refresh(incident)

    # Create notifications for all police/admin users and confirmation for victim
    notify_sos_alert(db, incident)
    return incident


def cancel_sos(db: Session, incident_id: UUID, user_id: UUID) -> Incident | None:
    incident = db.query(Incident).filter(
        Incident.id == incident_id, Incident.user_id == user_id
    ).first()
    if not incident:
        return None
    incident.status = "cancelled"
    db.commit()
    db.refresh(incident)
    return incident
