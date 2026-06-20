import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Firebase Cloud Messaging Service
/// Handles push notifications for SOS updates, police alerts, and guardian messages.
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotif;
  String? _fcmToken;

  /// Stream of incoming messages (can be listened to from anywhere in the app)
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messages => _messageController.stream;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM — call this in main.dart after Firebase.initializeApp()
  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;

    // Request permission
    await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Setup local notifications (for foreground display)
    _localNotif = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif!.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create high-importance notification channel (Android)
    const channel = AndroidNotificationChannel(
      'cybershield_sos',
      'CyberShield SOS Alerts',
      description: 'Critical SOS and safety alerts from CyberShield',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _localNotif!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Get token
    _fcmToken = await _messaging!.getToken();
    debugPrint('[FCM] Token: $_fcmToken');

    // Refresh token listener
    _messaging!.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('[FCM] Token refreshed: $token');
      // TODO: send refreshed token to backend /users/me/fcm_token
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage msg) async {
    _messageController.add(msg);
    _showLocalNotification(msg);
  }

  void _handleMessageTap(RemoteMessage msg) {
    _messageController.add(msg);
    // Route based on data payload
    final type = msg.data['type'] as String?;
    debugPrint('[FCM] Notification tapped — type: $type');
    // Navigation is handled externally via the messages stream listener
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Local notification tapped: ${response.payload}');
  }

  Future<void> _showLocalNotification(RemoteMessage msg) async {
    final notification = msg.notification;
    if (notification == null) return;

    final isSOS = msg.data['type'] == 'sos_alert';
    const androidDetails = AndroidNotificationDetails(
      'cybershield_sos',
      'CyberShield SOS Alerts',
      channelDescription: 'Critical SOS and safety alerts',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      color: Color(0xFFFF3B6B),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _localNotif!.show(
      notification.hashCode,
      isSOS ? '🚨 ${notification.title}' : notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: msg.data['type'],
    );
  }

  /// Subscribe to a topic (e.g. 'ahmedabad_alerts')
  Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
  }

  /// Send token to backend (call after login)
  Future<void> registerTokenWithBackend(String Function() tokenGetter) async {
    // Implement API call: POST /users/me/fcm_token { token: _fcmToken }
    debugPrint('[FCM] Register token with backend: $_fcmToken');
  }

  void dispose() {
    _messageController.close();
  }
}

/// Background message handler — MUST be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}
