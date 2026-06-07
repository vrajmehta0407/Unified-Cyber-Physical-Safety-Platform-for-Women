import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class AwarenessApiService {
  final ApiService _api;
  AwarenessApiService(this._api);

  Future<List<Map<String, dynamic>>> getArticles({String language = 'en'}) async {
    try {
      final response = await _api.get(ApiConstants.awarenessArticles, queryParameters: {'language': language});
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
