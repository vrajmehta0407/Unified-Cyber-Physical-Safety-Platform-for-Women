import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final ApiService _api;
  final FlutterSecureStorage _storage;

  static const _kToken   = 'cs_access_token';
  static const _kUserJson = 'cs_user_json';

  AuthRepositoryImpl(this._remote, this._api)
      : _storage = const FlutterSecureStorage();

  /// Saves token + user locally AND injects the token into ApiService so all
  /// subsequent HTTP calls are authenticated immediately.
  Future<UserEntity> _persistSession(String token, UserModel user) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUserJson, value: jsonEncode(user.toJson()));
    _api.setToken(token); // ← KEY FIX: inject into Dio headers right away
    return user.toEntity();
  }

  @override
  Future<UserEntity> login(String mobile, String password) async {
    try {
      final resp = await _remote.login(mobile, password);
      return _persistSession(resp.accessToken, resp.user);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<(String, String?)> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) async {
    try {
      final result = await _remote.register(
          name: name, mobile: mobile, email: email, password: password);
      final devOtp = result['devOtp'] as String?;
      return (mobile, devOtp);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String?> sendOtp(String mobile) async {
    try {
      return await _remote.sendOtp(mobile);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyOtp(String mobile, String otp) async {
    try {
      final resp = await _remote.verifyOtp(mobile, otp);
      return _persistSession(resp.accessToken, resp.user);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _storage.read(key: _kToken);
    if (token == null || token.isEmpty) return null;

    // Re-inject token into ApiService on app restart
    _api.setToken(token);

    try {
      final cachedJson = await _storage.read(key: _kUserJson);
      if (cachedJson == null) return null;
      final json = jsonDecode(cachedJson) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasSession() async {
    final token = await _storage.read(key: _kToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUserJson);
    _api.setToken(''); // Clear token from Dio headers
  }
}
