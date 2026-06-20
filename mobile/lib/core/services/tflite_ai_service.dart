import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// On-Device TensorFlow Lite AI Engine
/// Runs threat detection models locally without internet.
/// Supports: phishing URL analysis, deepfake image scoring, text threat scoring.
class TfliteAiService {
  static final TfliteAiService _instance = TfliteAiService._internal();
  factory TfliteAiService() => _instance;
  TfliteAiService._internal();

  Interpreter? _phishingInterpreter;
  Interpreter? _deepfakeInterpreter;
  bool _phishingLoaded = false;
  bool _deepfakeLoaded = false;

  // ──────────────────────────────────────────────────────────
  // INITIALIZATION
  // ──────────────────────────────────────────────────────────

  /// Load phishing detection model (text-based URL analysis).
  Future<bool> loadPhishingModel() async {
    try {
      _phishingInterpreter = await Interpreter.fromAsset(
        'assets/models/phishing_model.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      _phishingLoaded = true;
      debugPrint('[TFLite] Phishing model loaded');
      return true;
    } catch (e) {
      debugPrint('[TFLite] Phishing model load failed: $e (using server fallback)');
      _phishingLoaded = false;
      return false;
    }
  }

  /// Load deepfake detection model (image-based classification).
  Future<bool> loadDeepfakeModel() async {
    try {
      _deepfakeInterpreter = await Interpreter.fromAsset(
        'assets/models/deepfake_model.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      _deepfakeLoaded = true;
      debugPrint('[TFLite] Deepfake model loaded');
      return true;
    } catch (e) {
      debugPrint('[TFLite] Deepfake model load failed: $e (using server fallback)');
      _deepfakeLoaded = false;
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────
  // PHISHING URL ANALYSIS (On-Device)
  // ──────────────────────────────────────────────────────────

  /// Analyze a URL for phishing risk on-device.
  /// Returns a [ThreatResult] with score 0.0–1.0 and label.
  Future<ThreatResult> analyzeUrl(String url) async {
    if (!_phishingLoaded) {
      // Heuristic fallback when model not available
      return _heuristicUrlAnalysis(url);
    }

    try {
      // Tokenize URL to fixed-length float32 input [1, 200]
      final input = _tokenizeUrl(url, maxLen: 200);
      final output = List.filled(2, 0.0).reshape([1, 2]);

      _phishingInterpreter!.run(input.reshape([1, 200]), output);

      final score = output[0][1] as double; // probability of phishing
      return ThreatResult(
        score: score,
        label: score > 0.7 ? 'PHISHING' : score > 0.4 ? 'SUSPICIOUS' : 'SAFE',
        confidence: score > 0.5 ? score : 1.0 - score,
        source: 'on-device',
      );
    } catch (e) {
      debugPrint('[TFLite] URL inference error: $e');
      return _heuristicUrlAnalysis(url);
    }
  }

  ThreatResult _heuristicUrlAnalysis(String url) {
    final lower = url.toLowerCase();
    double score = 0.0;

    // Strong phishing signals
    if (lower.contains('login') && !lower.contains('.gov')) score += 0.15;
    if (lower.contains('verify') || lower.contains('secure-')) score += 0.15;
    if (lower.contains('bank') && !RegExp(r'\.bank\.(in|com)$').hasMatch(lower)) score += 0.2;
    if (lower.contains('paypal') || lower.contains('paytm') && !lower.endsWith('.com')) score += 0.25;
    if (lower.contains('bit.ly') || lower.contains('tinyurl')) score += 0.15;
    if (RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(lower)) score += 0.3;
    if (lower.contains('.xyz') || lower.contains('.tk') || lower.contains('.ml')) score += 0.2;
    if (lower.split('.').length > 4) score += 0.1;
    if (lower.contains('free') && lower.contains('win')) score += 0.25;

    score = score.clamp(0.0, 1.0);
    return ThreatResult(
      score: score,
      label: score > 0.5 ? 'PHISHING' : score > 0.25 ? 'SUSPICIOUS' : 'SAFE',
      confidence: 0.75,
      source: 'heuristic',
    );
  }

  List<double> _tokenizeUrl(String url, {required int maxLen}) {
    final chars = url.codeUnits.take(maxLen).map((c) => c / 127.0).toList();
    while (chars.length < maxLen) chars.add(0.0);
    return chars;
  }

  // ──────────────────────────────────────────────────────────
  // DEEPFAKE IMAGE DETECTION (On-Device)
  // ──────────────────────────────────────────────────────────

  /// Analyze an image file for deepfake manipulation on-device.
  /// Returns a [ThreatResult] with score and label.
  Future<ThreatResult> analyzeImageForDeepfake(File imageFile) async {
    if (!_deepfakeLoaded) {
      return ThreatResult(
        score: 0.0,
        label: 'UNKNOWN',
        confidence: 0.0,
        source: 'unavailable',
        message: 'On-device model not loaded. Using server analysis.',
      );
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Could not decode image');

      // Resize to model input size (224x224 for MobileNet-based models)
      final resized = img.copyResize(decoded, width: 224, height: 224);

      // Normalize to [-1, 1]
      final input = List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            (pixel.r / 127.5) - 1.0,
            (pixel.g / 127.5) - 1.0,
            (pixel.b / 127.5) - 1.0,
          ];
        })
      );

      final output = List.filled(2, 0.0).reshape([1, 2]);
      _deepfakeInterpreter!.run([input], output);

      final score = output[0][1] as double;
      return ThreatResult(
        score: score,
        label: score > 0.65 ? 'DEEPFAKE' : score > 0.35 ? 'SUSPICIOUS' : 'AUTHENTIC',
        confidence: score > 0.5 ? score : 1.0 - score,
        source: 'on-device',
      );
    } catch (e) {
      debugPrint('[TFLite] Image inference error: $e');
      return ThreatResult(
        score: 0.0,
        label: 'ERROR',
        confidence: 0.0,
        source: 'error',
        message: e.toString(),
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // TEXT THREAT SCORING (Heuristic — no model needed)
  // ──────────────────────────────────────────────────────────

  /// Score an SMS or message for threat signals.
  ThreatResult analyzeSmsText(String text) {
    final lower = text.toLowerCase();
    double score = 0.0;

    const highRiskWords = [
      'otp', 'password', 'account suspended', 'verify immediately',
      'click here', 'you won', 'prize money', 'urgent action',
      'bank details', 'aadhar', 'pan card', 'kyc', 'arrest warrant',
      'income tax', 'emi overdue', 'last warning',
    ];
    const mediumRiskWords = [
      'free', 'limited offer', 'claim now', 'congratulations',
      'loan approved', 'job offer', 'work from home', 'earn daily',
    ];

    for (final w in highRiskWords) {
      if (lower.contains(w)) score += 0.12;
    }
    for (final w in mediumRiskWords) {
      if (lower.contains(w)) score += 0.07;
    }
    if (RegExp(r'http[s]?://').hasMatch(lower)) score += 0.1;
    if (RegExp(r'\b\d{10}\b').hasMatch(text)) score += 0.05;

    score = score.clamp(0.0, 1.0);
    return ThreatResult(
      score: score,
      label: score > 0.5 ? 'SCAM' : score > 0.25 ? 'SUSPICIOUS' : 'SAFE',
      confidence: 0.8,
      source: 'heuristic',
    );
  }

  void dispose() {
    _phishingInterpreter?.close();
    _deepfakeInterpreter?.close();
  }
}

// ──────────────────────────────────────────────────────────
// RESULT MODEL
// ──────────────────────────────────────────────────────────

class ThreatResult {
  final double score;
  final String label;
  final double confidence;
  final String source;
  final String? message;

  const ThreatResult({
    required this.score,
    required this.label,
    required this.confidence,
    required this.source,
    this.message,
  });

  bool get isThreat => score > 0.5;
  bool get isSuspicious => score > 0.25 && score <= 0.5;
  bool get isSafe => score <= 0.25;

  String get scorePercent => '${(score * 100).toStringAsFixed(0)}%';

  @override
  String toString() =>
      'ThreatResult(label: $label, score: $scorePercent, confidence: $confidence, source: $source)';
}
