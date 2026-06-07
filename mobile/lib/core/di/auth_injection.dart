import 'package:flutter/material.dart';
import 'service_locator.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// @deprecated Use ServiceLocator instead
class AuthInjection {
  static AuthBloc createAuthBloc() => ServiceLocator.instance.createAuthBloc();
}
