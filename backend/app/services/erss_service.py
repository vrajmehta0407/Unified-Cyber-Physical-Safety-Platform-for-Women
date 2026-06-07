from uuid import uuid4


def dispatch_erss_alert(lat: float, lng: float, emergency_type: str = "physical_threat") -> dict:
    """Mock ERSS 112 emergency dispatch."""
    return {
        "incident_id": f"ERSS-{uuid4().hex[:8].upper()}",
        "rescue_team": "Ahmedabad Emergency Response Unit",
        "location": {"lat": lat, "lng": lng},
        "emergency_type": emergency_type,
        "eta_minutes": 4,
        "distance_km": 1.2,
        "status": "dispatched",
    }
