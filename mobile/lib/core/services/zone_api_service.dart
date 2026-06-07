import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class ZoneApiService {
  final ApiService _api;
  ZoneApiService(this._api);

  Future<Map<String, dynamic>> getUnsafeZones({String city = 'Ahmedabad'}) async {
    try {
      final response = await _api.get(ApiConstants.aiUnsafeZone, queryParameters: {'city': city});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
