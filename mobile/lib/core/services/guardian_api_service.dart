import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_parser.dart';
import 'api_service.dart';

class GuardianApiService {
  final ApiService _api;
  GuardianApiService(this._api);

  Future<List<Map<String, dynamic>>> listGuardians() async {
    try {
      final response = await _api.get(ApiConstants.guardians);
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<void> addGuardian({required String name, required String phone, String? relation}) async {
    try {
      await _api.post(ApiConstants.guardians, data: {
        'name': name,
        'phone': phone,
        'relation': relation,
      });
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<void> removeGuardian(String id) async {
    try {
      await _api.delete('${ApiConstants.guardians}$id');
    } on DioException catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
