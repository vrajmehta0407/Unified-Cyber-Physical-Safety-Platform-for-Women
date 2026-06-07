import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class EvidenceApiService {
  final ApiService _api;
  EvidenceApiService(this._api);

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    String? incidentId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
        if (incidentId != null) 'incident_id': incidentId,
      });
      final response = await _api.upload(ApiConstants.evidenceUpload, formData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<List<Map<String, dynamic>>> listEvidence() async {
    try {
      final response = await _api.get(ApiConstants.evidenceList);
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<Map<String, dynamic>> verifyHash(String hash) async {
    try {
      final response = await _api.get('${ApiConstants.evidenceVerify}/$hash');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
