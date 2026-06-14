import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/sms_otp_service.dart';
import '../../domain/entities/user_entity.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Fully offline local authentication data source.
/// No backend server required — all data stored encrypted on-device.
/// OTPs are delivered via SMS text message to the user's phone number.
class AuthRemoteDataSource {
  final FlutterSecureStorage _store = const FlutterSecureStorage();
  final SmsOtpService _smsService = SmsOtpService();

  static const _kUsers = 'cs_local_users';
  static const _kOtps  = 'cs_local_otps';

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final raw = await _store.read(key: _kUsers);
    if (raw == null || raw.isEmpty) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    await _store.write(key: _kUsers, value: jsonEncode(users));
  }

  Future<Map<String, String>> _getOtps() async {
    final raw = await _store.read(key: _kOtps);
    if (raw == null || raw.isEmpty) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  Future<void> _saveOtps(Map<String, String> otps) async {
    await _store.write(key: _kOtps, value: jsonEncode(otps));
  }

  String _newId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      Random().nextInt(999999).toRadixString(36);

  String _newOtp() => (100000 + Random().nextInt(900000)).toString();

  String _localToken(String userId) =>
      base64Url.encode(utf8.encode('local:$userId'));

  UserModel _toModel(Map<String, dynamic> u) => UserModel(
        id: u['id'] as String,
        name: u['name'] as String,
        mobile: u['mobile'] as String,
        email: u['email'] as String?,
        role: u['role'] as String? ?? 'user',
      );

  // ── Pre-seeded demo accounts ──────────────────────────────────────────────

  Future<void> _ensureDemoUsers() async {
    final users = await _getUsers();
    final existing = users.map((u) => u['mobile'] as String).toSet();

    const demos = [
      {'name': 'Ananya Sharma',  'mobile': '9876543210', 'password': 'password123', 'role': 'user'},
      {'name': 'Officer Sharma', 'mobile': '9999999999', 'password': 'police123',   'role': 'police'},
      {'name': 'Admin Singh',    'mobile': '9000000001', 'password': 'admin123',    'role': 'admin'},
    ];

    bool changed = false;
    for (final d in demos) {
      if (!existing.contains(d['mobile'])) {
        users.add({
          'id': _newId(),
          'name': d['name'],   'mobile': d['mobile'],
          'email': null,       'password': d['password'],
          'role': d['role'],
        });
        changed = true;
      }
    }
    if (changed) await _saveUsers(users);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<AuthResponseModel> login(String mobile, String password) async {
    await _ensureDemoUsers();
    final users = await _getUsers();
    final hits = users.where((u) => u['mobile'] == mobile).toList();
    if (hits.isEmpty) throw Exception('Mobile number not registered');
    if (hits.first['password'] != password) throw Exception('Incorrect password');

    final model = _toModel(hits.first);
    return AuthResponseModel(accessToken: _localToken(model.id), user: model);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) async {
    await _ensureDemoUsers();
    final users = await _getUsers();
    if (users.any((u) => u['mobile'] == mobile)) {
      throw Exception('Mobile number already registered');
    }
    if (email != null && email.isNotEmpty && users.any((u) => u['email'] == email)) {
      throw Exception('Email already registered');
    }

    final newUser = {
      'id': _newId(), 'name': name, 'mobile': mobile,
      'email': email, 'password': password, 'role': 'user',
    };
    users.add(newUser);
    await _saveUsers(users);

    final otp = _newOtp();
    final otps = await _getOtps()..putIfAbsent(mobile, () => otp);
    otps[mobile] = otp;
    await _saveOtps(otps);

    // Send OTP via SMS text message
    bool smsSent = false;
    try {
      smsSent = await _smsService.sendOtp(phoneNumber: mobile, otp: otp);
    } catch (_) {
      // SMS failed — fall back to on-screen display
    }

    return {
      'user': _toModel(newUser),
      'devOtp': otp,
      'smsSent': smsSent,
    };
  }

  Future<String> sendOtp(String mobile) async {
    await _ensureDemoUsers();
    final users = await _getUsers();
    if (!users.any((u) => u['mobile'] == mobile)) {
      throw Exception('Mobile number not registered');
    }
    final otp = _newOtp();
    final otps = await _getOtps();
    otps[mobile] = otp;
    await _saveOtps(otps);

    // Send OTP via SMS text message
    try {
      await _smsService.sendOtp(phoneNumber: mobile, otp: otp);
    } catch (_) {
      // SMS failed — OTP still returned for on-screen display
    }

    return otp;
  }

  Future<AuthResponseModel> verifyOtp(String mobile, String otp) async {
    final otps = await _getOtps();
    final stored = otps[mobile];
    if (stored == null || stored != otp.trim()) {
      throw Exception('Invalid OTP. Please check the code sent to your phone via SMS.');
    }
    otps.remove(mobile);
    await _saveOtps(otps);

    final users = await _getUsers();
    final hits = users.where((u) => u['mobile'] == mobile).toList();
    if (hits.isEmpty) throw Exception('User not found');
    final model = _toModel(hits.first);
    return AuthResponseModel(accessToken: _localToken(model.id), user: model);
  }

  Future<UserModel> getMe(String userId) async {
    final users = await _getUsers();
    final hits = users.where((u) => u['id'] == userId).toList();
    if (hits.isEmpty) throw Exception('Session expired. Please login again.');
    return _toModel(hits.first);
  }

  String parseError(dynamic e) =>
      e.toString().replaceFirst('Exception: ', '');
}

extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id, name: name, mobile: mobile, email: email, role: role,
      );
}
