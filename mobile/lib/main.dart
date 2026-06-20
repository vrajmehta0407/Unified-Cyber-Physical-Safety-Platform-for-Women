import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0F1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── Firebase ──────────────────────────────────────────
  // NOTE: google-services.json (Android) and GoogleService-Info.plist (iOS)
  // must be placed in android/app/ and ios/Runner/ respectively.
  // Download from Firebase Console → Project Settings.
  try {
    await Firebase.initializeApp();
    // Register background message handler BEFORE calling other Firebase functions
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);
    // Initialize FCM service
    await FcmService().initialize();
    // Subscribe to Ahmedabad alerts topic
    await FcmService().subscribeToTopic('ahmedabad_cyber_alerts');
    debugPrint('[Main] Firebase + FCM initialized');
  } catch (e) {
    // Firebase init failure is non-fatal (app works without it in dev mode)
    debugPrint('[Main] Firebase init error (non-fatal): $e');
  }

  // ── App Services ──────────────────────────────────────
  await ServiceLocator.instance.init();

  runApp(const CyberShieldApp());
}
