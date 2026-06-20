from fastapi import APIRouter, WebSocket, WebSocketDisconnect

router = APIRouter(prefix="/ws/sos/location", tags=["SOS Location"])


class IncidentConnectionManager:
    def __init__(self):
        # incident_id -> set of websockets
        self.active: dict[str, set[WebSocket]] = {}

    async def connect(self, incident_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active.setdefault(incident_id, set()).add(websocket)

    def disconnect(self, incident_id: str, websocket: WebSocket):
        conns = self.active.get(incident_id)
        if not conns:
            return
        conns.discard(websocket)
        if not conns:
            self.active.pop(incident_id, None)

    async def broadcast(self, incident_id: str, message: dict):
        conns = list(self.active.get(incident_id, set()))
        for connection in conns:
            try:
                await connection.send_json(message)
            except Exception:
                # Best-effort; drop dead connections on next disconnect
                pass


manager = IncidentConnectionManager()


@router.websocket("/stream/{incident_id}")
async def incident_location_stream(websocket: WebSocket, incident_id: str):
    """Incident-scoped location streaming.

    Mobile clients connect to receive location updates and can optionally send updates.
    Server broadcasts any received JSON payload to all clients connected to same incident_id.
    """
    await manager.connect(incident_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            await manager.broadcast(incident_id, data)
    except WebSocketDisconnect:
        manager.disconnect(incident_id, websocket)

