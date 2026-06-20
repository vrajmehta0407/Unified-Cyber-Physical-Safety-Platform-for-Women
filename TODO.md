# TODO — CyberShield SOS Screen 7/8/9 Production Implementation

## Backend
- [ ] Add incident-scoped websocket: `WS /api/v1/ws/sos/location/stream/{incident_id}` (or adapt current WS)
- [ ] Add `POST /api/v1/sos/resolve/{incident_id}` endpoint
- [ ] Ensure SOS trigger returns correct incident id used by mobile

## Mobile
- [ ] Replace `LiveTrackingPage` placeholder map with `GoogleMap` + dark style + pulsing beacon
- [ ] Remove hardcoded fallback coords in live tracking (show error state instead)
- [ ] Upgrade `SosPage` to countdown (3-2-1), shake-trigger bypass, active emergency red view, status chips
- [ ] Wire SOS resolve button (“I Am Safe”) to backend resolve endpoint

## Validation (when Docker works)
- [ ] Run backend containers and verify Swagger endpoints
- [ ] Flutter debug run on Android emulator/device
- [ ] Verify SOS activation -> live tracking updates -> resolve

