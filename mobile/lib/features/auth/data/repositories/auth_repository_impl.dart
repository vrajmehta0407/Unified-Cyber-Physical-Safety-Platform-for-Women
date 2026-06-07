import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final StorageService _storage;
  final ApiService _api;

  AuthRepositoryImpl(this._remote, this._storage, this._api);

  Future<UserEntity> _persistSession(AuthResponseModel response) async {
    await _storage.saveToken(response.accessToken);
    await _storage.saveUserJson(jsonEncode(response.user.toJson()));
    _api.setToken(response.accessToken);
    return response.user.toEntity();
  }

  @override
  Future<UserEntity> login(String mobile, String password) async {
    try {
      final response = await _remote.login(mobile, password);
      return _persistSession(response);
    } on DioException catch (e) {
      throw Exception(_remote.parseError(e));
    }
  }

  @override
  Future<String> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) async {
    try {
      await _remote.register(name: name, mobile: mobile, email: email, password: password);
      await _remote.sendOtp(mobile);
      return mobile;
    } on DioException catch (e) {
      throw Exception(_remote.parseError(e));
    }
  }

  @override
  Future<void> sendOtp(String mobile) async {
    try {
      await _remote.sendOtp(mobile);
    } on DioException catch (e) {
      throw Exception(_remote.parseError(e));
    }
  }

  @override
  Future<UserEntity> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _remote.verifyOtp(mobile, otp);
      return _persistSession(response);
    } on DioException catch (e) {
      throw Exception(_remote.parseError(e));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    _api.setToken(token);
    try {
      final user = await _remote.getMe();
      await _storage.saveUserJson(jsonEncode(user.toJson()));
      return user.toEntity();
    } on DioException {
      final cached = await _storage.getUserJson();
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return UserModel.fromJson(json).toEntity();
      }
      await logout();
      return null;
    }
  }

  @override
  Future<bool> hasSession() => _storage.hasSession();

  @override
  Future<void> logout() async {
    await _storage.clearSession();
  }
}
