import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String mobile, String password);
  Future<(String, String?)> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  });
  Future<String?> sendOtp(String mobile);
  Future<UserEntity> verifyOtp(String mobile, String otp);
  Future<UserEntity?> getCurrentUser();
  Future<bool> hasSession();
  Future<void> logout();
}
