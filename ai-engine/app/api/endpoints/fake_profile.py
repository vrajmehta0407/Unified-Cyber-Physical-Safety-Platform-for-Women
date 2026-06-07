from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/predict", tags=["Fake Profile"])


class FakeProfileRequest(BaseModel):
    username: str
    platform: str = "instagram"
    profile_data: dict = {}


@router.post("/fake-profile")
def predict_fake_profile(data: FakeProfileRequest):
    profile = data.profile_data
    score = 30.0
    factors = {}

    followers = profile.get("followers", 100)
    following = profile.get("following", 50)
    posts = profile.get("posts", 10)
    has_photo = profile.get("has_profile_photo", True)
    bio_length = len(profile.get("bio", ""))

    if followers > 0 and following / max(followers, 1) > 2:
        score += 20
        factors["follower_ratio"] = "suspicious"

    if posts < 3:
        score += 15
        factors["post_count"] = "low"

    if not has_photo:
        score += 20
        factors["profile_photo"] = "missing"

    if bio_length < 5:
        score += 10
        factors["bio"] = "empty"

    score = min(score, 100)
    verdict = "high_risk" if score >= 60 else "moderate_risk" if score >= 35 else "low_risk"

    return {
        "risk_score": score,
        "verdict": verdict,
        "details": factors,
        "message": f"Profile @{data.username} on {data.platform}: {verdict.replace('_', ' ').title()}",
    }
