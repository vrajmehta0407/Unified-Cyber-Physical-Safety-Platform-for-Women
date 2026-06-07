import os
os.environ["DATABASE_URL"] = "sqlite:///./test_auth.db"

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.database import Base, get_db
from app.main import app

engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def test_register_login_and_me():
    register = client.post("/api/v1/auth/register", json={
        "name": "Test User",
        "mobile": "9123456789",
        "password": "secret12",
    })
    assert register.status_code == 201

    login = client.post("/api/v1/auth/login", json={
        "mobile": "9123456789",
        "password": "secret12",
    })
    assert login.status_code == 200
    token = login.json()["access_token"]

    me = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me.status_code == 200
    assert me.json()["mobile"] == "9123456789"


def test_otp_flow():
    client.post("/api/v1/auth/register", json={
        "name": "OTP User",
        "mobile": "9111111111",
        "password": "secret12",
    })
    send = client.post("/api/v1/auth/otp/send", json={"mobile": "9111111111"})
    assert send.status_code == 200
    otp = send.json()["otp_dev_only"]

    verify = client.post("/api/v1/auth/otp/verify", json={"mobile": "9111111111", "otp": otp})
    assert verify.status_code == 200
    assert "access_token" in verify.json()
