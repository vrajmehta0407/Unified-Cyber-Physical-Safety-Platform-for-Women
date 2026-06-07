from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import CyberReport, User
from app.services.cctns_service import get_cctns_status, sync_to_cctns
from app.services.erss_service import dispatch_erss_alert

router = APIRouter(prefix="/integrations", tags=["Integrations"])


@router.get("/cctns/{report_id}")
def get_cctns_integration(report_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    report = db.query(CyberReport).filter(CyberReport.id == report_id).first()
    if not report:
        sync_data = sync_to_cctns(report_id, "unknown", "")
    else:
        sync_data = sync_to_cctns(str(report.id), report.category, report.description)
    status = get_cctns_status(sync_data["cctns_id"])
    return {
        **sync_data,
        **status,
        "steps": [
            {"label": "Complaint Received", "done": True},
            {"label": "CCTNS Record Created", "done": True},
            {"label": "Investigation In Progress", "done": status["status"] == "investigation_in_progress"},
            {"label": "Case Status Updated", "done": False},
        ],
        "legal_sections": ["354D", "66C", "66E", "IT Act"],
    }


@router.get("/erss/active")
def get_active_erss(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    dispatch = dispatch_erss_alert(23.0036, 72.6015, "physical_threat")
    return {
        "active_dispatches": [dispatch],
        "total": 1,
    }
