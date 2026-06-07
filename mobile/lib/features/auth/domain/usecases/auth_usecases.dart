import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);
  Future<UserEntity> call(String mobile, String password) =>
      _repository.login(mobile, password);
}

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);
  Future<String> call({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) =>
      _repository.register(name: name, mobile: mobile, email: email, password: password);
}

class VerifyOtpUseCase {
  final AuthRepository _repository;
  VerifyOtpUseCase(this._repository);
  Future<UserEntity> call(String mobile, String otp) =>
      _repository.verifyOtp(mobile, otp);
}

class CheckAuthUseCase {
  final AuthRepository _repository;
  CheckAuthUseCase(this._repository);
  Future<UserEntity?> call() => _repository.getCurrentUser();
}

class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);
  Future<void> call() => _repository.logout();
}

class SendOtpUseCase {
  final AuthRepository _repository;
  SendOtpUseCase(this._repository);
  Future<void> call(String mobile) => _repository.sendOtp(mobile);
}
