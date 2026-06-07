import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/user_entity.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiService _api;

  AuthRemoteDataSource(this._api);

  Future<AuthResponseModel> login(String mobile, String password) async {
    final response = await _api.post(ApiConstants.authLogin, data: {
      'mobile': mobile,
      'password': password,
    });
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) async {
    final response = await _api.post(ApiConstants.authRegister, data: {
      'name': name,
      'mobile': mobile,
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> sendOtp(String mobile) async {
    await _api.post(ApiConstants.authOtpSend, data: {'mobile': mobile});
  }

  Future<AuthResponseModel> verifyOtp(String mobile, String otp) async {
    final response = await _api.post(ApiConstants.authOtpVerify, data: {
      'mobile': mobile,
      'otp': otp,
    });
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final response = await _api.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  String parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) return detail.first.toString();
    }
    return 'Something went wrong. Please try again.';
  }
}

extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        mobile: mobile,
        email: email,
        role: role,
      );
}
