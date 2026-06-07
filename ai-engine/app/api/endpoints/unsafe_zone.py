from fastapi import APIRouter

router = APIRouter(prefix="/predict", tags=["Unsafe Zone"])


# Ahmedabad sample zones
ZONES = [
    {"name": "Maninagar", "lat": 23.0036, "lng": 72.6015, "risk": "high", "incidents": 45},
    {"name": "Navrangpura", "lat": 23.0360, "lng": 72.5611, "risk": "medium", "incidents": 28},
    {"name": "Satellite", "lat": 23.0225, "lng": 72.5714, "risk": "low", "incidents": 12},
    {"name": "Vastrapur", "lat": 23.0395, "lng": 72.5240, "risk": "medium", "incidents": 22},
    {"name": "Bapunagar", "lat": 23.0390, "lng": 72.6380, "risk": "high", "incidents": 38},
]


@router.get("/unsafe-zone")
def get_unsafe_zones(city: str = "Ahmedabad"):
    high = sum(1 for z in ZONES if z["risk"] == "high")
    medium = sum(1 for z in ZONES if z["risk"] == "medium")
    low = sum(1 for z in ZONES if z["risk"] == "low")
    return {
        "city": city,
        "zones": ZONES,
        "statistics": {
            "high_risk_areas": high,
            "medium_risk_areas": medium,
            "low_risk_areas": low,
            "total_incidents": sum(z["incidents"] for z in ZONES),
        },
    }
