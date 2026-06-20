"""
CyberShield SOS Service
─────────────────────────
trigger_sos  → creates Incident, LocationLog, generates case_id, notifies police + guardians via SMS
cancel_sos   → marks cancelled
"""

import random
import string
from uuid import UUID

from sqlalchemy.orm import Session

from app.models import Incident, LocationLog
from app.services.notification_service import notify_sos_alert, create_notification


def _generate_case_id() -> str:
    """Generate AHM-SOS-XXXXX case ID."""
    suffix = "".join(random.choices(string.digits, k=5))
    return f"AHM-SOS-{suffix}"


def trigger_sos(
    db: Session,
    user_id: UUID,
    lat: float,
    lng: float,
    is_silent: bool = False,
) -> Incident:
    """
    Create an active SOS incident, log the location, send all notifications.
    Returns the committed Incident ORM object.
    """
    case_id = _generate_case_id()

    incident = Incident(
        user_id=user_id,
        case_id=case_id,
        type="sos",
        status="active",
        lat=lat,
        lng=lng,
        is_silent=is_silent,
    )
    db.add(incident)
    db.flush()  # get incident.id before commit

    db.add(LocationLog(incident_id=incident.id, lat=lat, lng=lng))
    db.commit()
    db.refresh(incident)

    # Notify police dashboard (DB) + send SMS to guardians
    notify_sos_alert(db, incident)

    return incident


def cancel_sos(db: Session, incident_id: UUID, user_id: UUID) -> Incident | None:
    """Cancel an active SOS by the user who triggered it."""
    incident = db.query(Incident).filter(
        Incident.id == incident_id,
        Incident.user_id == user_id,
    ).first()
    if not incident:
        return None
    incident.status = "cancelled"
    db.commit()
    db.refresh(incident)
    return incident
