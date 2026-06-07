"""Training script for the fake profile detector.

Usage:
    cd ai-engine
    python -m app.training.train_fake_profile

Trains a GradientBoosting classifier on fake_profiles.csv and saves to saved_models/fake_profile_model.pkl
"""

import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from app.models.fake_profile_features import extract_profile_features, features_to_vector


def main():
    dataset_path = Path(__file__).parent / "datasets" / "fake_profiles.csv"
    if not dataset_path.exists():
        print(f"Dataset not found: {dataset_path}")
        return

    print("Loading dataset...")
    df = pd.read_csv(dataset_path)
    print(f"Loaded {len(df)} samples")

    print("Extracting features...")
    X = []
    y = []
    for _, row in df.iterrows():
        profile_data = {
            "followers": row.get("followers", 0),
            "following": row.get("following", 0),
            "posts": row.get("posts", 0),
            "bio": row.get("bio", ""),
            "has_profile_photo": bool(row.get("has_profile_photo", True)),
            "account_age_days": row.get("account_age_days", 365),
            "is_verified": bool(row.get("is_verified", False)),
            "has_external_url": bool(row.get("has_external_url", False)),
            "username": row.get("username", ""),
        }
        features = extract_profile_features(profile_data)
        vector = features_to_vector(features)
        X.append(vector)
        y.append(int(row["label"]))

    X = np.array(X)
    y = np.array(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    print(f"Train: {len(X_train)}, Test: {len(X_test)}")

    print("Training GradientBoosting classifier...")
    clf = GradientBoostingClassifier(n_estimators=100, max_depth=5, random_state=42)
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"\nAccuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=["Real", "Fake"]))

    output_dir = Path(__file__).parent.parent / "models" / "saved_models"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / "fake_profile_model.pkl"

    try:
        import joblib
        joblib.dump(clf, output_path)
    except ImportError:
        import pickle
        with open(output_path, "wb") as f:
            pickle.dump(clf, f)

    print(f"\nModel saved to {output_path}")


if __name__ == "__main__":
    main()
