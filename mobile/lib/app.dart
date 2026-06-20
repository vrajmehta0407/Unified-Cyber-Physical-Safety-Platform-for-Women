import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/sos/presentation/pages/sos_page.dart';
import 'features/sos/presentation/pages/offline_sos_page.dart';
import 'features/sos/presentation/pages/fake_call_sos_page.dart';
import 'features/sos/presentation/pages/live_stream_page.dart';
import 'features/tracking/presentation/pages/live_tracking_page.dart';
import 'features/tracking/presentation/pages/unsafe_zone_page.dart';
import 'features/cybercrime_report/presentation/pages/report_form_page.dart';
import 'features/evidence/presentation/pages/upload_evidence_page.dart';
import 'features/evidence/presentation/pages/blockchain_verification_page.dart';
import 'features/ai_protection/presentation/pages/phishing_checker_page.dart';
import 'features/ai_protection/presentation/pages/fake_profile_detector_page.dart';
import 'features/ai_protection/presentation/pages/deepfake_checker_page.dart';
import 'features/ai_protection/presentation/pages/social_media_scanner_page.dart';
import 'features/ai_protection/presentation/pages/ai_tools_home_page.dart';
import 'features/guardian/presentation/pages/guardian_management_page.dart';
import 'features/guardian/presentation/pages/community_safety_page.dart';
import 'features/guardian/presentation/pages/connected_devices_page.dart';
import 'features/guardian/presentation/pages/missing_person_page.dart';
import 'features/awareness/presentation/pages/awareness_home_page.dart';
import 'features/auth/presentation/pages/language_selection_page.dart';
import 'features/cybercrime_report/presentation/pages/complaint_tracker_page.dart';
import 'features/cybercrime_report/presentation/pages/report_hub_page.dart';
import 'features/tracking/presentation/pages/safety_map_page.dart';
import 'features/auth/presentation/pages/onboarding_carousel_page.dart';
import 'shared/pages/home_page.dart';
import 'shared/pages/settings_page.dart';

class CyberShieldApp extends StatelessWidget {
  const CyberShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.instance.createAuthBloc()..add(const AuthCheckRequested()),
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp.router(
              title: 'CyberShield',
              themeMode: themeProvider.mode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isAuth = authState is AuthAuthenticated;
    final loc = state.matchedLocation;
    final isPublicRoute = loc == '/splash' || loc == '/login' || loc == '/register' || loc == '/otp' || loc == '/onboarding';

    if (!isAuth && !isPublicRoute) return '/login';
    if (isAuth && (loc == '/login' || loc == '/register')) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingCarouselPage()),
    GoRoute(path: '/language', builder: (_, __) => const LanguageSelectionPage()),
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/otp', builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return OtpVerificationPage(
        mobile: extra?['mobile'] as String?,
        devOtp: extra?['devOtp'] as String?,
      );
    }),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    GoRoute(path: '/sos', builder: (_, __) => const SosPage()),
    GoRoute(path: '/offline-sos', builder: (_, __) => const OfflineSosPage()),
    GoRoute(path: '/fake-call-sos', builder: (_, __) => const FakeCallSosPage()),
    GoRoute(
      path: '/live-stream',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final incidentId = extra?['incidentId'] as String? ?? 'unknown';
        final isViewer = extra?['isViewer'] as bool? ?? false;
        return LiveStreamPage(incidentId: incidentId, isViewer: isViewer);
      },
    ),
    GoRoute(path: '/tracking', builder: (_, __) => const LiveTrackingPage()),
    GoRoute(path: '/unsafe-zones', builder: (_, __) => const UnsafeZonePage()),
    GoRoute(
      path: '/report',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final category = extra?['category'] as String?;
        return ReportFormPage(initialCategory: category);
      },
    ),
    GoRoute(path: '/evidence', builder: (_, __) => const UploadEvidencePage()),
    GoRoute(path: '/blockchain', builder: (_, __) => const BlockchainVerificationPage()),
    GoRoute(path: '/phishing', builder: (_, __) => const PhishingCheckerPage()),
    GoRoute(path: '/deepfake', builder: (_, __) => const DeepfakeCheckerPage()),
    GoRoute(path: '/fake-profile', builder: (_, __) => const FakeProfileDetectorPage()),
    GoRoute(path: '/social-scanner', builder: (_, __) => const SocialMediaScannerPage()),
    GoRoute(path: '/ai-tools', builder: (_, __) => const AiToolsHomePage()),
    GoRoute(path: '/guardians', builder: (_, __) => const GuardianManagementPage()),
    GoRoute(path: '/community', builder: (_, __) => const CommunitySafetyPage()),
    GoRoute(path: '/devices', builder: (_, __) => const ConnectedDevicesPage()),
    GoRoute(path: '/missing-person', builder: (_, __) => const MissingPersonPage()),
    GoRoute(path: '/awareness', builder: (_, __) => const AwarenessHomePage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(path: '/report-hub', builder: (_, __) => const ReportHubPage()),
    GoRoute(path: '/my-complaints', builder: (_, __) => const ComplaintTrackerPage()),
    GoRoute(path: '/safety-map', builder: (_, __) => const SafetyMapPage()),
  ],
);
