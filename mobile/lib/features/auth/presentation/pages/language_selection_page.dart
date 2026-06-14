import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with TickerProviderStateMixin {
  String _selectedLang = 'en';
  bool _saving = false;

  late final AnimationController _shieldCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _shieldScale;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  static const _storage = FlutterSecureStorage();

  final _languages = [
    _LangOption(
      code: 'en',
      flag: '🇮🇳',
      name: 'English',
      nativeScript: 'English — India',
      subtitle: 'Continue in English',
    ),
    _LangOption(
      code: 'hi',
      flag: '🇮🇳',
      name: 'हिंदी',
      nativeScript: 'देवनागरी लिपि',
      subtitle: 'हिंदी में जारी रखें',
    ),
    _LangOption(
      code: 'gu',
      flag: '🇮🇳',
      name: 'ગુજરાતી',
      nativeScript: 'ગુજરાતી લિપિ',
      subtitle: 'ગુજરાતીમાં ચાલુ રાખો',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shieldCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _shieldScale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _shieldCtrl, curve: Curves.elasticOut));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

    _shieldCtrl.forward().then((_) => _fadeCtrl.forward());
  }

  @override
  void dispose() {
    _shieldCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_saving) return;
    setState(() => _saving = true);
    await _storage.write(key: 'language_set', value: _selectedLang);
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            // Decorative ambient circles
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.05),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Shield logo
                    ScaleTransition(
                      scale: _shieldScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                AppColors.primary.withOpacity(0.18),
                                Colors.transparent,
                              ]),
                            ),
                          ),
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.45),
                                    blurRadius: 28,
                                    spreadRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.security, size: 44, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title block
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
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose Your Language',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'अपनी भाषा चुनें  •  તમારી ભાષા પસંદ કરો',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Language cards
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Column(
                        children: _languages.map((lang) => _buildLangCard(lang)).toList(),
                      ),
                    ),
                    const Spacer(),
                    // Continue button
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: GestureDetector(
                          onTap: _onContinue,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Center(
                              child: _saving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5)
                                  : Text(
                                      'Continue →',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangCard(_LangOption lang) {
    final isSelected = _selectedLang == lang.code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLang = lang.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    const Color(0xFF00E5A0).withOpacity(0.12),
                    AppColors.card.withOpacity(0.9),
                  ]
                : [
                    const Color(0xFF2A1F4A),
                    const Color(0xFF1A1230),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5A0)
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5A0).withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Flag + language circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF00E5A0).withOpacity(0.15)
                    : AppColors.cardAlt,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00E5A0).withOpacity(0.5)
                      : AppColors.borderLight,
                ),
              ),
              child: Center(
                child: Text(lang.flag, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF00E5A0)
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.nativeScript,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF00E5A0)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00E5A0)
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String flag;
  final String name;
  final String nativeScript;
  final String subtitle;
  const _LangOption({
    required this.code,
    required this.flag,
    required this.name,
    required this.nativeScript,
    required this.subtitle,
  });
}
