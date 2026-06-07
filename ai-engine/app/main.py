from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.endpoints import deepfake, fake_profile, pattern, phishing, unsafe_zone

app = FastAPI(title="CyberShield AI Engine", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(phishing.router)
app.include_router(fake_profile.router)
app.include_router(deepfake.router)
app.include_router(unsafe_zone.router)
app.include_router(pattern.router)


@app.get("/health")
def health():
    return {"status": "ok", "service": "cybershield-ai-engine"}
