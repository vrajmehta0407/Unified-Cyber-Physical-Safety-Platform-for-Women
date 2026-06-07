from sqlalchemy.orm import Session

from app.models import AwarenessContent

AWARENESS_ARTICLES = [
    {
        "title": "Stay Safe Online",
        "body": "Never share OTPs or passwords with anyone claiming to be from banks or police. Verify caller identity before sharing personal details.",
        "category": "cyber_safety",
        "language": "en",
    },
    {
        "title": "Using SOS Feature",
        "body": "In emergencies, tap the SOS button. Your live location is shared with guardians and police. Silent SOS sends alerts without sound.",
        "category": "app_guide",
        "language": "en",
    },
    {
        "title": "Evidence Collection Tips",
        "body": "Screenshot chats, save URLs, and record dates. Upload evidence through the app — files are encrypted and hash-verified on blockchain.",
        "category": "evidence",
        "language": "en",
    },
    {
        "title": "ऑनलाइन सुरक्षित रहें",
        "body": "OTP या पासवर्ड किसी के साथ साझा न करें। बैंक या पुलिस का दावा करने वालों से सावधान रहें।",
        "category": "cyber_safety",
        "language": "hi",
    },
    {
        "title": "ઓનલાઇન સુરક્ષિત રહો",
        "body": "OTP અથવા પાસવર્ડ કોઈ સાથે શેર ન કરો. બેંક અથવા પોલીસનો દાવો કરનારાથી સાવચેત રહો.",
        "category": "cyber_safety",
        "language": "gu",
    },
]


def seed_awareness_content(db: Session) -> None:
    for article in AWARENESS_ARTICLES:
        exists = (
            db.query(AwarenessContent)
            .filter(AwarenessContent.title == article["title"], AwarenessContent.language == article["language"])
            .first()
        )
        if exists:
            continue
        db.add(AwarenessContent(**article))
    db.commit()
