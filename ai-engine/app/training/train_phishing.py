"""Training script for the phishing URL classifier.

Usage:
    cd ai-engine
    python -m app.training.train_phishing

Trains a RandomForest classifier on phishing_urls.csv and saves to saved_models/phishing_classifier.pkl
"""

import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from app.models.phishing_features import extract_url_features, features_to_vector


def main():
    dataset_path = Path(__file__).parent / "datasets" / "phishing_urls.csv"
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
        features = extract_url_features(row["url"])
        vector = features_to_vector(features)
        X.append(vector)
        y.append(int(row["label"]))

    X = np.array(X)
    y = np.array(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    print(f"Train: {len(X_train)}, Test: {len(X_test)}")

    print("Training RandomForest classifier...")
    clf = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42)
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"\nAccuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=["Legitimate", "Phishing"]))

    # Save model
    output_dir = Path(__file__).parent.parent / "models" / "saved_models"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / "phishing_classifier.pkl"

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
