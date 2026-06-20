import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class SosApiService {
  final ApiService _api;
  SosApiService(this._api);

  Future<Map<String, dynamic>> triggerSos({
    required double lat,
    required double lng,
    bool isSilent = false,
  }) async {
    try {
      final response = await _api.post(ApiConstants.sosTrigger, data: {
        'lat': lat,
        'lng': lng,
        'is_silent': isSilent,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<Map<String, dynamic>> cancelSos(String incidentId) async {
    try {
      final response = await _api.post(ApiConstants.sosCancel, data: {
        'incident_id': incidentId,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<Map<String, dynamic>> resolveSos(String incidentId) async {
    try {
      final response = await _api.post(ApiConstants.sosResolve(incidentId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<List<dynamic>> getActiveSos() async {
    try {
      final response = await _api.get(ApiConstants.sosActive);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  /// Send WebRTC signaling data (offer/answer/ICE) to backend
  Future<void> sendWebRtcSignal({
    required String incidentId,
    required Map<String, dynamic> signal,
  }) async {
    try {
      await _api.post(
        '/sos/$incidentId/webrtc/signal',
        data: signal,
      );
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}

