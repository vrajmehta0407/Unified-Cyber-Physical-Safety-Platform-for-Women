from typing import Optional
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import AIScanResult, User
from app.schemas.ai_schema import AIResultResponse, FakeProfileRequest, PhishingRequest
from app.services import ai_service
from app.api.v1.endpoints.map import THREAT_FEED

router = APIRouter(prefix="/ai", tags=["AI Protection"])


class SmsScanRequest(BaseModel):
    sms_text: str
    sender: Optional[str] = None


class SmsScanResult(BaseModel):
    is_threat: bool
    threat_type: Optional[str] = None
    risk_score: int
    verdict: str
    indicators: list
    recommendation: str


from pydantic import BaseModel
from typing import Optional

@router.post("/phishing", response_model=AIResultResponse)
async def check_phishing(
    data: PhishingRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await ai_service.check_phishing(data.url, data.text)
    scan = AIScanResult(
        user_id=current_user.id,
        scan_type="phishing",
        input=data.url,
        result=result.get("verdict", ""),
        risk_score=result.get("risk_score", 0),
    )
    db.add(scan)
    db.commit()
    return AIResultResponse(
        scan_type="phishing",
        risk_score=result.get("risk_score", 0),
        verdict=result.get("verdict", "unknown"),
        details=result.get("details", {}),
        message=result.get("message", ""),
    )


@router.post("/fake-profile", response_model=AIResultResponse)
async def analyze_fake_profile(
    data: FakeProfileRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await ai_service.analyze_fake_profile(data.username, data.platform, data.profile_data)
    return AIResultResponse(
        scan_type="fake_profile",
        risk_score=result.get("risk_score", 0),
        verdict=result.get("verdict", "unknown"),
        details=result.get("details", {}),
        message=result.get("message", ""),
    )


@router.post("/deepfake", response_model=AIResultResponse)
async def detect_deepfake(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    content = await file.read()
    result = await ai_service.detect_deepfake(content, file.content_type or "image/jpeg")
    return AIResultResponse(
        scan_type="deepfake",
        risk_score=result.get("risk_score", 0),
        verdict=result.get("verdict", "unknown"),
        details=result.get("details", {}),
        message=result.get("message", ""),
    )


@router.get("/unsafe-zone")
async def get_unsafe_zones(city: str = "Ahmedabad", current_user: User = Depends(get_current_user)):
    try:
        return await ai_service.get_unsafe_zones(city)
    except Exception:
        raise HTTPException(status_code=503, detail="AI engine unavailable")


@router.post("/sms-scan")
async def scan_sms_for_threats(
    data: SmsScanRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Scan an SMS/message for scam patterns.
    Checks for: OTP phishing, prize scams, KYC fraud, job scams, bank impersonation.
    """
    text = data.sms_text.lower()
    indicators = []
    risk_score = 0
    threat_type = None

    # OTP phishing patterns
    otp_keywords = ["otp", "one time password", "do not share", "never share otp"]
    if any(k in text for k in otp_keywords) and any(k in text for k in ["bank", "kyc", "account", "verify"]):
        indicators.append("OTP phishing pattern detected")
        risk_score += 40
        threat_type = "otp_phishing"

    # Prize/lottery scam
    prize_keywords = ["won", "winner", "prize", "lottery", "lucky draw", "congratulation"]
    if any(k in text for k in prize_keywords):
        indicators.append("Prize/lottery scam pattern")
        risk_score += 35
        threat_type = "lottery_scam"

    # Job offer scam
    job_keywords = ["job offer", "work from home", "earn daily", "part time job", "data entry"]
    if any(k in text for k in job_keywords) and any(k in text for k in ["click", "apply", "link", "whatsapp"]):
        indicators.append("Fraudulent job offer pattern")
        risk_score += 30
        threat_type = "job_scam"

    # Bank/KYC impersonation
    bank_keywords = ["rbi", "sbi", "hdfc", "icici", "paytm", "phonepe", "kyc expired", "account blocked"]
    if any(k in text for k in bank_keywords) and any(k in text for k in ["click", "verify", "update", "link"]):
        indicators.append("Bank/payment impersonation detected")
        risk_score += 45
        threat_type = "bank_impersonation"

    # Suspicious links
    import re
    urls = re.findall(r'https?://[^\s]+', text)
    for url in urls:
        if any(k in url for k in ["bit.ly", "tinyurl", "t.me/", "short"]):
            indicators.append(f"Shortened/suspicious link found: {url}")
            risk_score += 25

    # Urgency patterns
    urgency_keywords = ["immediate", "urgent", "last chance", "expires today", "act now", "within 24 hours"]
    if any(k in text for k in urgency_keywords):
        indicators.append("Urgency manipulation tactic detected")
        risk_score += 15

    risk_score = min(risk_score, 100)
    is_threat = risk_score >= 30

    if risk_score >= 70:
        verdict = "DANGEROUS"
        recommendation = "Do NOT respond or click any links. Block the sender immediately and report to Cyber Cell at 1930."
    elif risk_score >= 40:
        verdict = "SUSPICIOUS"
        recommendation = "Exercise extreme caution. Do not share personal information or click links. Verify through official channels."
    elif risk_score >= 20:
        verdict = "LOW_RISK"
        recommendation = "Some suspicious patterns found. Verify sender identity before responding."
    else:
        verdict = "SAFE"
        recommendation = "No significant threats detected. Stay vigilant."

    return {
        "is_threat": is_threat,
        "threat_type": threat_type,
        "risk_score": risk_score,
        "verdict": verdict,
        "indicators": indicators,
        "recommendation": recommendation,
        "urls_found": urls,
    }


@router.get("/threat-feed/ahmedabad")
async def get_ahmedabad_threat_feed(
    limit: int = 10,
    current_user: User = Depends(get_current_user),
):
    """Get live cybercrime threat intelligence for Ahmedabad from I4C/NCCRP sources."""
    from datetime import datetime
    return {
        "city": "Ahmedabad",
        "state": "Gujarat",
        "last_updated": datetime.utcnow().isoformat(),
        "total": len(THREAT_FEED),
        "feed": THREAT_FEED[:limit],
        "emergency_contact": "1930 (National Cyber Crime Helpline)",
        "local_contact": "079-25506000 (Ahmedabad Cyber Cell)",
    }
