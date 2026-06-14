import '../services/storage_service.dart';
import '../services/ai_api_service.dart';
import '../services/api_service.dart';
import '../services/evidence_api_service.dart';
import '../services/location_service.dart';
import '../services/report_api_service.dart';
import '../services/sos_api_service.dart';
import '../services/awareness_api_service.dart';
import '../services/guardian_api_service.dart';
import '../services/zone_api_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  late final ApiService api;
  late final StorageService storage;
  late final LocationService location;
  late final SosApiService sos;
  late final ReportApiService reports;
  late final EvidenceApiService evidence;
  late final AiApiService ai;
  late final GuardianApiService guardians;
  late final AwarenessApiService awareness;
  late final ZoneApiService zones;
  late final AuthRepository authRepository;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    api = ApiService();
    storage = StorageService();
    location = LocationService();
    sos = SosApiService(api);
    reports = ReportApiService(api);
    evidence = EvidenceApiService(api);
    ai = AiApiService(api);
    guardians = GuardianApiService(api);
    awareness = AwarenessApiService(api);
    zones = ZoneApiService(api);

    final token = await storage.getToken();
    if (token != null) api.setToken(token);

    final remote = AuthRemoteDataSource();
    authRepository = AuthRepositoryImpl(remote);
    _initialized = true;
  }

  AuthBloc createAuthBloc() {
    return AuthBloc(
      checkAuth: CheckAuthUseCase(authRepository),
      login: LoginUseCase(authRepository),
      register: RegisterUseCase(authRepository),
      verifyOtp: VerifyOtpUseCase(authRepository),
      sendOtp: SendOtpUseCase(authRepository),
      logout: LogoutUseCase(authRepository),
    );
  }
}
