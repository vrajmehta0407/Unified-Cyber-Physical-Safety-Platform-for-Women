"""Model loader with caching for the AI engine."""

import os
import threading
from pathlib import Path
from typing import Any, Optional

_cache: dict[str, Any] = {}
_lock = threading.Lock()

MODELS_DIR = Path(__file__).resolve().parent.parent / "models" / "saved_models"


def get_model(model_name: str) -> Optional[Any]:
    """Load a model by name with thread-safe caching.

    Supports:
    - .pkl files (scikit-learn, loaded via joblib)
    - .h5 files (TensorFlow/Keras)
    """
    with _lock:
        if model_name in _cache:
            return _cache[model_name]

    model_path_pkl = MODELS_DIR / f"{model_name}.pkl"
    model_path_h5 = MODELS_DIR / f"{model_name}.h5"

    model = None

    if model_path_pkl.exists():
        try:
            import joblib
            model = joblib.load(model_path_pkl)
        except ImportError:
            import pickle
            with open(model_path_pkl, "rb") as f:
                model = pickle.load(f)

    elif model_path_h5.exists():
        try:
            from tensorflow import keras
            model = keras.models.load_model(model_path_h5)
        except ImportError:
            pass

    if model is not None:
        with _lock:
            _cache[model_name] = model

    return model


def is_model_available(model_name: str) -> bool:
    """Check if a trained model file exists."""
    return (
        (MODELS_DIR / f"{model_name}.pkl").exists()
        or (MODELS_DIR / f"{model_name}.h5").exists()
    )


def list_available_models() -> list[str]:
    """List all available model files."""
    if not MODELS_DIR.exists():
        return []
    models = []
    for f in MODELS_DIR.iterdir():
        if f.suffix in (".pkl", ".h5"):
            models.append(f.stem)
    return models
