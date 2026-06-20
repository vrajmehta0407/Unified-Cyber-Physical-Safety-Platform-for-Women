import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Firebase Realtime Database — SOS Location Streaming Service
/// Streams real-time GPS coordinates from victim device to police dashboard
/// during an active SOS incident.
class FirebaseRtdbService {
  static final FirebaseRtdbService _instance = FirebaseRtdbService._internal();
  factory FirebaseRtdbService() => _instance;
  FirebaseRtdbService._internal();

  FirebaseDatabase get _db => FirebaseDatabase.instance;
  StreamSubscription? _locationSub;
  Timer? _locationTimer;

  /// Start pushing the user's live location to RTDB every 5 seconds.
  /// [incidentId] — SOS incident UUID
  /// [userId] — current user UUID
  /// [getPosition] — async function that returns {lat, lng}
  Future<void> startStreaming({
    required String incidentId,
    required String userId,
    required Future<Map<String, double>> Function() getPosition,
  }) async {
    _locationTimer?.cancel();
    debugPrint('[RTDB] Starting location stream for incident: $incidentId');

    // Write initial status
    await _db.ref('sos/$incidentId').update({
      'userId': userId,
      'status': 'active',
      'startedAt': DateTime.now().toIso8601String(),
    });

    // Stream location every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await getPosition();
        await _db.ref('sos/$incidentId/location').set({
          'lat': pos['lat'],
          'lng': pos['lng'],
          'updatedAt': DateTime.now().toIso8601String(),
        });
        debugPrint('[RTDB] Location pushed: ${pos['lat']}, ${pos['lng']}');
      } catch (e) {
        debugPrint('[RTDB] Location push error: $e');
      }
    });
  }

  /// Stop streaming and mark incident resolved.
  Future<void> stopStreaming({
    required String incidentId,
    String status = 'resolved',
  }) async {
    _locationTimer?.cancel();
    _locationTimer = null;
    debugPrint('[RTDB] Stopping location stream for incident: $incidentId');
    try {
      await _db.ref('sos/$incidentId').update({
        'status': status,
        'endedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[RTDB] Stop stream error: $e');
    }
  }

  /// Listen to another user's SOS (for guardian / police use).
  Stream<Map<String, dynamic>?> watchIncident(String incidentId) {
    return _db
        .ref('sos/$incidentId')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return null;
          return Map<String, dynamic>.from(data as Map);
        });
  }

  /// Get all active SOS incidents (police dashboard).
  Stream<List<Map<String, dynamic>>> watchAllActiveSos() {
    return _db
        .ref('sos')
        .orderByChild('status')
        .equalTo('active')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return [];
          final map = Map<String, dynamic>.from(data as Map);
          return map.entries
              .map((e) => {
                    'id': e.key,
                    ...Map<String, dynamic>.from(e.value as Map),
                  })
              .toList();
        });
  }

  /// Write a broadcast advisory to RTDB (for police to push alerts).
  Future<void> pushBroadcastAdvisory({
    required String title,
    required String message,
    required String zone,
    String type = 'advisory',
  }) async {
    final key = _db.ref('broadcasts').push().key;
    await _db.ref('broadcasts/$key').set({
      'title': title,
      'message': message,
      'zone': zone,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Stream broadcast advisories for display in app.
  Stream<List<Map<String, dynamic>>> watchBroadcasts() {
    return _db
        .ref('broadcasts')
        .limitToLast(20)
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return [];
          final map = Map<String, dynamic>.from(data as Map);
          return map.entries
              .map((e) => {
                    'id': e.key,
                    ...Map<String, dynamic>.from(e.value as Map),
                  })
              .toList()
              .reversed
              .toList();
        });
  }

  void dispose() {
    _locationTimer?.cancel();
    _locationSub?.cancel();
  }
}
