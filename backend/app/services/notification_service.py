"""
CyberShield Notification Service
─────────────────────────────────
Handles SMS (Twilio), FCM push, and in-app DB notifications.
All external calls are wrapped with graceful fallbacks so the
system continues to operate when API credentials are absent.
"""
import logging
import os
from typing import Optional

from sqlalchemy.orm import Session

from app.config import settings
from app.models import Guardian, Incident, Notification, User

logger = logging.getLogger("cybershield.notifications")

# ─── Twilio client (lazy-loaded, graceful if creds absent) ───────────────────
_twilio_client = None


def _get_twilio():
    global _twilio_client
    if _twilio_client is not None:
        return _twilio_client
    sid = settings.TWILIO_ACCOUNT_SID
    token = settings.TWILIO_AUTH_TOKEN
    if not sid or not token:
        logger.warning("[TWILIO] Credentials not set — SMS delivery disabled (dev mode)")
        return None
    try:
        from twilio.rest import Client
        _twilio_client = Client(sid, token)
        logger.info(f"[TWILIO] Client initialised successfully (SID={sid[:10]}...)")
        return _twilio_client
    except Exception as exc:
        logger.error(f"[TWILIO] Failed to initialise client: {exc}")
        return None


# ─── SMS helpers ─────────────────────────────────────────────────────────────
TWILIO_FROM = settings.TWILIO_PHONE_NUMBER
TWILIO_WA_FROM = settings.TWILIO_WHATSAPP_NUMBER


def _send_sms(to: str, body: str) -> bool:
    """Send SMS via Twilio. Returns True if sent, False on failure/no-creds."""
    client = _get_twilio()
    if not client:
        logger.info(f"[SMS-DEV] To={to} | Body={body[:80]}...")
        return False
    try:
        # Ensure E.164 format for Indian numbers
        if not to.startswith("+"):
            to = "+91" + to.lstrip("0")
        msg = client.messages.create(to=to, from_=TWILIO_FROM, body=body)
        logger.info(f"[SMS] Sent to {to} | SID={msg.sid}")
        return True
    except Exception as exc:
        logger.error(f"[SMS] Failed to send to {to}: {exc}")
        return False


def _send_whatsapp(to: str, body: str) -> bool:
    """Send WhatsApp message via Twilio. Returns True if sent."""
    client = _get_twilio()
    if not client or not TWILIO_WA_FROM:
        logger.info(f"[WA-DEV] To={to} | Body={body[:60]}...")
        return False
    try:
        if not to.startswith("+"):
            to = "+91" + to.lstrip("0")
        msg = client.messages.create(
            to=f"whatsapp:{to}",
            from_=f"whatsapp:{TWILIO_WA_FROM}",
            body=body
        )
        logger.info(f"[WhatsApp] Sent to {to} | SID={msg.sid}")
        return True
    except Exception as exc:
        logger.error(f"[WhatsApp] Failed to send to {to}: {exc}")
        return False


# ─── OTP SMS ─────────────────────────────────────────────────────────────────
def send_otp_sms(mobile: str, otp: str) -> bool:
    body = (
        f"[CyberShield] Your OTP is: {otp}\n"
        f"Valid for 5 minutes. Do NOT share this code with anyone.\n"
        f"Ahmedabad Cyber Crime Cell | Helpline: 1930"
    )
    return _send_sms(mobile, body)


# ─── Welcome SMS (after OTP verified) ────────────────────────────────────────
def send_welcome_sms(mobile: str, name: str) -> bool:
    body = (
        f"Welcome to CyberShield, {name}!\n"
        f"Your account has been verified and activated.\n"
        f"In an emergency, press SOS in the app or say your safe word.\n"
        f"Cyber Helpline: 1930 | -Ahmedabad Cyber Crime Cell"
    )
    return _send_sms(mobile, body)


# ─── SOS Alert SMS to Guardians ──────────────────────────────────────────────
def send_sos_guardian_sms(guardian_phone: str, victim_name: str,
                           lat: float, lng: float, case_id: str) -> bool:
    maps_link = f"https://maps.google.com/?q={lat},{lng}"
    body = (
        f"EMERGENCY ALERT via CyberShield\n"
        f"{victim_name} has triggered an SOS and may be in danger.\n"
        f"Live Location: {maps_link}\n"
        f"Case ID: {case_id}\n"
        f"Call them immediately or dial 100 (Police) / 1930 (Cyber).\n"
        f"-Ahmedabad Cyber Crime Cell"
    )
    return _send_sms(guardian_phone, body)


# ─── SOS Confirmation SMS to Victim ──────────────────────────────────────────
def send_sos_confirmation_sms(mobile: str, case_id: str, guardian_count: int) -> bool:
    body = (
        f"[CyberShield] Your SOS alert is active.\n"
        f"Case ID: {case_id}\n"
        f"{guardian_count} emergency contact(s) have been notified.\n"
        f"Police have been alerted. Help is on the way. Stay safe.\n"
        f"Helpline: 1930"
    )
    return _send_sms(mobile, body)


# ─── SOS Resolution SMS ──────────────────────────────────────────────────────
def send_sos_resolved_sms(guardian_phone: str, victim_name: str, case_id: str) -> bool:
    body = (
        f"[CyberShield] SAFE ALERT\n"
        f"{victim_name} is now safe. The emergency has been resolved.\n"
        f"Case ID: {case_id} has been closed.\n"
        f"Thank you for being part of their safety network. -CyberShield"
    )
    return _send_sms(guardian_phone, body)


# ─── Complaint Receipt WhatsApp ───────────────────────────────────────────────
def send_complaint_receipt_whatsapp(mobile: str, complaint_number: str, category: str) -> bool:
    body = (
        f"✅ Complaint Filed Successfully\n\n"
        f"Case ID: {complaint_number}\n"
        f"Category: {category.replace('_', ' ').title()}\n"
        f"Status: Submitted\n\n"
        f"Track your case in the CyberShield app. "
        f"For urgent help call: 1930\n"
        f"-Ahmedabad Cyber Crime Cell"
    )
    sent = _send_whatsapp(mobile, body)
    if not sent:
        # Fallback to SMS
        return _send_sms(mobile, f"Complaint {complaint_number} filed. Category: {category}. Track in CyberShield app. -ACCC")
    return sent


# ─── Guardian Added SMS ───────────────────────────────────────────────────────
def send_guardian_added_sms(guardian_phone: str, user_name: str) -> bool:
    body = (
        f"[CyberShield] {user_name} has added you as their emergency contact.\n"
        f"If they trigger an SOS, you will receive an immediate alert with their location.\n"
        f"App: CyberShield | Helpline: 1930 | -Ahmedabad Cyber Crime Cell"
    )
    return _send_sms(guardian_phone, body)


# ─── DB Notification helpers ─────────────────────────────────────────────────
def notify_sos_alert(db: Session, incident: Incident) -> None:
    """
    Create DB notifications for all police/admin users AND the victim.
    Also sends SMS to all guardians of the victim.
    """
    logger.info(f"[NOTIFY] SOS alert: incident={incident.id} lat={incident.lat} lng={incident.lng}")

    victim = db.query(User).filter(User.id == incident.user_id).first()
    victim_name = victim.name if victim else "Unknown"
    case_id = getattr(incident, "case_id", None) or str(incident.id)[:8].upper()

    # In-app DB notification for police/admin
    police_users = db.query(User).filter(User.role.in_(("police", "admin"))).all()
    for officer in police_users:
        db.add(Notification(
            user_id=officer.id,
            title="🚨 SOS Alert Triggered",
            body=(
                f"Emergency SOS from {victim_name} at "
                f"({incident.lat:.5f}, {incident.lng:.5f}). "
                f"Case: {case_id}. Immediate response required."
            ),
            category="sos",
        ))

    # Confirmation for victim
    db.add(Notification(
        user_id=incident.user_id,
        title="SOS Alert Sent ✓",
        body=(
            f"Your emergency SOS is active. Case ID: {case_id}. "
            f"Help is on the way. Stay safe."
        ),
        category="sos",
    ))

    db.commit()
    logger.info(f"[NOTIFY] Notified {len(police_users)} officers for incident {case_id}")

    # SMS to victim (confirmation)
    if victim and victim.mobile:
        guardians = db.query(Guardian).filter(Guardian.user_id == incident.user_id).all()
        send_sos_confirmation_sms(victim.mobile, case_id, len(guardians))

        # SMS to all guardians
        for guardian in guardians:
            if guardian.phone:
                send_sos_guardian_sms(
                    guardian.phone,
                    victim_name,
                    incident.lat or 0.0,
                    incident.lng or 0.0,
                    case_id,
                )


def notify_sos_resolved(db: Session, incident: Incident) -> None:
    """Notify guardians that victim is safe."""
    victim = db.query(User).filter(User.id == incident.user_id).first()
    victim_name = victim.name if victim else "Unknown"
    case_id = getattr(incident, "case_id", None) or str(incident.id)[:8].upper()

    if victim:
        guardians = db.query(Guardian).filter(Guardian.user_id == incident.user_id).all()
        for guardian in guardians:
            if guardian.phone:
                send_sos_resolved_sms(guardian.phone, victim_name, case_id)

    logger.info(f"[NOTIFY] SOS resolved notifications sent for {case_id}")


def create_notification(db: Session, user_id, title: str, body: str,
                         category: str = "general") -> Notification:
    """Create a single in-app notification for a specific user."""
    notification = Notification(
        user_id=user_id,
        title=title,
        body=body,
        category=category,
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification


def notify_complaint_status_update(db: Session, report, new_status: str, officer_name: Optional[str] = None) -> None:
    """Send in-app notification + SMS when complaint status changes."""
    status_messages = {
        "under-review": "Your complaint is now under review by our cyber team.",
        "assigned": f"Your complaint has been assigned to {officer_name or 'an officer'}.",
        "investigation": "Active investigation has started on your complaint.",
        "closed": "Your complaint has been closed. Thank you for reporting.",
    }
    msg = status_messages.get(new_status, f"Your complaint status updated to: {new_status}.")

    db.add(Notification(
        user_id=report.user_id,
        title=f"📋 Complaint Update — {report.complaint_number or str(report.id)[:8].upper()}",
        body=msg,
        category="complaint",
    ))
    db.commit()

    # SMS notification
    user = db.query(User).filter(User.id == report.user_id).first()
    if user and user.mobile:
        _send_sms(
            user.mobile,
            f"CyberShield Update: {msg} "
            f"Case: {report.complaint_number or str(report.id)[:8].upper()}. -ACCC"
        )
