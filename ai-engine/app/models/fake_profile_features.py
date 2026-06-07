"""Fake profile feature extraction for social media analysis."""


def extract_profile_features(profile_data: dict) -> dict:
    """Extract features from social media profile data."""
    followers = profile_data.get("followers", 0)
    following = profile_data.get("following", 0)
    posts = profile_data.get("posts", 0)
    bio = profile_data.get("bio", "")
    has_photo = profile_data.get("has_profile_photo", True)
    account_age_days = profile_data.get("account_age_days", 365)
    is_verified = profile_data.get("is_verified", False)
    has_url = profile_data.get("has_external_url", False)

    features = {
        "follower_count": followers,
        "following_count": following,
        "follower_following_ratio": following / max(followers, 1),
        "post_count": posts,
        "posts_per_day": posts / max(account_age_days, 1),
        "bio_length": len(bio),
        "has_profile_photo": has_photo,
        "account_age_days": account_age_days,
        "is_verified": is_verified,
        "has_external_url": has_url,
        "has_generic_username": _is_generic_username(profile_data.get("username", "")),
        "engagement_rate": _calc_engagement(followers, posts),
    }
    return features


def _is_generic_username(username: str) -> bool:
    """Check if username follows generic bot-like patterns."""
    import re
    # Patterns like user12345, john_doe_9382, random letter sequences
    if re.match(r"^[a-z]+\d{4,}$", username.lower()):
        return True
    if re.match(r"^[a-z]+_[a-z]+_\d{3,}$", username.lower()):
        return True
    if len(username) > 20:
        return True
    return False


def _calc_engagement(followers: int, posts: int) -> float:
    """Rough engagement estimate."""
    if followers == 0 or posts == 0:
        return 0.0
    return min(posts / max(followers, 1) * 100, 100.0)


def features_to_vector(features: dict) -> list[float]:
    """Convert profile features to numeric vector."""
    return [
        min(features["follower_count"] / 10000, 1.0),
        min(features["following_count"] / 10000, 1.0),
        min(features["follower_following_ratio"], 5.0) / 5.0,
        min(features["post_count"] / 500, 1.0),
        min(features["posts_per_day"], 10.0) / 10.0,
        min(features["bio_length"] / 150, 1.0),
        float(features["has_profile_photo"]),
        min(features["account_age_days"] / 1825, 1.0),
        float(features["is_verified"]),
        float(features["has_external_url"]),
        float(features["has_generic_username"]),
        min(features["engagement_rate"] / 100, 1.0),
    ]
