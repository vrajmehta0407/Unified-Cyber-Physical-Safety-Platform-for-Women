import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _local;
  final FlutterSecureStorage _storage;

  static const _kToken   = 'cs_access_token';
  static const _kUserJson = 'cs_user_json';

  AuthRepositoryImpl(this._local) : _storage = const FlutterSecureStorage();

  Future<UserEntity> _persistSession(String token, UserModel user) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUserJson, value: jsonEncode(user.toJson()));
    return user.toEntity();
  }

  @override
  Future<UserEntity> login(String mobile, String password) async {
    try {
      final resp = await _local.login(mobile, password);
      return _persistSession(resp.accessToken, resp.user);
    } catch (e) {
      throw Exception(_local.parseError(e));
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
      final result = await _local.register(
          name: name, mobile: mobile, email: email, password: password);
      final devOtp = result['devOtp'] as String?;
      return (mobile, devOtp);
    } catch (e) {
      throw Exception(_local.parseError(e));
    }
  }

  @override
  Future<String?> sendOtp(String mobile) async {
    try {
      return await _local.sendOtp(mobile);
    } catch (e) {
      throw Exception(_local.parseError(e));
    }
  }

  @override
  Future<UserEntity> verifyOtp(String mobile, String otp) async {
    try {
      final resp = await _local.verifyOtp(mobile, otp);
      return _persistSession(resp.accessToken, resp.user);
    } catch (e) {
      throw Exception(_local.parseError(e));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _storage.read(key: _kToken);
    if (token == null || token.isEmpty) return null;

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
  }
}
