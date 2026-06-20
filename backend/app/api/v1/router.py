from fastapi import APIRouter

from app.api.v1.endpoints import (
    ai_protection,
    analytics,
    auth,
    awareness,
    broadcasts,
    evidence,
    guardians,
    incidents,
    integrations,
    map,
    notifications,
    officers,
    reports,
    sos,
    sos_resolve,
    tracking,
    users,
    ws_sos_location,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(sos.router)
api_router.include_router(sos_resolve.router)

api_router.include_router(ws_sos_location.router)

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
api_router.include_router(broadcasts.router)
api_router.include_router(officers.router)


