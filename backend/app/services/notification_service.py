import logging

from sqlalchemy.orm import Session

from app.models import Incident, Notification, User

logger = logging.getLogger("cybershield.notifications")


def notify_sos_alert(db: Session, incident: Incident) -> None:
    """Create a DB notification for all police/admin users about an SOS alert."""
    logger.info(f"[NOTIFY] SOS alert: incident={incident.id} at ({incident.lat}, {incident.lng})")

    # Get the victim's name for the notification
    victim = db.query(User).filter(User.id == incident.user_id).first()
    victim_name = victim.name if victim else "Unknown"

    # Notify all police and admin users
    police_users = db.query(User).filter(User.role.in_(("police", "admin"))).all()
    for user in police_users:
        notification = Notification(
            user_id=user.id,
            title="🚨 SOS Alert Triggered",
            body=f"Emergency SOS from {victim_name} at ({incident.lat}, {incident.lng}). Immediate response required.",
        )
        db.add(notification)

    # Also notify the user's guardians (confirmation notification)
    user_notification = Notification(
        user_id=incident.user_id,
        title="SOS Alert Sent",
        body="Your emergency SOS has been received. Help is on the way. Stay safe.",
    )
    db.add(user_notification)
    db.commit()
    logger.info(f"[NOTIFY] Notified {len(police_users)} officers + user for incident {incident.id}")


def create_notification(db: Session, user_id, title: str, body: str) -> Notification:
    """Create a single notification for a specific user."""
    notification = Notification(
        user_id=user_id,
        title=title,
        body=body,
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification
