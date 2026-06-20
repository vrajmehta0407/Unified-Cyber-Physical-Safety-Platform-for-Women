from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.config import get_settings
from app.database import Base, SessionLocal, engine
from app.middleware.audit_logger import AuditLoggerMiddleware
from app.middleware.rate_limiter import RateLimiterMiddleware
from app.utils.seed_awareness import seed_awareness_content
from app.utils.seed_users import seed_demo_users

settings = get_settings()

app = FastAPI(
    title="CyberShield API",
    description="Cyber-Integrated Safety Platform for Women — KANADSHIELD26_P2_01",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list if getattr(settings, "cors_origins_list", None) else ["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(AuditLoggerMiddleware)
app.add_middleware(RateLimiterMiddleware, max_requests=100, window_seconds=60)

app.include_router(api_router, prefix="/api/v1")


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_demo_users(db)
        seed_awareness_content(db)
    finally:
        db.close()


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "cybershield-backend"}


class ConnectionManager:
    def __init__(self):
        self.active: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active:
            self.active.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active:
            await connection.send_json(message)


sos_manager = ConnectionManager()


@app.websocket("/ws/sos")
async def sos_websocket(websocket: WebSocket):
    await sos_manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            await sos_manager.broadcast(data)
    except WebSocketDisconnect:
        sos_manager.disconnect(websocket)
