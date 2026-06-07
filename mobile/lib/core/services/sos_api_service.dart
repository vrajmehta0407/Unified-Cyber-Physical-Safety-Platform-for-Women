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
}
