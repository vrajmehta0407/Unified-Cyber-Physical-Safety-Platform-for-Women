from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import AIScanResult, User
from app.schemas.ai_schema import AIResultResponse, FakeProfileRequest, PhishingRequest
from app.services import ai_service

router = APIRouter(prefix="/ai", tags=["AI Protection"])

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
