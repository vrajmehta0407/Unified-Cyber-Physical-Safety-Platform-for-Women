"""
CyberShield — Cyber Report Endpoints
──────────────────────────────────────
POST   /reports/          → Submit new complaint (generates CYB-AHM-YYYY-XXXX)
GET    /reports/          → List all (police) or own (user)
GET    /reports/stats     → Aggregate stats for dashboard
GET    /reports/{id}      → Full report detail
PATCH  /reports/{id}      → Update status / assign officer (police/admin)
POST   /reports/{id}/fir  → Generate FIR PDF (police/admin)
GET    /reports/{id}/fir  → Download previously generated FIR PDF
"""

import io
import json
import logging
from datetime import datetime
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import CyberReport, Evidence, ReportUpdate, User
from app.utils.db_helpers import _id
from app.schemas.report_schema import (
    ReportCreate,
    ReportResponse,
    ReportStatsResponse,
    ReportUpdateRequest,
)
from app.services.cctns_service import sync_to_cctns
from app.services.notification_service import (
    notify_complaint_status_update,
    send_complaint_receipt_whatsapp,
)

logger = logging.getLogger("cybershield.reports")
router = APIRouter(prefix="/reports", tags=["Reports"])


# ─── Complaint number generator ───────────────────────────────────────────────
def _generate_complaint_number(db: Session) -> str:
    """Generate sequential complaint number: CYB-AHM-2026-XXXX."""
    year = datetime.utcnow().year
    prefix = f"CYB-AHM-{year}-"
    count = (
        db.query(func.count(CyberReport.id))
        .filter(CyberReport.complaint_number.like(f"{prefix}%"))
        .scalar()
        or 0
    )
    return f"{prefix}{count + 1:04d}"


# ─── POST /reports/ ───────────────────────────────────────────────────────────
@router.post("/", response_model=ReportResponse)
def submit_report(
    data: ReportCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    complaint_number = _generate_complaint_number(db)

    report = CyberReport(
        user_id=current_user.id,
        complaint_number=complaint_number,
        category=data.category,
        description=data.description,
        priority=data.priority or "medium",
        accused_platform=data.accused_platform,
        accused_username=data.accused_username,
        status_timeline=json.dumps([{
            "status": "submitted",
            "timestamp": datetime.utcnow().isoformat(),
            "officer": None,
            "note": "Complaint submitted by user",
        }]),
    )
    db.add(report)
    db.commit()
    db.refresh(report)

    # Background tasks (best-effort)
    try:
        sync_to_cctns(str(report.id), data.category, data.description)
    except Exception as exc:
        logger.warning(f"[CCTNS] sync failed: {exc}")

    try:
        send_complaint_receipt_whatsapp(
            current_user.mobile,
            complaint_number,
            data.category,
        )
    except Exception as exc:
        logger.warning(f"[WhatsApp] receipt send failed: {exc}")

    logger.info(f"[REPORT] New complaint {complaint_number} by user {current_user.id}")
    return report


# ─── GET /reports/stats ───────────────────────────────────────────────────────
@router.get("/stats", response_model=ReportStatsResponse)
def get_report_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")

    total = db.query(CyberReport).count()

    status_rows = (
        db.query(CyberReport.status, func.count(CyberReport.id))
        .group_by(CyberReport.status)
        .all()
    )
    category_rows = (
        db.query(CyberReport.category, func.count(CyberReport.id))
        .group_by(CyberReport.category)
        .all()
    )
    priority_rows = (
        db.query(CyberReport.priority, func.count(CyberReport.id))
        .group_by(CyberReport.priority)
        .all()
    )

    return ReportStatsResponse(
        total=total,
        by_status={r[0]: r[1] for r in status_rows},
        by_category={r[0]: r[1] for r in category_rows},
        by_priority={r[0]: r[1] for r in priority_rows},
    )


# ─── GET /reports/ ────────────────────────────────────────────────────────────
@router.get("/", response_model=list[ReportResponse])
def list_reports(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role in ("admin", "police"):
        return (
            db.query(CyberReport)
            .order_by(CyberReport.created_at.desc())
            .limit(200)
            .all()
        )
    return (
        db.query(CyberReport)
        .filter(CyberReport.user_id == current_user.id)
        .order_by(CyberReport.created_at.desc())
        .all()
    )


# ─── GET /reports/{report_id} ────────────────────────────────────────────────
@router.get("/{report_id}", response_model=ReportResponse)
def get_report(
    report_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    report = db.query(CyberReport).filter(CyberReport.id == _id(report_id)).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    if current_user.role not in ("admin", "police") and report.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    return report


# ─── PATCH /reports/{report_id} ──────────────────────────────────────────────
@router.patch("/{report_id}", response_model=ReportResponse)
def update_report(
    report_id: str,
    data: ReportUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update status, priority, assigned officer. Police/admin only."""
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")

    report = db.query(CyberReport).filter(CyberReport.id == _id(report_id)).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    old_status = report.status

    if data.status is not None:
        report.status = data.status
        if data.status == "closed":
            report.resolved_at = datetime.utcnow()

        # Append to status_timeline JSON field
        timeline = []
        try:
            raw = report.status_timeline
            if isinstance(raw, str):
                timeline = json.loads(raw)
            elif isinstance(raw, list):
                timeline = raw
        except Exception:
            timeline = []

        timeline.append({
            "status": data.status,
            "timestamp": datetime.utcnow().isoformat(),
            "officer": current_user.name,
            "note": data.notes or "",
        })
        report.status_timeline = json.dumps(timeline)

    if data.priority is not None:
        report.priority = data.priority
    if data.assigned_officer is not None:
        report.assigned_officer = data.assigned_officer

    if data.notes is not None:
        db.add(ReportUpdate(
            report_id=report.id,
            message=data.notes,
            updated_by=current_user.name,
        ))

    db.commit()
    db.refresh(report)

    # Send notification if status changed
    if data.status and data.status != old_status:
        try:
            notify_complaint_status_update(db, report, data.status, current_user.name)
        except Exception as exc:
            logger.warning(f"[NOTIFY] Status update notification failed: {exc}")

    return report


# ─── POST /reports/{report_id}/fir ───────────────────────────────────────────
@router.post("/{report_id}/fir")
def generate_fir_pdf(
    report_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Generate a formatted FIR PDF for the given complaint. Police/admin only."""
    if current_user.role not in ("admin", "police"):
        raise HTTPException(status_code=403, detail="Police access required")

    report = db.query(CyberReport).filter(CyberReport.id == _id(report_id)).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    evidence_items = (
        db.query(Evidence)
        .filter(Evidence.user_id == _id(report.user_id) if hasattr(report, 'user_id') else True)
        .limit(20)
        .all()
    )

    # Mark FIR as generated
    report.fir_status = "draft"
    db.commit()

    # Generate PDF
    pdf_bytes = _build_fir_pdf(report, current_user, evidence_items)

    filename = f"FIR_{report.complaint_number or str(report.id)[:8]}.pdf"
    return StreamingResponse(
        io.BytesIO(pdf_bytes),
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# ─── FIR PDF Builder ─────────────────────────────────────────────────────────
def _build_fir_pdf(report: CyberReport, officer: User, evidence_items: list) -> bytes:
    """Build the FIR PDF using fpdf2."""
    try:
        from fpdf import FPDF
    except ImportError:
        raise HTTPException(
            status_code=503,
            detail="PDF library not installed. Run: pip install fpdf2",
        )

    pdf = FPDF()
    pdf.set_margins(20, 20, 20)
    pdf.add_page()
    pdf.set_auto_page_break(auto=True, margin=20)

    # ── Header ──────────────────────────────────────────────
    pdf.set_font("Helvetica", "B", 16)
    pdf.cell(0, 10, "AHMEDABAD CYBER CRIME CELL", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 8, "FIRST INFORMATION REPORT (FIR)", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    pdf.cell(0, 6, "Office of the Commissioner of Police, Ahmedabad City", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)
    pdf.set_draw_color(50, 50, 50)
    pdf.line(20, pdf.get_y(), 190, pdf.get_y())
    pdf.ln(6)

    # ── FIR Meta ─────────────────────────────────────────────
    complaint_no = report.complaint_number or f"CYB-AHM-{str(report.id)[:8].upper()}"
    filed_date = report.created_at.strftime("%d %B %Y, %H:%M IST") if report.created_at else "—"
    officer_name = officer.name if officer else "—"

    def kv_row(key: str, val: str):
        pdf.set_font("Helvetica", "B", 10)
        pdf.cell(55, 7, key + ":", new_x="RIGHT", new_y="LAST")
        pdf.set_font("Helvetica", "", 10)
        pdf.multi_cell(0, 7, str(val) if val else "—", new_x="LMARGIN", new_y="NEXT")

    kv_row("Complaint Number", complaint_no)
    kv_row("Date & Time Filed", filed_date)
    kv_row("Investigating Officer", officer_name)
    kv_row("Status", report.status.replace("-", " ").title())
    kv_row("FIR Status", report.fir_status.replace("_", " ").title() if report.fir_status else "Draft")
    pdf.ln(4)
    pdf.line(20, pdf.get_y(), 190, pdf.get_y())
    pdf.ln(6)

    # ── Section 1: Complainant ────────────────────────────────
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, "1. COMPLAINANT DETAILS (Anonymised per data protection policy)", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    victim_alias = f"Victim #{str(report.user_id)[:6].upper()}"
    kv_row("  Alias / Case Ref", victim_alias)
    kv_row("  Language", "As per records")
    kv_row("  Report Filed Via", "CyberShield Mobile Application")
    pdf.ln(4)

    # ── Section 2: Incident Category ─────────────────────────
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, "2. OFFENCE DETAILS", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    kv_row("  Category", report.category.replace("_", " ").title() if report.category else "—")
    kv_row("  Priority", report.priority.title() if report.priority else "—")
    kv_row("  Date Incident Reported", filed_date)
    pdf.ln(4)

    # ── Section 3: Description ────────────────────────────────
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, "3. INCIDENT DESCRIPTION", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    description = report.description or "Not provided."
    pdf.multi_cell(0, 6, description, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)

    # ── Section 4: Accused ───────────────────────────────────
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, "4. ACCUSED / SUSPECT DETAILS", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    kv_row("  Platform", report.accused_platform or "Not specified")
    kv_row("  Username / Handle", report.accused_username or "Not specified")
    kv_row("  Phone Number", report.accused_phone or "Not specified")
    kv_row("  Profile URL", report.accused_profile_url or "Not specified")
    pdf.ln(4)

    # ── Section 5: Evidence List ─────────────────────────────
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, "5. DIGITAL EVIDENCE", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    if evidence_items:
        for i, ev in enumerate(evidence_items, 1):
            fname = ev.original_filename or f"evidence_{i}"
            ev_hash = ev.hash or "N/A"
            admissible = "YES" if ev.court_admissible else "PENDING"
            pdf.cell(0, 6,
                     f"  [{i}] {fname} | SHA-256: {ev_hash[:20]}... | Court-Admissible: {admissible}",
                     new_x="LMARGIN", new_y="NEXT")
    else:
        pdf.cell(0, 6, "  No digital evidence linked to this FIR.", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)

    # ── Section 6: Applicable Sections ───────────────────────
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, "6. APPLICABLE LEGAL PROVISIONS", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    CATEGORY_SECTIONS = {
        "cyberstalking": "Section 354D IPC / Section 77 BNS 2023 / Section 67 IT Act 2000",
        "fake_profile": "Section 419, 468 IPC / Section 66C, 66D IT Act 2000",
        "financial_fraud": "Section 420 IPC / Section 66D IT Act 2000 / Section 25 Payment & Settlement Act",
        "blackmail": "Section 383, 385 IPC / Section 67, 67A IT Act 2000",
        "deepfake": "Section 67, 67A IT Act 2000 / Section 79 BNS 2023",
        "identity_theft": "Section 419 IPC / Section 66C IT Act 2000",
        "phishing": "Section 420 IPC / Section 66D IT Act 2000",
        "harassment": "Section 354A, 509 IPC / Section 67 IT Act 2000",
        "sim_swap": "Section 420 IPC / Section 66C, 66D IT Act 2000",
        "morphed_images": "Section 67, 67A IT Act 2000 / Section 354C IPC",
        "vishing": "Section 420 IPC / TRAI regulations",
        "social_hacking": "Section 66, 66C IT Act 2000",
    }
    applicable = CATEGORY_SECTIONS.get(
        report.category or "",
        "IT Act 2000 — relevant sections to be determined by Investigating Officer"
    )
    pdf.multi_cell(0, 6, f"  {applicable}", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(6)

    # ── Signature section ────────────────────────────────────
    pdf.line(20, pdf.get_y(), 190, pdf.get_y())
    pdf.ln(8)
    pdf.set_font("Helvetica", "", 10)
    pdf.cell(90, 6, f"Investigating Officer: {officer_name}", new_x="RIGHT", new_y="LAST")
    pdf.cell(0, 6, f"Date: {datetime.utcnow().strftime('%d %b %Y')}", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(16)
    pdf.cell(90, 1, "_" * 40, new_x="RIGHT", new_y="LAST")
    pdf.cell(0, 1, "_" * 40, new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 9)
    pdf.cell(90, 5, "Signature of I.O.", new_x="RIGHT", new_y="LAST")
    pdf.cell(0, 5, "Seal & Signature of SHO", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)

    # ── Footer ────────────────────────────────────────────────
    pdf.set_font("Helvetica", "I", 8)
    pdf.cell(0, 6,
             f"Generated by CyberShield Platform | Case: {complaint_no} | "
             f"Tamper-proof hash chain maintained. -Ahmedabad Cyber Crime Cell",
             align="C", new_x="LMARGIN", new_y="NEXT")

    return bytes(pdf.output())
