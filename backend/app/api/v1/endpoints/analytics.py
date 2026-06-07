from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import CyberReport, Incident, User
from app.services import ai_service

router = APIRouter(prefix="/analytics", tags=["Analytics"])


class DashboardStats(BaseModel):
    active_sos: int
    cyber_complaints: int
    total_incidents: int
    active_officers: int


@router.get("/dashboard", response_model=DashboardStats)
def get_dashboard_stats(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")

    active_sos = db.query(Incident).filter(Incident.type == "sos", Incident.status == "active").count()
    cyber_complaints = db.query(CyberReport).count()
    total_incidents = db.query(Incident).count()
    active_officers = db.query(User).filter(User.role == "police").count()

    return DashboardStats(
        active_sos=active_sos,
        cyber_complaints=cyber_complaints,
        total_incidents=total_incidents,
        active_officers=max(active_officers, 1),
    )


@router.get("/patterns")
async def get_crime_patterns(current_user: User = Depends(get_current_user)):
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")
    try:
        return await ai_service.call_ai_engine_get("/analytics/pattern")
    except Exception:
        raise HTTPException(status_code=503, detail="AI engine unavailable")
