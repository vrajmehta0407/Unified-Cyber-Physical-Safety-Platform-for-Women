"""Data preprocessing utilities for the AI engine."""

import re
from typing import Optional


def normalize_url(url: str) -> str:
    """Normalize a URL for consistent processing."""
    url = url.strip().lower()
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    # Remove trailing slash
    return url.rstrip("/")


def clean_text(text: str) -> str:
    """Clean text input for NLP processing."""
    text = text.strip()
    # Remove extra whitespace
    text = re.sub(r"\s+", " ", text)
    # Remove special Unicode characters
    text = text.encode("ascii", "ignore").decode("ascii")
    return text


def normalize_score(score: float, min_val: float = 0, max_val: float = 100) -> float:
    """Clamp a score to [min_val, max_val] range."""
    return max(min_val, min(score, max_val))


def safe_divide(a: float, b: float, default: float = 0.0) -> float:
    """Safe division that returns default on zero divisor."""
    return a / b if b != 0 else default


def validate_base64(data: str) -> Optional[bytes]:
    """Validate and decode base64 data, return None on failure."""
    import base64
    try:
        return base64.b64decode(data, validate=True)
    except Exception:
        return None


def image_metadata(content: bytes) -> dict:
    """Extract basic image metadata using Pillow."""
    try:
        from PIL import Image
        import io
        img = Image.open(io.BytesIO(content))
        return {
            "format": img.format,
            "width": img.width,
            "height": img.height,
            "mode": img.mode,
            "is_animated": getattr(img, "is_animated", False),
        }
    except Exception:
        return {"format": "unknown", "width": 0, "height": 0, "mode": "unknown", "is_animated": False}
