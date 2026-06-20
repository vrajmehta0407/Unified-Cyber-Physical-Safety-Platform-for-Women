import 'package:shake/shake.dart';

/// Shake-to-SOS Service
/// Detects phone shake gesture and triggers SOS callback.
/// Usage: call [startListening] with a callback, [stopListening] to deactivate.
class ShakeSosService {
  ShakeDetector? _detector;
  bool _isActive = false;

  bool get isActive => _isActive;

  /// Start listening for shake gestures.
  /// [onShake] is called when shake is detected.
  /// [shakeSensitivity] — lower = more sensitive (default 15).
  void startListening({
    required VoidCallback onShake,
    double shakeSensitivity = 15.0,
    int minimumShakeCount = 2,
  }) {
    _detector?.stopListening();
    _detector = ShakeDetector.autoStart(
      onPhoneShake: (_) => onShake(),
      shakeThresholdGravity: shakeSensitivity,
      minimumShakeCount: minimumShakeCount,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
    );
    _isActive = true;
  }

  /// Stop listening for shake gestures.
  void stopListening() {
    _detector?.stopListening();
    _detector = null;
    _isActive = false;
  }

  void dispose() {
    stopListening();
  }
}

// Typedef for convenience
typedef VoidCallback = void Function();
