import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class AiApiService {
  final ApiService _api;
  AiApiService(this._api);

  Future<Map<String, dynamic>> checkPhishing(String url, {String? text}) async {
    try {
      final response = await _api.post(ApiConstants.aiPhishing, data: {
        'url': url,
        'text': text,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<Map<String, dynamic>> analyzeFakeProfile({
    required String username,
    String platform = 'instagram',
    Map<String, dynamic>? profileData,
  }) async {
    try {
      final response = await _api.post(ApiConstants.aiFakeProfile, data: {
        'username': username,
        'platform': platform,
        'profile_data': profileData ?? {},
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<Map<String, dynamic>> detectDeepfake(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await _api.upload(ApiConstants.aiDeepfake, formData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
