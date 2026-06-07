"""Seed demo users for development."""
from sqlalchemy.orm import Session

from app.models import User
from app.services.auth_service import hash_password

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
]


def seed_demo_users(db: Session) -> None:
    for demo in DEMO_USERS:
        exists = db.query(User).filter(User.mobile == demo["mobile"]).first()
        if exists:
            continue
        db.add(
            User(
                name=demo["name"],
                mobile=demo["mobile"],
                email=demo["email"],
                password_hash=hash_password(demo["password"]),
                role=demo["role"],
            )
        )
    db.commit()
