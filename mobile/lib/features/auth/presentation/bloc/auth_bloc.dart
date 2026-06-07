import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthUseCase _checkAuth;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final VerifyOtpUseCase _verifyOtp;
  final SendOtpUseCase _sendOtp;
  final LogoutUseCase _logout;

  AuthBloc({
    required CheckAuthUseCase checkAuth,
    required LoginUseCase login,
    required RegisterUseCase register,
    required VerifyOtpUseCase verifyOtp,
    required SendOtpUseCase sendOtp,
    required LogoutUseCase logout,
  })  : _checkAuth = checkAuth,
        _login = login,
        _register = register,
        _verifyOtp = verifyOtp,
        _sendOtp = sendOtp,
        _logout = logout,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthOtpVerifyRequested>(_onVerifyOtp);
    on<AuthOtpResendRequested>(_onResendOtp);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _checkAuth();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _login(event.mobile, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final mobile = await _register(
        name: event.name,
        mobile: event.mobile,
        email: event.email,
        password: event.password,
      );
      emit(AuthOtpSent(mobile));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(AuthOtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _verifyOtp(event.mobile, event.otp);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onResendOtp(AuthOtpResendRequested event, Emitter<AuthState> emit) async {
    try {
      await _sendOtp(event.mobile);
      emit(AuthOtpSent(event.mobile));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
