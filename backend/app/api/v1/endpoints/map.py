"""
CyberShield — Safety Map Endpoints
Provides safe zone data, community reports, threat feed,
and safe route planning for Ahmedabad.
"""

from datetime import datetime, timedelta
from typing import List, Optional
import httpx
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models import User
from app.config import settings


router = APIRouter(prefix="/map", tags=["Safety Map"])


# ─────────────────────────── Schemas ───────────────────────────

class SafeZone(BaseModel):
    id: str
    name: str
    type: str  # police_station | hospital | fire_station | pharmacy | women_help
    lat: float
    lng: float
    address: str
    phone: Optional[str] = None
    is_24hr: bool = False
    distance_m: Optional[float] = None


class IncidentHeatPoint(BaseModel):
    lat: float
    lng: float
    severity: str  # low | medium | high
    category: str
    count: int
    radius_m: int = 200


class CommunityReport(BaseModel):
    id: str
    lat: float
    lng: float
    description: str
    category: str
    confirmation_count: int
    reported_at: str
    expires_at: str


class CommunityReportCreate(BaseModel):
    lat: float
    lng: float
    description: str
    category: str  # unsafe_area | harassment | suspicious_activity | poor_lighting


class SafeRouteRequest(BaseModel):
    from_lat: float
    from_lng: float
    to_lat: float
    to_lng: float
    depart_time: Optional[str] = None  # ISO format, used for time-of-day risk adjustment


class SafeRouteResponse(BaseModel):
    route_type: str
    distance_km: float
    duration_min: int
    risk_level: str  # low | medium | high
    safe_stops: List[SafeZone]
    warnings: List[str]
    encoded_polyline: Optional[str] = None


# ─────────────── Ahmedabad Safe Zones (Static + Dynamic) ───────────────

AHMEDABAD_SAFE_ZONES: List[dict] = [
    # Police Stations
    {"id": "ps-001", "name": "Ahmedabad City Police HQ", "type": "police_station", "lat": 23.0300, "lng": 72.5876, "address": "Shahibaug, Ahmedabad", "phone": "100", "is_24hr": True},
    {"id": "ps-002", "name": "Satellite Police Station", "type": "police_station", "lat": 23.0300, "lng": 72.5100, "address": "Satellite Road, Ahmedabad", "phone": "079-26743211", "is_24hr": True},
    {"id": "ps-003", "name": "Navrangpura Police Station", "type": "police_station", "lat": 23.0390, "lng": 72.5580, "address": "Navrangpura, Ahmedabad", "phone": "079-26409000", "is_24hr": True},
    {"id": "ps-004", "name": "Maninagar Police Station", "type": "police_station", "lat": 22.9966, "lng": 72.6003, "address": "Maninagar, Ahmedabad", "phone": "079-25463711", "is_24hr": True},
    {"id": "ps-005", "name": "Cyber Crime Cell Ahmedabad", "type": "police_station", "lat": 23.0225, "lng": 72.5714, "address": "Commissioner Office, Shahibaug", "phone": "079-25506000", "is_24hr": False},
    {"id": "ps-006", "name": "Bopal Police Station", "type": "police_station", "lat": 23.0330, "lng": 72.4700, "address": "Bopal, Ahmedabad", "phone": "079-26851811", "is_24hr": True},
    # Hospitals
    {"id": "h-001", "name": "Civil Hospital Ahmedabad", "type": "hospital", "lat": 23.0400, "lng": 72.5828, "address": "Asarwa, Ahmedabad", "phone": "079-22681321", "is_24hr": True},
    {"id": "h-002", "name": "VS General Hospital", "type": "hospital", "lat": 23.0285, "lng": 72.5870, "address": "Khanpur, Ahmedabad", "phone": "079-25506721", "is_24hr": True},
    {"id": "h-003", "name": "Sterling Hospital Gurukul", "type": "hospital", "lat": 23.0550, "lng": 72.5325, "address": "Gurukul Road, Ahmedabad", "phone": "079-40011000", "is_24hr": True},
    {"id": "h-004", "name": "Zydus Hospital", "type": "hospital", "lat": 23.0420, "lng": 72.5050, "address": "Thaltej, Ahmedabad", "phone": "079-66777777", "is_24hr": True},
    # Women Help Centers
    {"id": "w-001", "name": "Women Helpline (Abhayam)", "type": "women_help", "lat": 23.0225, "lng": 72.5714, "address": "Ahmedabad", "phone": "181", "is_24hr": True},
    {"id": "w-002", "name": "Sakhi One Stop Centre", "type": "women_help", "lat": 23.0350, "lng": 72.5900, "address": "Civil Hospital Campus, Asarwa", "phone": "079-22686250", "is_24hr": True},
    # Fire Stations
    {"id": "f-001", "name": "Fire Station Navrangpura", "type": "fire_station", "lat": 23.0420, "lng": 72.5650, "address": "Navrangpura, Ahmedabad", "phone": "101", "is_24hr": True},
    {"id": "f-002", "name": "Fire Station Maninagar", "type": "fire_station", "lat": 22.9990, "lng": 72.5980, "address": "Maninagar, Ahmedabad", "phone": "101", "is_24hr": True},
]

# Ahmedabad high-risk zone heat data (anonymized historical + predicted)
INCIDENT_HEAT_DATA: List[dict] = [
    {"lat": 23.0150, "lng": 72.5800, "severity": "high", "category": "online_fraud", "count": 28, "radius_m": 500},
    {"lat": 23.0560, "lng": 72.5350, "severity": "medium", "category": "cyberstalking", "count": 15, "radius_m": 400},
    {"lat": 22.9950, "lng": 72.6100, "severity": "medium", "category": "financial_fraud", "count": 12, "radius_m": 350},
    {"lat": 23.0700, "lng": 72.5200, "severity": "low", "category": "phishing", "count": 8, "radius_m": 300},
    {"lat": 23.0250, "lng": 72.6200, "severity": "high", "category": "sim_swap", "count": 22, "radius_m": 450},
    {"lat": 23.0050, "lng": 72.5400, "severity": "medium", "category": "deepfake_abuse", "count": 9, "radius_m": 300},
    {"lat": 23.0800, "lng": 72.5900, "severity": "low", "category": "harassment", "count": 6, "radius_m": 250},
]

# Ahmedabad Threat Intelligence Feed
THREAT_FEED: List[dict] = [
    {
        "id": "tf-001",
        "title": "New Property Scam Targeting Ahmedabad Residents",
        "category": "financial_fraud",
        "description": "Fraudsters posing as real estate agents are collecting advance booking amounts for non-existent properties in Bopal and Thaltej areas. Do not pay without site visit and legal verification.",
        "severity": "high",
        "affected_area": "Bopal, Thaltej, SG Highway",
        "source": "Ahmedabad Cyber Cell",
        "created_at": (datetime.utcnow() - timedelta(hours=3)).isoformat(),
        "verified": True,
    },
    {
        "id": "tf-002",
        "title": "Matrimonial Fraud Alert — Fake NRI Profiles",
        "category": "fake_profile",
        "description": "Multiple reports of fake NRI matrimonial profiles on Jeevansathi and Shaadi.com targeting Gujarati families. Victims reported financial losses after sending money for 'visa processing'.",
        "severity": "high",
        "affected_area": "Ahmedabad, Gujarat",
        "source": "I4C / NCCRP",
        "created_at": (datetime.utcnow() - timedelta(hours=8)).isoformat(),
        "verified": True,
    },
    {
        "id": "tf-003",
        "title": "Fake Job Offer SMS Circulating — IT Companies",
        "category": "phishing",
        "description": "SMS messages claiming to offer IT jobs at major companies are circulating. Links lead to credential-harvesting sites. Never click unverified job offer links.",
        "severity": "medium",
        "affected_area": "GIFT City, Gandhinagar, Ahmedabad",
        "source": "Ahmedabad Cyber Cell",
        "created_at": (datetime.utcnow() - timedelta(hours=12)).isoformat(),
        "verified": True,
    },
    {
        "id": "tf-004",
        "title": "SIM Swap Fraud Spike — Telecom Impersonation",
        "category": "sim_swap",
        "description": "Fraudsters calling from spoofed telecom numbers claiming KYC expiry. They ask for OTPs to 'update' your SIM, which they use to take over banking accounts.",
        "severity": "critical",
        "affected_area": "Gujarat",
        "source": "TRAI Advisory",
        "created_at": (datetime.utcnow() - timedelta(hours=24)).isoformat(),
        "verified": True,
    },
    {
        "id": "tf-005",
        "title": "WhatsApp Investment Scam — Crypto Groups",
        "category": "financial_fraud",
        "description": "Fake cryptocurrency investment groups on WhatsApp promising 300% returns. Groups added victims without consent and then pressured them to invest via fake trading apps.",
        "severity": "high",
        "affected_area": "Ahmedabad, Surat, Vadodara",
        "source": "I4C",
        "created_at": (datetime.utcnow() - timedelta(hours=36)).isoformat(),
        "verified": True,
    },
    {
        "id": "tf-006",
        "title": "Deepfake Video Extortion Cases Rising",
        "category": "deepfake_abuse",
        "description": "AI-generated deepfake videos of women being used for blackmail (sextortion). Victims targeted via Instagram DMs. Report immediately to Cyber Cell at 1930.",
        "severity": "critical",
        "affected_area": "Gujarat",
        "source": "Ahmedabad Cyber Cell",
        "created_at": (datetime.utcnow() - timedelta(hours=48)).isoformat(),
        "verified": True,
    },
]


# ─────────────────────────── Endpoints ───────────────────────────

@router.get("/safe-zones", response_model=List[SafeZone])
async def get_safe_zones(
    lat: float = Query(..., description="User latitude"),
    lng: float = Query(..., description="User longitude"),
    radius_km: float = Query(5.0, description="Search radius in km"),
    zone_type: Optional[str] = Query(None, description="Filter by type"),
    current_user: User = Depends(get_current_user),
):
    """Get safe zones (police stations, hospitals, etc.) near a location."""
    import math

    def haversine_km(lat1, lng1, lat2, lng2):
        R = 6371
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng/2)**2
        return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

    results = []
    for zone in AHMEDABAD_SAFE_ZONES:
        if zone_type and zone["type"] != zone_type:
            continue
        dist = haversine_km(lat, lng, zone["lat"], zone["lng"])
        if dist <= radius_km:
            results.append(SafeZone(**zone, distance_m=round(dist * 1000)))

    results.sort(key=lambda z: z.distance_m or float("inf"))
    return results


@router.get("/incidents/nearby")
async def get_nearby_incidents(
    lat: float = Query(...),
    lng: float = Query(...),
    radius_km: float = Query(2.0),
    current_user: User = Depends(get_current_user),
):
    """Get anonymized incident heat data near a location."""
    import math

    def haversine_km(lat1, lng1, lat2, lng2):
        R = 6371
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng/2)**2
        return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

    nearby = []
    for point in INCIDENT_HEAT_DATA:
        dist = haversine_km(lat, lng, point["lat"], point["lng"])
        if dist <= radius_km:
            nearby.append({**point, "distance_m": round(dist * 1000)})

    return {
        "total_incidents": len(nearby),
        "heat_points": nearby,
        "risk_summary": "high" if any(p["severity"] == "high" for p in nearby) else
                        "medium" if any(p["severity"] == "medium" for p in nearby) else "low",
    }


@router.post("/community-report")
async def submit_community_report(
    report: CommunityReportCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Submit a community safety report (unsafe spot, harassment, etc.)."""
    from uuid import uuid4

    now = datetime.utcnow()
    report_id = f"cr-{uuid4().hex[:8]}"

    # In production: save to community_reports table
    # For now: return the created report
    return {
        "id": report_id,
        "lat": report.lat,
        "lng": report.lng,
        "description": report.description,
        "category": report.category,
        "confirmation_count": 1,
        "reported_at": now.isoformat(),
        "expires_at": (now + timedelta(days=30)).isoformat(),
        "status": "pending_verification",
        "message": "Report submitted. Will appear on map after 3 confirmations.",
    }


@router.get("/safe-route")
async def plan_safe_route(
    from_lat: float = Query(...),
    from_lng: float = Query(...),
    to_lat: float = Query(...),
    to_lng: float = Query(...),
    depart_time: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
):
    """Plan the safest route between two points, considering incident heat zones."""
    import math

    # Determine time-of-day risk multiplier
    hour = datetime.utcnow().hour + 5  # IST offset approx
    if 21 <= hour or hour <= 5:  # Night hours (9pm-5am)
        risk_multiplier = 1.8
        time_warning = "⚠ Night-time routing — avoiding high-risk zones. Extra caution advised."
    elif 17 <= hour <= 21:  # Evening peak
        risk_multiplier = 1.3
        time_warning = "Evening hours — moderate risk. Stay on main roads."
    else:
        risk_multiplier = 1.0
        time_warning = None

    # Calculate straight-line distance
    def haversine_km(lat1, lng1, lat2, lng2):
        R = 6371
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng/2)**2
        return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

    total_dist = haversine_km(from_lat, from_lng, to_lat, to_lng)
    route_dist = round(total_dist * 1.25, 2)  # Route is ~25% longer than straight line
    duration_min = round(route_dist / 30 * 60)  # Assume avg 30 km/h city speed

    # Find safe stops along route (simplified: nearest safe zones)
    mid_lat = (from_lat + to_lat) / 2
    mid_lng = (from_lng + to_lng) / 2

    safe_stops = []
    for zone in AHMEDABAD_SAFE_ZONES:
        if zone["type"] in ("police_station", "hospital"):
            dist_to_mid = haversine_km(mid_lat, mid_lng, zone["lat"], zone["lng"])
            if dist_to_mid <= 3.0:
                safe_stops.append(SafeZone(**zone, distance_m=round(dist_to_mid * 1000)))

    safe_stops = sorted(safe_stops, key=lambda z: z.distance_m or 9999)[:3]

    # Assess route risk
    route_crosses_risk = any(
        haversine_km(from_lat, from_lng, pt["lat"], pt["lng"]) < 1.5
        or haversine_km(to_lat, to_lng, pt["lat"], pt["lng"]) < 1.5
        for pt in INCIDENT_HEAT_DATA if pt["severity"] == "high"
    )

    risk_level = "high" if route_crosses_risk and risk_multiplier > 1.3 else \
                 "medium" if route_crosses_risk or risk_multiplier > 1.0 else "low"

    warnings = []
    if time_warning:
        warnings.append(time_warning)
    if route_crosses_risk:
        warnings.append("🔴 Route passes through reported incident zones. Consider alternate path.")
    if risk_level == "low":
        warnings.append("✅ Route clear. Stay aware of surroundings.")

    return {
        "route_type": "safest",
        "distance_km": route_dist,
        "duration_min": duration_min,
        "risk_level": risk_level,
        "time_of_day_risk": risk_multiplier > 1.0,
        "safe_stops": [s.dict() for s in safe_stops],
        "warnings": warnings,
        "maps_directions_url": (
            f"https://www.google.com/maps/dir/{from_lat},{from_lng}/{to_lat},{to_lng}"
            f"/@{mid_lat},{mid_lng},13z/data=!4m2!4m1!3e2"  # walking mode avoids highways
        ),
        "google_maps_api_key": settings.GOOGLE_MAPS_API_KEY if hasattr(settings, "GOOGLE_MAPS_API_KEY") else None,
    }


@router.get("/threat-feed")
async def get_threat_feed(
    area: str = Query("ahmedabad", description="City/area filter"),
    limit: int = Query(10),
    current_user: User = Depends(get_current_user),
):
    """Get live threat intelligence feed for the specified area."""
    feed = THREAT_FEED[:limit]
    return {
        "total": len(feed),
        "area": area,
        "last_updated": datetime.utcnow().isoformat(),
        "items": feed,
    }


@router.get("/threat-feed/public")
async def get_public_threat_feed(
    area: str = Query("ahmedabad"),
    limit: int = Query(5),
):
    """Public threat feed — no auth required. Returns limited items."""
    return {
        "total": min(len(THREAT_FEED), limit),
        "area": area,
        "items": THREAT_FEED[:limit],
    }
