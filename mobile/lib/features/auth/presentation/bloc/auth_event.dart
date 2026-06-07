import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String mobile;
  final String password;
  const AuthLoginRequested({required this.mobile, required this.password});
  @override
  List<Object?> get props => [mobile, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String mobile;
  final String? email;
  final String password;
  const AuthRegisterRequested({
    required this.name,
    required this.mobile,
    this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, mobile, email, password];
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String mobile;
  final String otp;
  const AuthOtpVerifyRequested({required this.mobile, required this.otp});
  @override
  List<Object?> get props => [mobile, otp];
}

class AuthOtpResendRequested extends AuthEvent {
  final String mobile;
  const AuthOtpResendRequested(this.mobile);
  @override
  List<Object?> get props => [mobile];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
