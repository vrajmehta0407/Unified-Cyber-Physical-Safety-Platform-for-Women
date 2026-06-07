import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/cs_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _SosBanner(),
                const SizedBox(height: 28),
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 14),
                _QuickActionsGrid(),
                const SizedBox(height: 28),
                const SectionHeader(title: 'AI Safety Tools'),
                const SizedBox(height: 14),
                _AiToolsList(),
                const SizedBox(height: 28),
                const SectionHeader(title: 'Advanced Safety'),
                const SizedBox(height: 14),
                _AdvancedSafetyGrid(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name = state is AuthAuthenticated ? state.user.name.split(' ').first : 'Guest';
            return Row(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(name[0].toUpperCase(),
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Hello, $name 👋',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Stay Safe, Stay Strong',
                        style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                // Notification bell
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.notifications_outlined, size: 20, color: AppColors.textPrimary)),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Logout button
                GestureDetector(
                  onTap: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(child: Icon(Icons.logout, size: 18, color: AppColors.textSecondary)),
                  ),
                ),
              ],
            );
          },
        ),
        background: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
        ),
      ),
    );
  }
}

class _SosBanner extends StatefulWidget {
  @override
  State<_SosBanner> createState() => _SosBannerState();
}

class _SosBannerState extends State<_SosBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
              colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.danger.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              // SOS badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text('SOS',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SOS Emergency Alert',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Slide to send SOS',
                        style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionDef(Icons.report_problem_outlined, 'Report Cyber Crime', 'Report Now', '/report',
          [const Color(0xFF7C3AED), const Color(0xFF5B21B6)]),
      _ActionDef(Icons.upload_file_outlined, 'Upload Evidence', 'Upload Now', '/evidence',
          [const Color(0xFFEC4899), const Color(0xFFBE185D)]),
      _ActionDef(Icons.location_on_outlined, 'Live Tracking', 'View Location', '/tracking',
          [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]),
      _ActionDef(Icons.lightbulb_outlined, 'Safety Tips', 'Learn More', '/awareness',
          [const Color(0xFFEAB308), const Color(0xFFCA8A04)]),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: actions.map((a) => ActionIconCard(
        icon: a.icon,
        label: a.label,
        subtitle: a.subtitle,
        onTap: () => context.push(a.route),
        gradient: a.gradient,
      )).toList(),
    );
  }
}

class _AiToolsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolDef(Icons.link, 'Phishing Checker', 'Check if a link is safe', '/phishing'),
      _ToolDef(Icons.person_search, 'Fake Profile Detector', 'Detect fake social profiles', '/fake-profile'),
      _ToolDef(Icons.face_retouching_off, 'Deepfake Detector', 'Analyze image/video for deepfakes', '/deepfake'),
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

class _AdvancedSafetyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionDef(Icons.map_outlined, 'Unsafe Zones', 'View Map', '/unsafe-zones',
          [const Color(0xFFEF4444), const Color(0xFFB91C1C)]),
      _ActionDef(Icons.verified_outlined, 'Blockchain Verify', 'Verify Evidence', '/blockchain',
          [const Color(0xFF22C55E), const Color(0xFF15803D)]),
      _ActionDef(Icons.people_outlined, 'Community', 'Connect', '/community',
          [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]),
      _ActionDef(Icons.sms_outlined, 'Offline SOS', 'SMS Alert', '/offline-sos',
          [const Color(0xFFF97316), const Color(0xFFEA580C)]),
      _ActionDef(Icons.watch_outlined, 'Wearables', 'Connect Device', '/devices',
          [const Color(0xFF06B6D4), const Color(0xFF0891B2)]),
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
      children: items.map((a) => ActionIconCard(
        icon: a.icon,
        label: a.label,
        subtitle: a.subtitle,
        onTap: () => context.push(a.route),
        gradient: a.gradient,
      )).toList(),
    );
  }
}

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
