"""URL feature extraction for phishing detection."""

import re
from urllib.parse import urlparse


def extract_url_features(url: str) -> dict:
    """Extract features from a URL for phishing classification."""
    parsed = urlparse(url if "://" in url else f"http://{url}")
    domain = parsed.netloc or parsed.path.split("/")[0]

    features = {
        "url_length": len(url),
        "domain_length": len(domain),
        "has_https": url.lower().startswith("https"),
        "has_ip_address": bool(re.match(r"\d+\.\d+\.\d+\.\d+", domain)),
        "num_dots": domain.count("."),
        "num_hyphens": domain.count("-"),
        "num_slashes": url.count("/"),
        "num_at_signs": url.count("@"),
        "num_params": url.count("&") + (1 if "?" in url else 0),
        "has_redirect": "//" in url[8:],
        "path_length": len(parsed.path),
        "subdomain_count": max(0, domain.count(".") - 1),
        "has_suspicious_tld": any(domain.endswith(t) for t in [".tk", ".ml", ".ga", ".cf", ".gq", ".xyz", ".top", ".pw"]),
        "has_suspicious_keywords": bool(re.search(
            r"(login|verify|secure|update|confirm|account|bank|paypal|signin|free|prize|winner|urgent|click|action|suspend)",
            url.lower(),
        )),
        "uses_shortener": any(s in domain.lower() for s in ["bit.ly", "tinyurl", "goo.gl", "t.co", "is.gd", "buff.ly", "ow.ly"]),
        "has_encoding": "%" in url,
        "digit_ratio": sum(c.isdigit() for c in domain) / max(len(domain), 1),
    }
    return features


def features_to_vector(features: dict) -> list[float]:
    """Convert feature dict to a numeric vector for ML model input."""
    return [
        features["url_length"] / 200,
        features["domain_length"] / 50,
        float(features["has_https"]),
        float(features["has_ip_address"]),
        features["num_dots"] / 5,
        features["num_hyphens"] / 5,
        features["num_slashes"] / 10,
        features["num_at_signs"],
        features["num_params"] / 5,
        float(features["has_redirect"]),
        features["path_length"] / 100,
        features["subdomain_count"] / 3,
        float(features["has_suspicious_tld"]),
        float(features["has_suspicious_keywords"]),
        float(features["uses_shortener"]),
        float(features["has_encoding"]),
        features["digit_ratio"],
    ]
