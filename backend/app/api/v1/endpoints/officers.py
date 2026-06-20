"""
CyberShield — Officers Endpoints
──────────────────────────────────
GET    /officers/          → Paginated officer roster + stats
POST   /officers/          → Add new officer (admin only)
GET    /officers/{id}      → Single officer detail
PUT    /officers/{id}      → Update duty status / role / details
DELETE /officers/{id}      → Deactivate (soft delete)
GET    /officers/stats     → Roster summary stats
"""

import logging
from datetime import datetime
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr, field_validator
from sqlalchemy import func
from sqlalchemy.orm import Session

import bcrypt

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import Incident, Officer, User

logger = logging.getLogger("cybershield.officers")
router = APIRouter(prefix="/officers", tags=["Officers"])


# ─── Schemas (inline to keep the file self-contained) ──────────────────────
class OfficerCreate(BaseModel):
    full_name: str
    badge_number: str
    email: str
    password: str
    role: str = "officer"          # officer | supervisor | admin
    phone: str | None = None
    station: str | None = None

    @field_validator("role")
    @classmethod
    def validate_role(cls, v):
        if v not in ("officer", "supervisor", "admin"):
            raise ValueError("role must be officer, supervisor, or admin")
        return v


class OfficerUpdate(BaseModel):
    full_name: str | None = None
    email: str | None = None
    phone: str | None = None
    station: str | None = None
    role: str | None = None
    is_on_duty: bool | None = None
    password: str | None = None


class OfficerOut(BaseModel):
    id: str
    full_name: str
    badge_number: str
    email: str
    role: str
    is_on_duty: bool
    phone: str | None
    station: str | None
    cases_assigned: int
    created_at: datetime
    last_active: datetime

    model_config = {"from_attributes": True}


# ─── GET /officers/stats ────────────────────────────────────────────────────
@router.get("/stats")
def officer_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_police_or_admin(current_user)
    total = db.query(Officer).count()
    on_duty = db.query(Officer).filter(Officer.is_on_duty == True).count()  # noqa: E712
    return {
        "total_officers": total,
        "on_duty": on_duty,
        "off_duty": total - on_duty,
        "supervisors": db.query(Officer).filter(Officer.role == "supervisor").count(),
        "admins": db.query(Officer).filter(Officer.role == "admin").count(),
    }


# ─── GET /officers/ ─────────────────────────────────────────────────────────
@router.get("/", response_model=list[OfficerOut])
def list_officers(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_police_or_admin(current_user)
    officers = db.query(Officer).offset(skip).limit(limit).all()
    return [_to_out(o) for o in officers]


# ─── POST /officers/ ────────────────────────────────────────────────────────
@router.post("/", response_model=OfficerOut, status_code=201)
def create_officer(
    data: OfficerCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_admin(current_user)

    # Check for duplicate badge number or email
    if db.query(Officer).filter(Officer.badge_number == data.badge_number).first():
        raise HTTPException(status_code=409, detail="Badge number already registered")
    if db.query(Officer).filter(Officer.email == data.email).first():
        raise HTTPException(status_code=409, detail="Email already registered")

    hashed = bcrypt.hashpw(data.password.encode(), bcrypt.gensalt()).decode()
    officer = Officer(
        full_name=data.full_name,
        badge_number=data.badge_number,
        email=data.email,
        password_hash=hashed,
        role=data.role,
        phone=data.phone,
        station=data.station,
        is_on_duty=False,
    )
    db.add(officer)
    db.commit()
    db.refresh(officer)
    logger.info(f"[OFFICER] Created {officer.badge_number} by {current_user.name}")
    return _to_out(officer)


# ─── GET /officers/{officer_id} ─────────────────────────────────────────────
@router.get("/{officer_id}", response_model=OfficerOut)
def get_officer(
    officer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_police_or_admin(current_user)
    officer = db.query(Officer).filter(Officer.id == officer_id).first()
    if not officer:
        raise HTTPException(status_code=404, detail="Officer not found")
    return _to_out(officer)


# ─── PUT /officers/{officer_id} ─────────────────────────────────────────────
@router.put("/{officer_id}", response_model=OfficerOut)
def update_officer(
    officer_id: str,
    data: OfficerUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_police_or_admin(current_user)
    officer = db.query(Officer).filter(Officer.id == officer_id).first()
    if not officer:
        raise HTTPException(status_code=404, detail="Officer not found")

    # Only admins can change roles
    if data.role is not None and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can change roles")

    if data.full_name is not None:
        officer.full_name = data.full_name
    if data.email is not None:
        officer.email = data.email
    if data.phone is not None:
        officer.phone = data.phone
    if data.station is not None:
        officer.station = data.station
    if data.role is not None:
        officer.role = data.role
    if data.is_on_duty is not None:
        officer.is_on_duty = data.is_on_duty
    if data.password is not None:
        officer.password_hash = bcrypt.hashpw(data.password.encode(), bcrypt.gensalt()).decode()

    officer.last_active = datetime.utcnow()
    db.commit()
    db.refresh(officer)
    logger.info(f"[OFFICER] Updated {officer.badge_number}")
    return _to_out(officer)


# ─── DELETE /officers/{officer_id} ──────────────────────────────────────────
@router.delete("/{officer_id}", status_code=204)
def delete_officer(
    officer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_admin(current_user)
    officer = db.query(Officer).filter(Officer.id == officer_id).first()
    if not officer:
        raise HTTPException(status_code=404, detail="Officer not found")
    db.delete(officer)
    db.commit()
    logger.info(f"[OFFICER] Deleted {officer.badge_number} by {current_user.name}")


# ─── Internal helpers ────────────────────────────────────────────────────────
def _require_police_or_admin(user: User):
    if user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")


def _require_admin(user: User):
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")


def _to_out(o: Officer) -> OfficerOut:
    return OfficerOut(
        id=str(o.id),
        full_name=o.full_name,
        badge_number=o.badge_number,
        email=o.email,
        role=o.role,
        is_on_duty=o.is_on_duty,
        phone=o.phone,
        station=o.station,
        cases_assigned=o.cases_assigned or 0,
        created_at=o.created_at or datetime.utcnow(),
        last_active=o.last_active or datetime.utcnow(),
    )
