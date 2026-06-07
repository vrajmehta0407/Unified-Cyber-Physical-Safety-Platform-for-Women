# Saved Models Directory

This directory contains trained ML model files:
- `phishing_classifier.pkl` — RandomForest phishing URL classifier
- `fake_profile_model.pkl` — GradientBoosting fake profile detector

To generate these models, run the training scripts:
```bash
cd ai-engine
python -m app.training.train_phishing
python -m app.training.train_fake_profile
```
