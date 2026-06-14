import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingCarouselPage extends StatefulWidget {
  const OnboardingCarouselPage({super.key});

  @override
  State<OnboardingCarouselPage> createState() => _OnboardingCarouselPageState();
}

class _OnboardingCarouselPageState extends State<OnboardingCarouselPage>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Per-slide animation controllers
  late final List<AnimationController> _iconCtrls;
  late final List<Animation<double>> _iconScales;
  late final List<Animation<double>> _iconFades;

  static const _slides = [
    _SlideData(
      gradientColors: [Color(0xFF1A0A2E), Color(0xFF2D1045)],
      accentColor: Color(0xFFEF4444),
      icon: Icons.emergency_share_rounded,
      iconBg: [Color(0xFFEF4444), Color(0xFFB91C1C)],
      headline: 'One tap.\nEmergency response in seconds.',
      subtitle:
          'Instant SOS triggers alerts to Police, emergency contacts, and your guardians — even offline via SMS.',
      tag: 'SOS SYSTEM',
    ),
    _SlideData(
      gradientColors: [Color(0xFF0A1A2E), Color(0xFF102045)],
      accentColor: Color(0xFF7C3AED),
      icon: Icons.lock_rounded,
      iconBg: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
      headline: 'Report cybercrimes\nwith evidence that sticks.',
      subtitle:
          'AES-256 encrypted evidence vault with blockchain hash verification — your proof, secured forever.',
      tag: 'EVIDENCE VAULT',
    ),
    _SlideData(
      gradientColors: [Color(0xFF0A2E1A), Color(0xFF103028)],
      accentColor: Color(0xFF00E5A0),
      icon: Icons.shield_rounded,
      iconBg: [Color(0xFF00E5A0), Color(0xFF00B87A)],
      headline: 'AI-powered protection\nbefore threats reach you.',
      subtitle:
          'Phishing link checker, deepfake detector, fake profile scanner — your 24/7 digital guardian.',
      tag: 'AI PROTECTION',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrls = List.generate(
      _slides.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      ),
    );
    _iconScales = _iconCtrls
        .map((c) => Tween<double>(begin: 0.4, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.elasticOut)))
        .toList();
    _iconFades = _iconCtrls
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeIn)))
        .toList();

    // Animate first slide immediately
    _iconCtrls[0].forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _iconCtrls) c.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.gradientColors,
          ),
        ),
        child: Stack(
          children: [
            // Decorative ambient orbs
            Positioned(
              top: -80,
              left: -80,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.accentColor.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.accentColor.withOpacity(0.05),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar: Skip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tag chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: slide.accentColor.withOpacity(0.35)),
                          ),
                          child: Text(
                            slide.tag,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: slide.accentColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _slides.length,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                        _iconCtrls[i].reset();
                        _iconCtrls[i].forward();
                      },
                      itemBuilder: (context, index) {
                        final s = _slides[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated icon
                              ScaleTransition(
                                scale: _iconScales[index],
                                child: FadeTransition(
                                  opacity: _iconFades[index],
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(colors: [
                                            s.accentColor.withOpacity(0.15),
                                            Colors.transparent,
                                          ]),
                                        ),
                                      ),
                                      Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: s.iconBg,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: s.accentColor.withOpacity(0.4),
                                              blurRadius: 40,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(s.icon,
                                            size: 60, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 44),
                              Text(
                                s.headline,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.subtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom: dots + next button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                    child: Column(
                      children: [
                        // Progress dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (i) {
                            final isActive = i == _currentPage;
                            final dot = _slides[i];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? dot.accentColor
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _nextPage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: slide.iconBg,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: slide.accentColor.withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentPage == _slides.length - 1
                                    ? 'Get Started 🚀'
                                    : 'Next →',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;
  final List<Color> iconBg;
  final String headline;
  final String subtitle;
  final String tag;

  const _SlideData({
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
    required this.iconBg,
    required this.headline,
    required this.subtitle,
    required this.tag,
  });
}
