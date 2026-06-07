from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import CyberReport, User
from app.schemas.report_schema import ReportCreate, ReportResponse
from app.services.cctns_service import sync_to_cctns

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.post("/", response_model=ReportResponse)
def submit_report(
    data: ReportCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    report = CyberReport(
        user_id=current_user.id,
        category=data.category,
        description=data.description,
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    sync_to_cctns(str(report.id), data.category, data.description)
    return report


@router.get("/", response_model=list[ReportResponse])
def list_reports(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role in ("admin", "police"):
        return db.query(CyberReport).order_by(CyberReport.created_at.desc()).limit(100).all()
    return db.query(CyberReport).filter(CyberReport.user_id == current_user.id).all()
