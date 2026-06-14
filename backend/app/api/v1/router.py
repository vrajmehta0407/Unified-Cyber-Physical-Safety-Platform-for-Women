from fastapi import APIRouter

from app.api.v1.endpoints import (
    ai_protection,
    analytics,
    auth,
    awareness,
    evidence,
    guardians,
    incidents,
    integrations,
    map,
    notifications,
    reports,
    sos,
    tracking,
    users,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(sos.router)
api_router.include_router(incidents.router)
api_router.include_router(evidence.router)
api_router.include_router(reports.router)
api_router.include_router(guardians.router)
api_router.include_router(integrations.router)
api_router.include_router(ai_protection.router)
api_router.include_router(tracking.router)
api_router.include_router(notifications.router)
api_router.include_router(analytics.router)
api_router.include_router(awareness.router)
api_router.include_router(map.router)

