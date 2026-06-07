import re

from fastapi import APIRouter
from pydantic import BaseModel

from app.models.phishing_features import extract_url_features
from app.utils.preprocessor import normalize_url

router = APIRouter(prefix="/predict", tags=["Phishing"])


class PhishingRequest(BaseModel):
    url: str
    text: str | None = None


SUSPICIOUS_PATTERNS = [
    r"login.*verify",
    r"secure.*update",
    r"bit\.ly",
    r"tinyurl",
    r"free.*prize",
    r"urgent.*action",
    r"account.*suspend",
    r"confirm.*identity",
    r"reset.*password",
    r"click.*here",
    r"winner.*selected",
    r"earn.*money",
    r"bank.*details",
]


@router.post("/phishing")
def predict_phishing(data: PhishingRequest):
    url = normalize_url(data.url)
    content = f"{url} {data.text or ''}".lower()

    # Extract structured URL features
    features = extract_url_features(url)

    # Score calculation using feature analysis
    score = 0.0
    factors = {}

    # SSL check
    if not features["has_https"]:
        score += 20
        factors["ssl"] = "missing"

    # IP address in domain
    if features["has_ip_address"]:
        score += 20
        factors["ip_in_url"] = "suspicious"

    # Suspicious TLD
    if features["has_suspicious_tld"]:
        score += 15
        factors["tld"] = "suspicious"

    # URL shortener
    if features["uses_shortener"]:
        score += 15
        factors["shortener"] = "detected"

    # Suspicious keywords
    matched_patterns = []
    for pattern in SUSPICIOUS_PATTERNS:
        if re.search(pattern, content):
            matched_patterns.append(pattern)
    if matched_patterns:
        score += min(len(matched_patterns) * 8, 25)
        factors["keyword_matches"] = len(matched_patterns)

    # URL length penalty
    if features["url_length"] > 80:
        score += 5
        factors["url_length"] = "long"
    if features["url_length"] > 120:
        score += 5

    # Many subdomains
    if features["subdomain_count"] >= 3:
        score += 10
        factors["subdomains"] = "excessive"

    # Encoded characters
    if features["has_encoding"]:
        score += 5
        factors["encoding"] = "detected"

    # High digit ratio in domain
    if features["digit_ratio"] > 0.3:
        score += 10
        factors["digit_ratio"] = "high"

    # Redirect in URL
    if features["has_redirect"]:
        score += 10
        factors["redirect"] = "detected"

    score = min(score, 100)
    verdict = "high_risk" if score >= 60 else "moderate_risk" if score >= 30 else "low_risk"

    return {
        "risk_score": round(score, 1),
        "verdict": verdict,
        "details": factors,
        "features_analyzed": len(features),
        "message": f"Phishing analysis complete — {verdict.replace('_', ' ').title()}",
    }
