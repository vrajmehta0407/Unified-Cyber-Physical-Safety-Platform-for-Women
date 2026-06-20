import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/cs_widgets.dart';
import '../widgets/sos_shell_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SosShellWrapper(
      showFab: true,
      enableShake: true,
      child: Scaffold(
        backgroundColor: t.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeroAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _SafetyScoreCard(),
                  const SizedBox(height: 16),
                  _PremiumSosBanner(),
                  const SizedBox(height: 24),
                  _LiveStatsRow(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'Quick Actions', icon: Icons.flash_on_rounded),
                  const SizedBox(height: 14),
                  _QuickActionsGrid(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'AI Safety Tools', icon: Icons.auto_awesome_rounded),
                  const SizedBox(height: 14),
                  _AiToolsList(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'Advanced Safety', icon: Icons.shield_rounded),
                  const SizedBox(height: 14),
                  _AdvancedSafetyGrid(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'Feature Catalog', icon: Icons.apps_rounded),
                  const SizedBox(height: 14),
                  _FeatureCatalogList(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    ));
  }

  Widget _buildHeroAppBar(BuildContext context) {
    final t = Theme.of(context);
    final isLight = t.brightness == Brightness.light;
    return SliverAppBar(
      backgroundColor: t.scaffoldBackgroundColor,
      elevation: 0,
      pinned: true,
      expandedHeight: 140,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name = state is AuthAuthenticated
                ? state.user.name.split(' ').first
                : 'Guest';
            return Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(name[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Hello, $name',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary)),
                      Text('Stay Safe, Stay Strong',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
                _AppBarAction(
                  icon: Icons.notifications_outlined,
                  onTap: () {},
                  badge: true,
                  isLight: isLight,
                ),
                const SizedBox(width: 8),
                _AppBarAction(
                  icon: Icons.logout_rounded,
                  onTap: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  isLight: isLight,
                ),
              ],
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isLight
                  ? [AppColors.primaryLight.withOpacity(0.08), Colors.transparent]
                  : [AppColors.primary.withOpacity(0.12), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  final bool isLight;
  const _AppBarAction({required this.icon, required this.onTap, this.badge = false, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isLight ? 0.04 : 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(icon, size: 20,
                  color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary),
            ),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  SECTION TITLE
// ════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradientShort),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.bold, color: t.textTheme.headlineSmall?.color)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════
//  PREMIUM SOS BANNER
// ════════════════════════════════════════════════════
class _PremiumSosBanner extends StatefulWidget {
  @override
  State<_PremiumSosBanner> createState() => _PremiumSosBannerState();
}

class _PremiumSosBannerState extends State<_PremiumSosBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/sos'),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Center(
                  child: Icon(Icons.emergency_outlined, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SOS Emergency',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 3),
                    Text('Tap to send instant alert',
                        style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13)),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  LIVE STATS ROW
// ════════════════════════════════════════════════════
class _LiveStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isLight = t.brightness == Brightness.light;
    final stats = [
      _StatDef(Icons.shield_outlined, '85', 'Safety Score', AppColors.success),
      _StatDef(Icons.person_outline, '3', 'Guardians', AppColors.accentSky),
      _StatDef(Icons.assignment_outlined, '2', 'Reports', AppColors.primary),
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightCard : AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
              boxShadow: [
                BoxShadow(
                  color: s.color.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(s.icon, size: 22, color: s.color),
                const SizedBox(height: 6),
                Text(s.value,
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: t.textTheme.headlineMedium?.color)),
                Text(s.label,
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatDef {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatDef(this.icon, this.value, this.label, this.color);
}

// ════════════════════════════════════════════════════
//  QUICK ACTIONS GRID
// ════════════════════════════════════════════════════
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionDef(Icons.report_problem_outlined, 'Report Crime', 'File Report',
          '/report-hub', [const Color(0xFF7C3AED), const Color(0xFF5B21B6)]),
      _ActionDef(Icons.lock_outline, 'Evidence Vault', 'Secure Files',
          '/evidence', [const Color(0xFFEC4899), const Color(0xFFBE185D)]),
      _ActionDef(Icons.shield_outlined, 'AI Threat Scan', 'Scan Now',
          '/ai-tools', [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]),
      _ActionDef(Icons.map_outlined, 'Safe Route', 'Plan Route',
          '/safety-map', [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]),
      _ActionDef(Icons.person_search_outlined, 'Fake Profile', 'Verify Now',
          '/fake-profile', [const Color(0xFF06B6D4), const Color(0xFF0891B2)]),
      _ActionDef(Icons.lightbulb_outlined, 'Safety Tips', 'Learn More',
          '/awareness', [const Color(0xFFF59E0B), const Color(0xFFD97706)]),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: actions
          .map((a) => _PremiumActionCard(
                icon: a.icon,
                label: a.label,
                subtitle: a.subtitle,
                onTap: () => context.push(a.route),
                gradient: a.gradient,
              ))
          .toList(),
    );
  }
}

class _PremiumActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final List<Color> gradient;
  const _PremiumActionCard({
    required this.icon, required this.label, required this.subtitle,
    required this.onTap, required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isLight = t.brightness == Brightness.light;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightCard : AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.textTheme.titleMedium?.color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  AI TOOLS LIST
// ════════════════════════════════════════════════════
class _AiToolsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolDef(Icons.link, 'Phishing Checker', 'Check if a link is safe', '/phishing'),
      _ToolDef(Icons.person_search, 'Fake Profile Detector', 'Detect fake social profiles', '/fake-profile'),
      _ToolDef(Icons.face_retouching_off, 'Deepfake Detector', 'Analyze image for deepfakes', '/deepfake'),
      _ToolDef(Icons.camera_alt_outlined, 'Social Media Scanner', 'Scan your social profile', '/social-scanner'),
    ];
    return Column(
      children: tools.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ActionListTile(
          icon: t.icon,
          label: t.label,
          subtitle: t.subtitle,
          onTap: () => context.push(t.route),
          gradient: [AppColors.primary, AppColors.primaryDark],
        ),
      )).toList(),
    );
  }
}

// ════════════════════════════════════════════════════
//  ADVANCED SAFETY GRID
// ════════════════════════════════════════════════════
class _AdvancedSafetyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionDef(Icons.map_outlined, 'Unsafe Zones', 'View Map',
          '/unsafe-zones', [const Color(0xFFEF4444), const Color(0xFFB91C1C)]),
      _ActionDef(Icons.verified_outlined, 'Blockchain', 'Verify Evidence',
          '/blockchain', [const Color(0xFF22C55E), const Color(0xFF15803D)]),
      _ActionDef(Icons.people_outlined, 'Community', 'Connect', '/community',
          [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]),
      _ActionDef(Icons.sms_outlined, 'Offline SOS', 'SMS Alert', '/offline-sos',
          [const Color(0xFFF97316), const Color(0xFFEA580C)]),
      _ActionDef(Icons.watch_outlined, 'Wearables', 'Connect Device',
          '/devices', [const Color(0xFF06B6D4), const Color(0xFF0891B2)]),
      _ActionDef(Icons.contacts_outlined, 'Guardians', 'Manage', '/guardians',
          [const Color(0xFFEC4899), const Color(0xFFBE185D)]),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items
          .map((a) => _PremiumActionCard(
                icon: a.icon,
                label: a.label,
                subtitle: a.subtitle,
                onTap: () => context.push(a.route),
                gradient: a.gradient,
              ))
          .toList(),
    );
  }
}

// ════════════════════════════════════════════════════
//  FEATURE CATALOG
// ════════════════════════════════════════════════════
class _FeatureCatalogList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      _FeatureInfo(Icons.emergency, 'SOS Emergency',
          'Panic button, voice trigger, silent mode', '/sos', AppColors.danger),
      _FeatureInfo(Icons.sms_outlined, 'Offline SMS SOS',
          'GPS coordinates via SMS without internet', '/offline-sos', AppColors.warning),
      _FeatureInfo(Icons.share_location, 'Live GPS Tracking',
          'Real-time location with share', '/tracking', AppColors.info),
      _FeatureInfo(Icons.assignment_outlined, 'Cybercrime Report',
          '8 categories: stalking, harassment, fraud', '/report', AppColors.primary),
      _FeatureInfo(Icons.lock_outline, 'Evidence Vault',
          'AES-256 encrypted upload plus SHA-256 hash', '/evidence', AppColors.secondary),
      _FeatureInfo(Icons.verified_outlined, 'Blockchain Verify',
          'Hash-based evidence verification', '/blockchain', AppColors.success),
      _FeatureInfo(Icons.travel_explore, 'Phishing Checker',
          'AI URL and SMS risk analysis', '/phishing', AppColors.info),
      _FeatureInfo(Icons.person_search, 'Fake Profile Detector',
          'Social media profile analysis', '/fake-profile', AppColors.primaryLight),
      _FeatureInfo(Icons.face_retouching_off, 'Deepfake Detector',
          'Image/video authenticity check', '/deepfake', AppColors.warning),
      _FeatureInfo(Icons.camera_alt_outlined, 'Social Media Scanner',
          'Multi-platform profile risk scan', '/social-scanner', AppColors.secondary),
      _FeatureInfo(Icons.contacts_outlined, 'Guardian Management',
          'Emergency contacts with auto-notify on SOS', '/guardians', AppColors.primary),
      _FeatureInfo(Icons.volunteer_activism, 'Community Safety',
          'Volunteer network plus safety check-in', '/community', AppColors.success),
      _FeatureInfo(Icons.watch_outlined, 'Wearable Devices',
          'Smartwatch SOS integration', '/devices', AppColors.info),
      _FeatureInfo(Icons.map_outlined, 'Unsafe Zone Map',
          'AI-predicted high-risk areas', '/unsafe-zones', AppColors.danger),
      _FeatureInfo(Icons.menu_book_outlined, 'Safety Awareness',
          'Articles in English, Hindi, Gujarati', '/awareness', AppColors.warning),
      _FeatureInfo(Icons.verified_user_outlined, 'Auth + OTP',
          'JWT login with mobile-based OTP', '/settings', AppColors.primaryDark),
    ];
    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ActionListTile(
            icon: f.icon,
            label: f.title,
            subtitle: f.description,
            onTap: () => context.push(f.route),
            gradient: [f.color, f.color.withOpacity(0.72)],
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════
//  SAFETY SCORE CARD (Premium)
// ════════════════════════════════════════════════════
class _SafetyScoreCard extends StatefulWidget {
  @override
  State<_SafetyScoreCard> createState() => _SafetyScoreCardState();
}

class _SafetyScoreCardState extends State<_SafetyScoreCard> with SingleTickerProviderStateMixin {
  late final AnimationController _scoreCtrl;
  late final Animation<double> _scoreAnim;
  bool _loading = true;
  bool guardiansSet = false;
  bool locationShared = false;
  bool accountVerified = false;
  bool aiScanDone = false;
  bool reportsFiled = false;

  int get score {
    int s = 0;
    if (guardiansSet) s += 20;
    if (locationShared) s += 20;
    if (accountVerified) s += 25;
    if (aiScanDone) s += 20;
    if (reportsFiled) s += 15;
    return s;
  }

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fetchSafetyData();
  }

  Future<void> _fetchSafetyData() async {
    final locator = ServiceLocator.instance;
    try {
      final guardians = await locator.guardians.listGuardians();
      guardiansSet = guardians.length >= 2;
    } catch (_) {}
    try {
      await locator.location.getCurrentPosition();
      locationShared = true;
    } catch (_) {}
    try {
      accountVerified = true;
    } catch (_) {}
    try {
      final reports = await locator.reports.listReports();
      reportsFiled = reports.isNotEmpty;
    } catch (_) {}
    final finalScore = score;
    _scoreAnim = Tween<double>(begin: 0, end: finalScore.toDouble()).animate(
      CurvedAnimation(parent: _scoreCtrl, curve: Curves.fastOutSlowIn),
    );
    _scoreCtrl.forward();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isLight = t.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightCard : AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: AnimatedBuilder(
              animation: _scoreAnim,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: 1.0,
                            backgroundColor: isLight
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                            color: Colors.transparent,
                            strokeWidth: 7,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _scoreAnim.value / 100.0,
                        backgroundColor: Colors.transparent,
                        color: _scoreAnim.value > 75
                            ? AppColors.success
                            : (_scoreAnim.value > 45 ? AppColors.warning : AppColors.danger),
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_scoreAnim.value.toInt()}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: t.textTheme.headlineMedium?.color,
                          ),
                        ),
                        Text('/100',
                            style: GoogleFonts.outfit(
                                fontSize: 9,
                                color: isLight ? AppColors.lightTextHint : AppColors.darkTextHint)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety Score',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: t.textTheme.titleLarge?.color)),
                const SizedBox(height: 2),
                Text('Complete all actions to maximize',
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FactorChip(label: 'Guardians', active: guardiansSet, isLight: isLight),
                      const SizedBox(width: 6),
                      _FactorChip(label: 'GPS', active: locationShared, isLight: isLight),
                      const SizedBox(width: 6),
                      _FactorChip(label: 'Verified', active: accountVerified, isLight: isLight),
                      const SizedBox(width: 6),
                      _FactorChip(label: 'Scan', active: aiScanDone, isLight: isLight, isWarn: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool isLight;
  final bool isWarn;
  const _FactorChip({
    required this.label, required this.active, required this.isLight, this.isWarn = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = active
        ? AppColors.success.withOpacity(0.12)
        : (isWarn ? AppColors.warning.withOpacity(0.12) : (isLight ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt));
    final borderColor = active
        ? AppColors.success.withOpacity(0.35)
        : (isWarn ? AppColors.warning.withOpacity(0.35) : (isLight ? AppColors.lightBorder : AppColors.darkBorder));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : (isWarn ? Icons.warning_amber : Icons.circle_outlined),
            size: 10,
            color: active ? AppColors.success : (isWarn ? AppColors.warning : (isLight ? AppColors.lightTextHint : AppColors.darkTextHint)),
          ),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? AppColors.success
                      : (isWarn ? AppColors.warning : (isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary)))),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  DATA CLASSES
// ════════════════════════════════════════════════════
class _ActionDef {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final List<Color> gradient;
  const _ActionDef(this.icon, this.label, this.subtitle, this.route, this.gradient);
}

class _ToolDef {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  const _ToolDef(this.icon, this.label, this.subtitle, this.route);
}

class _FeatureInfo {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color color;
  const _FeatureInfo(this.icon, this.title, this.description, this.route, this.color);
}
