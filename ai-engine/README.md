# CyberShield AI Engine

ML microservice for phishing detection, fake profile analysis, and deepfake detection.

## Endpoints

- `POST /predict/phishing` — URL/SMS phishing classifier
- `POST /predict/fake-profile` — Social media profile risk scorer
- `POST /predict/deepfake` — Image/video deepfake detection
- `GET /predict/unsafe-zone` — Unsafe zone heatmap data
- `GET /analytics/pattern` — Crime pattern analytics

## Run

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```
