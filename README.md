# 🛡️ CyberShield — Cyber-Integrated Safety Platform for Women
## KANADSHIELD26_P2_01 | Ahmedabad City Police Cyber Crime Branch

---

## 🏗️ Architecture Overview

```
cybershield/
├── mobile/          Flutter App (Android + iOS)  ← User-facing app
├── backend/         FastAPI REST API + WebSockets ← Core server
├── ai-engine/       AI/ML Microservice            ← Phishing/deepfake/zones
├── dashboard/       React Police Dashboard        ← Police command center
└── docker/          Docker deployment configs
```

---

## 🚀 Quick Start (Docker — Recommended)

```bash
# 1. Clone & enter directory
git clone <repo_url> && cd cybershield

# 2. Copy env file
cp .env.example .env

# 3. Start everything
docker-compose up --build

# Services:
# Backend API:      http://localhost:8000
# API Docs:         http://localhost:8000/docs
# AI Engine:        http://localhost:8001
# Police Dashboard: http://localhost:3000
```

---

## 📱 Mobile App Setup

```bash
cd mobile/
flutter pub get

# For Android emulator (default):
flutter run

# For physical device — update api_constants.dart first:
# baseUrl = 'http://YOUR_PC_IP:8000/api/v1'

# Build APK:
flutter build apk --debug     # Quick demo APK
flutter build apk --release   # Production APK
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Demo Credentials:**
| Mobile | Password | Role |
|--------|----------|------|
| 9876543210 | password123 | User (victim) |
| 9999999999 | police123 | Police officer |
| 9000000001 | admin123 | Admin |

---

## 🖥️ Police Dashboard Setup

```bash
cd dashboard/
npm install
npm run dev
# Open: http://localhost:5173

# Login: 9999999999 / police123
```

---

## ⚙️ Backend Setup (Without Docker)

```bash
cd backend/

# Install dependencies
pip install -r requirements.txt

# Start PostgreSQL (or use Docker):
docker run -d -p 5432:5432 -e POSTGRES_USER=cybershield -e POSTGRES_PASSWORD=cybershield -e POSTGRES_DB=cybershield postgres:16-alpine

# Run backend
uvicorn app.main:app --reload --port 8000

# API Docs: http://localhost:8000/docs
# The DB tables and demo users are seeded automatically on startup
```

---

## 🤖 AI Engine Setup (Without Docker)

```bash
cd ai-engine/
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001

# Health check: http://localhost:8001/health
```

---

## 📋 Feature Coverage

### Mobile App (Flutter)
| Feature | Description |
|---------|-------------|
| 🚨 SOS Emergency | Big panic button, voice trigger, silent mode, cancel |
| 📡 Offline SMS SOS | GPS coordinates via SMS without internet |
| 🗺️ Live GPS Tracking | Real-time location with share |
| 📝 Cybercrime Report | 8 categories: stalking, harassment, deepfake abuse, fraud... |
| 🔒 Evidence Vault | AES-256 encrypted upload + SHA-256 hash |
| ⛓️ Blockchain Verify | Hash-based evidence verification |
| 🔍 Phishing Checker | AI URL/SMS risk analysis |
| 👤 Fake Profile Detector | Social media profile analysis |
| 🎭 Deepfake Detector | Image/video authenticity check |
| 📷 Social Media Scanner | Multi-platform profile risk scan |
| 👥 Guardian Management | Emergency contacts with auto-notify on SOS |
| 🤝 Community Safety | Volunteer network + safety check-in |
| ⌚ Wearable Devices | Smartwatch SOS integration |
| 🗺️ Unsafe Zone Map | AI-predicted high-risk areas in Ahmedabad |
| 📚 Safety Awareness | Articles in English, Hindi, Gujarati |
| 🔐 Auth | JWT + OTP (mobile-based) |

### Backend (FastAPI)
| Endpoint Group | Routes |
|----------------|--------|
| Auth | /auth/register, /login, /otp/send, /otp/verify, /me |
| SOS | /sos/trigger, /cancel, /active, /status/:id |
| Evidence | /evidence/upload, /list, /verify/:hash |
| Reports | /reports/ (CRUD) |
| Guardians | /guardians/ (CRUD) |
| AI Protection | /ai/phishing, /fake-profile, /deepfake, /unsafe-zone |
| Tracking | /tracking/live, /history/:id |
| Awareness | /awareness/articles (CRUD, multi-language) |
| Analytics | /analytics/dashboard, /patterns |
| Integrations | /integrations/cctns/:id, /erss/active |
| Notifications | /notifications/, /send, /read |
| WebSocket | /ws/sos (real-time SOS broadcast) |

### AI Engine (FastAPI Microservice)
| Model | Endpoint |
|-------|----------|
| Phishing Classifier | POST /predict/phishing |
| Fake Profile Scorer | POST /predict/fake-profile |
| Deepfake Detector | POST /predict/deepfake |
| Unsafe Zone Predictor | GET /predict/unsafe-zone |
| Crime Pattern Analysis | GET /analytics/pattern |

### Police Dashboard (React)
- Live SOS Map (Leaflet + OpenStreetMap)
- Real-time SOS alerts (auto-refresh)
- Incident management (list, detail, status update)
- Complaint management with CCTNS integration
- Evidence review
- Unsafe zone heatmap
- ERSS 112 dispatch simulation
- Crime trend analytics (Recharts)
- User management (Admin)
- Content management (awareness articles)

---

## 🗄️ Database

PostgreSQL with 12 tables:
`users`, `guardians`, `incidents`, `location_logs`, `evidence`, `chain_of_custody`,
`cyber_reports`, `report_updates`, `ai_scan_results`, `notifications`, `awareness_content`, `audit_logs`

Tables auto-created on first startup. Demo data seeded automatically.

---

## 🔒 Security Features

- JWT authentication (7-day tokens)
- OTP verification (6-digit, 5-minute expiry)
- AES-256-GCM evidence encryption
- SHA-256 file hashing + chain of custody
- Rate limiting (100 req/min)
- Audit logging (all API actions)
- Role-based access (user / police / admin)

---

## 📞 Integrations

- **ERSS 112**: Simulated emergency dispatch on every SOS trigger
- **CCTNS**: Mock complaint sync with FIR number generation
- **Auto-FIR**: Draft FIR with applicable IPC sections

---

*CyberShield — KANADSHIELD26_P2_01 | Built for Ahmedabad City Police Cyber Crime Branch Hackathon*
