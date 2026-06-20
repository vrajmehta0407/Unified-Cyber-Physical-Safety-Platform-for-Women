"""Seed demo users and officers for development/demo."""
import logging

import bcrypt
from sqlalchemy.orm import Session

from app.models import Officer, User
from app.services.auth_service import hash_password

logger = logging.getLogger("cybershield.seed")

DEMO_USERS = [
    {
        "name": "Ananya Sharma",
        "mobile": "9876543210",
        "email": "ananya@example.com",
        "password": "password123",
        "role": "user",
    },
    {
        "name": "Officer Sharma",
        "mobile": "9999999999",
        "email": "officer@cybershield.gov.in",
        "password": "police123",
        "role": "police",
    },
    {
        "name": "Admin Singh",
        "mobile": "9000000001",
        "email": "admin@cybershield.gov.in",
        "password": "admin123",
        "role": "admin",
    },
    {
        "name": "Demo User",
        "mobile": "9111111111",
        "email": "demo@cybershield.gov.in",
        "password": "demo123",
        "role": "user",
    },
]

DEMO_OFFICERS = [
    {
        "full_name": "Inspector Rajesh Kumar",
        "badge_number": "AHM-CYB-001",
        "email": "rajesh.kumar@accc.gov.in",
        "password": "officer123",
        "role": "supervisor",
        "phone": "9900000001",
        "station": "Cyber Crime Cell - HQ",
        "is_on_duty": True,
    },
    {
        "full_name": "SI Priya Patel",
        "badge_number": "AHM-CYB-002",
        "email": "priya.patel@accc.gov.in",
        "password": "officer123",
        "role": "officer",
        "phone": "9900000002",
        "station": "Cyber Crime Cell - East",
        "is_on_duty": True,
    },
    {
        "full_name": "ASI Mohit Shah",
        "badge_number": "AHM-CYB-003",
        "email": "mohit.shah@accc.gov.in",
        "password": "officer123",
        "role": "officer",
        "phone": "9900000003",
        "station": "Cyber Crime Cell - West",
        "is_on_duty": False,
    },
    {
        "full_name": "HC Sunita Verma",
        "badge_number": "AHM-CYB-004",
        "email": "sunita.verma@accc.gov.in",
        "password": "officer123",
        "role": "officer",
        "phone": "9900000004",
        "station": "Cyber Crime Cell - North",
        "is_on_duty": True,
    },
    {
        "full_name": "DCP Anand Mehta",
        "badge_number": "AHM-CYB-005",
        "email": "anand.mehta@accc.gov.in",
        "password": "admin123",
        "role": "admin",
        "phone": "9900000005",
        "station": "Cyber Crime Cell - HQ",
        "is_on_duty": True,
    },
]


def seed_demo_users(db: Session) -> None:
    for demo in DEMO_USERS:
        if db.query(User).filter(User.mobile == demo["mobile"]).first():
            continue
        db.add(User(
            name=demo["name"],
            mobile=demo["mobile"],
            email=demo["email"],
            password_hash=hash_password(demo["password"]),
            role=demo["role"],
        ))
    try:
        db.commit()
        logger.info("[SEED] Demo users seeded successfully")
    except Exception as exc:
        db.rollback()
        logger.warning(f"[SEED] Users seed failed: {exc}")

    # Seed demo officers
    for demo in DEMO_OFFICERS:
        if db.query(Officer).filter(Officer.badge_number == demo["badge_number"]).first():
            continue
        pw_hash = bcrypt.hashpw(demo["password"].encode(), bcrypt.gensalt()).decode()
        db.add(Officer(
            full_name=demo["full_name"],
            badge_number=demo["badge_number"],
            email=demo["email"],
            password_hash=pw_hash,
            role=demo["role"],
            phone=demo["phone"],
            station=demo["station"],
            is_on_duty=demo["is_on_duty"],
        ))
    try:
        db.commit()
        logger.info("[SEED] Demo officers seeded successfully")
    except Exception as exc:
        db.rollback()
        logger.warning(f"[SEED] Officers seed failed: {exc}")
