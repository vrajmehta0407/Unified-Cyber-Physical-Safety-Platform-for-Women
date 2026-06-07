from uuid import uuid4


def sync_to_cctns(report_id: str, category: str, description: str) -> dict:
    """Mock CCTNS integration — complaint sync."""
    return {
        "cctns_id": f"CCTNS-{uuid4().hex[:8].upper()}",
        "fir_number": f"FIR/2024/{uuid4().hex[:4].upper()}",
        "status": "registered",
        "police_station": "Cyber Crime Branch, Ahmedabad",
    }


def get_cctns_status(cctns_id: str) -> dict:
    return {
        "cctns_id": cctns_id,
        "status": "investigation_in_progress",
        "assigned_io": "IO Sharma",
    }
