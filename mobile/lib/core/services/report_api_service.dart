import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class ReportApiService {
  final ApiService _api;
  ReportApiService(this._api);

  Future<Map<String, dynamic>> submitReport({
    required String category,
    required String description,
  }) async {
    try {
      final response = await _api.post(ApiConstants.reports, data: {
        'category': category,
        'description': description,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<List<Map<String, dynamic>>> listReports() async {
    try {
      final response = await _api.get(ApiConstants.reports);
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
