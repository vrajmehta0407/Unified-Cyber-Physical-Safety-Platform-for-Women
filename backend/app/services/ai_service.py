"""AI service — calls the AI Engine microservice with graceful fallback."""
import httpx

from app.config import get_settings

settings = get_settings()

_TIMEOUT = 30.0


async def _post(endpoint: str, payload: dict) -> dict:
    url = f"{settings.AI_ENGINE_URL}{endpoint}"
    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            response = await client.post(url, json=payload)
            response.raise_for_status()
            return response.json()
    except (httpx.ConnectError, httpx.TimeoutException, httpx.HTTPStatusError):
        return None  # Caller handles None as "engine unavailable"


async def _get(endpoint: str) -> dict:
    url = f"{settings.AI_ENGINE_URL}{endpoint}"
    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            response = await client.get(url)
            response.raise_for_status()
            return response.json()
    except (httpx.ConnectError, httpx.TimeoutException, httpx.HTTPStatusError):
        return None


async def call_ai_engine(endpoint: str, payload: dict) -> dict:
    result = await _post(endpoint, payload)
    if result is None:
        raise ConnectionError("AI engine unavailable")
    return result


async def call_ai_engine_get(endpoint: str) -> dict:
    result = await _get(endpoint)
    if result is None:
        raise ConnectionError("AI engine unavailable")
    return result


async def check_phishing(url: str, text: str | None = None) -> dict:
    result = await _post("/predict/phishing", {"url": url, "text": text})
    if result is None:
        # Fallback: basic heuristic
        score = 25.0
        if not url.startswith("https"):
            score += 20
        if any(w in url.lower() for w in ["login", "verify", "free", "prize", "urgent"]):
            score += 25
        verdict = "high_risk" if score >= 60 else "moderate_risk" if score >= 30 else "low_risk"
        return {"risk_score": score, "verdict": verdict, "details": {"fallback": "true"}, "message": f"Basic analysis — {verdict}"}
    return result


async def analyze_fake_profile(username: str, platform: str, profile_data: dict | None = None) -> dict:
    result = await _post("/predict/fake-profile", {"username": username, "platform": platform, "profile_data": profile_data or {}})
    if result is None:
        return {"risk_score": 30.0, "verdict": "low_risk", "details": {"fallback": "true"}, "message": "AI engine unavailable — basic check only"}
    return result


async def detect_deepfake(file_content: bytes, mime_type: str) -> dict:
    import base64
    result = await _post("/predict/deepfake", {"file_base64": base64.b64encode(file_content).decode(), "mime_type": mime_type})
    if result is None:
        return {"risk_score": 0.0, "verdict": "unknown", "details": {"fallback": "true"}, "message": "AI engine unavailable"}
    return result


async def get_unsafe_zones(city: str = "Ahmedabad") -> dict:
    result = await _get(f"/predict/unsafe-zone?city={city}")
    if result is None:
        # Return static fallback data
        return {
            "city": city,
            "zones": [
                {"name": "Maninagar", "lat": 23.0036, "lng": 72.6015, "risk": "high", "incidents": 45},
                {"name": "Navrangpura", "lat": 23.0360, "lng": 72.5611, "risk": "medium", "incidents": 28},
                {"name": "Satellite", "lat": 23.0225, "lng": 72.5714, "risk": "low", "incidents": 12},
            ],
            "statistics": {"high_risk_areas": 1, "medium_risk_areas": 1, "low_risk_areas": 1, "total_incidents": 85},
        }
    return result
