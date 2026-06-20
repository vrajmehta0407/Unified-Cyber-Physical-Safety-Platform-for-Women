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
    try {
      final response = await _api.post(ApiConstants.authLogin, data: {
        'mobile': mobile,
        'password': password,
      });
      final data = response.data;
      return AuthResponseModel(
        accessToken: data['access_token'],
        user: UserModel.fromJson(data['user']),
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) async {
    try {
      final response = await _api.post(ApiConstants.authRegister, data: {
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
      });
      final data = response.data;
      return {
        'user': UserModel.fromJson(data['user']),
        'devOtp': data['otp_dev_only'], // Shown as fallback if SMS fails
        'smsSent': data['otp_dev_only'] == null, // Twilio handles SMS on backend
      };
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<String> sendOtp(String mobile) async {
    try {
      final response = await _api.post(ApiConstants.authOtpSend, data: {
        'mobile': mobile,
      });
      return response.data['otp_dev_only'] ?? ''; 
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<AuthResponseModel> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _api.post(ApiConstants.authOtpVerify, data: {
        'mobile': mobile,
        'otp': otp,
      });
      final data = response.data;
      return AuthResponseModel(
        accessToken: data['access_token'],
        user: UserModel.fromJson(data['user']),
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<UserModel> getMe(String userId) async {
    try {
      final response = await _api.get(ApiConstants.authMe);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    if (e.response?.data != null && e.response?.data['detail'] != null) {
      return e.response!.data['detail'].toString();
    }
    return e.message ?? 'Unknown error occurred';
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
