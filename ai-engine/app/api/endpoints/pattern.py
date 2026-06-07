from fastapi import APIRouter

router = APIRouter(prefix="/analytics", tags=["Pattern Analysis"])


@router.get("/pattern")
def get_crime_patterns():
    return {
        "incident_trend": [
            {"month": "Jan", "count": 78},
            {"month": "Feb", "count": 92},
            {"month": "Mar", "count": 85},
            {"month": "Apr", "count": 110},
            {"month": "May", "count": 95},
            {"month": "Jun", "count": 88},
        ],
        "crime_categories": [
            {"category": "Harassment", "percentage": 30},
            {"category": "Cyber Fraud", "percentage": 25},
            {"category": "Stalking", "percentage": 15},
            {"category": "Blackmail", "percentage": 10},
            {"category": "Others", "percentage": 20},
        ],
        "top_hotspots": [
            {"area": "Maninagar", "incidents": 45},
            {"area": "Bapunagar", "incidents": 38},
            {"area": "Navrangpura", "incidents": 28},
        ],
        "repeat_offenders": [
            {"name": "Offender A", "incidents": 5},
            {"name": "Offender B", "incidents": 3},
        ],
    }
