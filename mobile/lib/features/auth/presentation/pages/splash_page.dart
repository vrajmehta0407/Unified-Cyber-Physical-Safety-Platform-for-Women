import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _shieldCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _shieldScale;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  String _selectedLang = 'EN';

  @override
  void initState() {
    super.initState();
    _shieldCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _shieldScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _shieldCtrl, curve: Curves.elasticOut));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

    _shieldCtrl.forward().then((_) => _fadeCtrl.forward());
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _shieldCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go('/home');
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0A1A), Color(0xFF1A0D35), Color(0xFF0F0A1A)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.06),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Animated shield logo
                    ScaleTransition(
                      scale: _shieldScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                AppColors.primary.withOpacity(0.2),
                                Colors.transparent,
                              ]),
                            ),
                          ),
                          // Shield container
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                              ],
                            ),
                            child: const Icon(Icons.security, size: 56, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // App name + tagline
                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (b) => const LinearGradient(
                                colors: AppColors.primaryGradient,
                              ).createShader(b),
                              child: Text(
                                'CyberShield',
                                style: GoogleFonts.outfit(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Safety, Our Priority',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    // CTA buttons
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            _buildGetStartedButton(context),
                            const SizedBox(height: 14),
                            _buildLoginButton(context),
                            const SizedBox(height: 32),
                            _buildLanguageSelector(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/onboarding'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: Text('Get Started',
              style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Text('Login',
              style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Language: ', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
        ...['EN', 'हिंदी', 'ગુજ'].map((lang) {
          final isSelected = _selectedLang == lang;
          return GestureDetector(
            onTap: () => setState(() => _selectedLang = lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                lang,
                style: GoogleFonts.outfit(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
