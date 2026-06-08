import 'service_locator.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// @deprecated Use ServiceLocator instead
class AuthInjection {
  static AuthBloc createAuthBloc() => ServiceLocator.instance.createAuthBloc();
}
