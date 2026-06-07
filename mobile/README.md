# CyberShield Mobile App

Flutter cross-platform app for Android and iOS.

## Setup

```bash
# After Flutter SDK is installed:
cd mobile
flutter create . --org com.cybershield --project-name cybershield
flutter pub get
flutter run
```

## API Configuration

- Android emulator: `http://10.0.2.2:8000/api/v1` (default in api_constants.dart)
- iOS simulator: change to `http://localhost:8000/api/v1`
- Physical device: use your PC's LAN IP, e.g. `http://192.168.1.5:8000/api/v1`

## Permissions

After `flutter create`, ensure AndroidManifest.xml includes:
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` (SOS, tracking)
- `INTERNET`
- `RECORD_AUDIO` (voice SOS)
- `SEND_SMS` (offline SMS fallback)

## Features

- SOS Emergency (silent & voice)
- Live GPS tracking
- Cybercrime reporting
- Evidence vault with encryption
- AI protection tools (phishing, fake profile, deepfake)
- Offline SMS fallback
