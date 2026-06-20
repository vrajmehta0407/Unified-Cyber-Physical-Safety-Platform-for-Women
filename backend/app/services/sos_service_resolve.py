"""
CyberShield SOS Resolve Service
─────────────────────────────────
resolve_sos → marks incident resolved, notifies guardians via SMS.
Allows both the victim (user_id match) and police/admin to resolve.
"""
from datetime import datetime
from uuid import UUID

from sqlalchemy.orm import Session

from app.models import Incident, User


def resolve_sos(db: Session, incident_id: UUID, requesting_user: User) -> Incident | None:
    """
    Resolve an SOS incident.
    - The victim themselves can resolve (user_id match).
    - Police / admin can also resolve any incident.
    Returns the updated Incident or None if not found / access denied.
    """
    query = db.query(Incident).filter(Incident.id == incident_id)

    if requesting_user.role not in ("admin", "police"):
        # Regular user — can only resolve their own incidents
        query = query.filter(Incident.user_id == requesting_user.id)

    incident = query.first()
    if not incident:
        return None

    incident.status = "resolved"
    incident.resolved_at = datetime.utcnow()
    db.commit()
    db.refresh(incident)

    # Notify guardians that victim is safe
    try:
        from app.services.notification_service import notify_sos_resolved
        notify_sos_resolved(db, incident)
    except Exception:
        pass  # Best-effort; don't fail the resolve

    return incident
