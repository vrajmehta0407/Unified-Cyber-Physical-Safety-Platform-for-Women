import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean, Column, DateTime, Float, ForeignKey,
    Integer, String, Text, JSON
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.database import Base


# ─────────────────────────────────────────────
#  Users
# ─────────────────────────────────────────────
class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    mobile = Column(String(20), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), default="user")  # user | police | admin
    fcm_token = Column(String(500), nullable=True)
    language = Column(String(10), default="en")
    safe_word = Column(String(100), nullable=True)
    decoy_pin = Column(String(10), nullable=True)
    safety_score = Column(Integer, default=20)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_active = Column(DateTime, default=datetime.utcnow)

    guardians = relationship("Guardian", back_populates="user", cascade="all, delete-orphan")
    incidents = relationship("Incident", back_populates="user")
    reports = relationship("CyberReport", back_populates="user")


# ─────────────────────────────────────────────
#  Officers  (separate from users — badge-based)
# ─────────────────────────────────────────────
class Officer(Base):
    __tablename__ = "officers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    full_name = Column(String(255), nullable=False)
    badge_number = Column(String(50), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), default="officer")   # officer | supervisor | admin
    fcm_token = Column(String(500), nullable=True)
    is_on_duty = Column(Boolean, default=False)
    phone = Column(String(20), nullable=True)
    station = Column(String(255), nullable=True)
    cases_assigned = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_active = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Guardians
# ─────────────────────────────────────────────
class Guardian(Base):
    __tablename__ = "guardians"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name = Column(String(255), nullable=False)
    phone = Column(String(20), nullable=False)
    relation = Column(String(100))
    permission_level = Column(String(20), default="sos_only")
    priority_order = Column(Integer, default=1)
    fcm_token = Column(String(500), nullable=True)

    user = relationship("User", back_populates="guardians")


# ─────────────────────────────────────────────
#  Incidents  (SOS events)
# ─────────────────────────────────────────────
class Incident(Base):
    __tablename__ = "incidents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    case_id = Column(String(30), unique=True, nullable=True, index=True)
    type = Column(String(50), default="sos")
    status = Column(String(50), default="active")   # active | responding | resolved | cancelled | false_alarm
    lat = Column(Float)
    lng = Column(Float)
    address = Column(Text, nullable=True)
    is_silent = Column(Boolean, default=False)
    is_offline_queued = Column(Boolean, default=False)
    audio_file_url = Column(String(500), nullable=True)
    audio_sha256 = Column(String(64), nullable=True)
    assigned_officer_id = Column(UUID(as_uuid=True), ForeignKey("officers.id"), nullable=True)
    assigned_officer_name = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    resolved_at = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="incidents")
    evidence = relationship("Evidence", back_populates="incident")
    location_logs = relationship("LocationLog", back_populates="incident")


# ─────────────────────────────────────────────
#  Location Logs  (WebSocket streaming coords)
# ─────────────────────────────────────────────
class LocationLog(Base):
    __tablename__ = "location_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    incident_id = Column(UUID(as_uuid=True), ForeignKey("incidents.id"), nullable=False)
    lat = Column(Float, nullable=False)
    lng = Column(Float, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    incident = relationship("Incident", back_populates="location_logs")


# ─────────────────────────────────────────────
#  Evidence
# ─────────────────────────────────────────────
class Evidence(Base):
    __tablename__ = "evidence"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    incident_id = Column(UUID(as_uuid=True), ForeignKey("incidents.id"), nullable=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    file_path = Column(String(500), nullable=False)
    original_filename = Column(String(255), nullable=True)
    hash = Column(String(64), nullable=False)
    mime_type = Column(String(100))
    file_size = Column(Integer, nullable=True)
    description = Column(Text, nullable=True)
    court_admissible = Column(Boolean, default=False)
    verified = Column(Boolean, default=True)
    timestamp = Column(DateTime, default=datetime.utcnow)

    incident = relationship("Incident", back_populates="evidence")
    chain_entries = relationship("ChainOfCustody", back_populates="evidence", cascade="all, delete-orphan")


# ─────────────────────────────────────────────
#  Chain of Custody  (append-only audit trail)
# ─────────────────────────────────────────────
class ChainOfCustody(Base):
    __tablename__ = "chain_of_custody"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    evidence_id = Column(UUID(as_uuid=True), ForeignKey("evidence.id"), nullable=False)
    action = Column(String(100), nullable=False)
    actor = Column(String(255), nullable=False)
    ip_address = Column(String(45), nullable=True)
    note = Column(Text, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)

    evidence = relationship("Evidence", back_populates="chain_entries")


# ─────────────────────────────────────────────
#  Cyber Reports
# ─────────────────────────────────────────────
class CyberReport(Base):
    __tablename__ = "cyber_reports"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    complaint_number = Column(String(30), unique=True, nullable=True, index=True)
    category = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)
    description_en = Column(Text, nullable=True)          # translated copy
    status = Column(String(50), default="submitted")       # submitted | under-review | assigned | investigation | closed
    priority = Column(String(50), default="medium")        # low | medium | high | critical
    assigned_officer = Column(String(255), nullable=True)  # officer name string (legacy)
    assigned_officer_id = Column(UUID(as_uuid=True), ForeignKey("officers.id"), nullable=True)
    accused_platform = Column(String(100), nullable=True)
    accused_username = Column(String(255), nullable=True)
    accused_phone = Column(String(20), nullable=True)
    accused_profile_url = Column(String(500), nullable=True)
    witness_name = Column(String(255), nullable=True)
    witness_contact = Column(String(100), nullable=True)
    nccrp_submitted = Column(Boolean, default=False)
    fir_status = Column(String(30), default="none")        # none | draft | signed | submitted
    status_timeline = Column(JSON, default=list)           # list of {status, timestamp, officer, note}
    resolved_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="reports")
    updates = relationship("ReportUpdate", back_populates="report", cascade="all, delete-orphan")


# ─────────────────────────────────────────────
#  Report Updates  (officer notes / status history)
# ─────────────────────────────────────────────
class ReportUpdate(Base):
    __tablename__ = "report_updates"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    report_id = Column(UUID(as_uuid=True), ForeignKey("cyber_reports.id"), nullable=False)
    message = Column(Text, nullable=False)
    updated_by = Column(String(255), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    report = relationship("CyberReport", back_populates="updates")


# ─────────────────────────────────────────────
#  AI Scan Results
# ─────────────────────────────────────────────
class AIScanResult(Base):
    __tablename__ = "ai_scan_results"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    scan_type = Column(String(50), nullable=False)
    input = Column(Text)
    result = Column(Text)
    verdict = Column(String(50), nullable=True)
    risk_score = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Notifications
# ─────────────────────────────────────────────
class Notification(Base):
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    category = Column(String(50), default="general")
    read = Column(Boolean, default=False)
    timestamp = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Awareness Content
# ─────────────────────────────────────────────
class AwarenessContent(Base):
    __tablename__ = "awareness_content"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    category = Column(String(100))
    language = Column(String(10), default="en")
    created_at = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Audit Log
# ─────────────────────────────────────────────
class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    action = Column(String(100), nullable=False)
    resource = Column(String(255))
    resource_id = Column(String(255), nullable=True)
    ip_address = Column(String(45))
    details = Column(JSON, default=dict)
    timestamp = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Officer Notes  (internal, not visible to complainant)
# ─────────────────────────────────────────────
class OfficerNote(Base):
    __tablename__ = "officer_notes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    incident_id = Column(UUID(as_uuid=True), ForeignKey("incidents.id"), nullable=True)
    report_id = Column(UUID(as_uuid=True), ForeignKey("cyber_reports.id"), nullable=True)
    officer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    note = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Community Reports
# ─────────────────────────────────────────────
class CommunityReport(Base):
    __tablename__ = "community_reports"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    lat = Column(Float, nullable=False)
    lng = Column(Float, nullable=False)
    description = Column(Text, nullable=False)
    severity = Column(String(50), default="medium")
    category = Column(String(100), nullable=True)
    confirmation_count = Column(Integer, default=1)
    is_published = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Threat Feed
# ─────────────────────────────────────────────
class ThreatFeedItem(Base):
    __tablename__ = "threat_feed"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    severity = Column(String(50), default="medium")
    lat = Column(Float, nullable=True)
    lng = Column(Float, nullable=True)
    category = Column(String(100), nullable=True)
    affected_area = Column(String(255), nullable=True)
    source = Column(String(100), default="system")
    created_at = Column(DateTime, default=datetime.utcnow)


# ─────────────────────────────────────────────
#  Advisory Broadcasts
# ─────────────────────────────────────────────
class AdvisoryBroadcast(Base):
    __tablename__ = "advisory_broadcasts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    target_audience = Column(String(100), default="all")
    priority = Column(String(50), default="medium")
    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    delivery_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
