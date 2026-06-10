import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class AiToolsHomePage extends StatelessWidget {
  const AiToolsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 4),
                _buildHeroBanner(),
                const SizedBox(height: 24),
                _buildSectionLabel('Detection Tools'),
                const SizedBox(height: 12),
                _ToolCard(
                  gradient: [const Color(0xFF7C3AED), const Color(0xFF5B21B6)],
                  icon: Icons.travel_explore,
                  title: 'Phishing Checker',
                  subtitle: 'Check if a link or message is phishing or safe',
                  actionLabel: 'Check Now',
                  route: '/phishing',
                ),
                const SizedBox(height: 12),
                _ToolCard(
                  gradient: [const Color(0xFFEC4899), const Color(0xFFBE185D)],
                  icon: Icons.person_search_outlined,
                  title: 'Fake Profile Detector',
                  subtitle: 'Detect fake or suspicious social media profiles',
                  actionLabel: 'Check Now',
                  route: '/fake-profile',
                ),
                const SizedBox(height: 12),
                _ToolCard(
                  gradient: [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
                  icon: Icons.face_retouching_off,
                  title: 'Deepfake Detector',
                  subtitle: 'Analyze images and videos for deepfake manipulation',
                  actionLabel: 'Analyze Now',
                  route: '/deepfake',
                ),
                const SizedBox(height: 24),
                _buildSectionLabel('Scanning Tools'),
                const SizedBox(height: 12),
                _ToolCard(
                  gradient: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                  icon: Icons.manage_search,
                  title: 'Social Media Safety Scan',
                  subtitle: 'Scan your social media profile for suspicious activity',
                  actionLabel: 'Scan Now',
                  route: '/social-scanner',
                ),
                const SizedBox(height: 24),
                _buildSectionLabel('Search Tools'),
                const SizedBox(height: 12),
                _ToolCard(
                  gradient: [const Color(0xFF22C55E), const Color(0xFF15803D)],
                  icon: Icons.image_search,
                  title: 'Missing Person Assist',
                  subtitle: 'Upload a photo to search for potential matches',
                  actionLabel: 'Search Now',
                  route: '/missing-person',
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('AI Safety Tools',
                      style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Powered by CyberShield AI',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('AI Online', style: GoogleFonts.outfit(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stay Protected',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Our AI tools detect online threats in real-time, keeping you safe from cyber attacks.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  }
}

class _ToolCard extends StatelessWidget {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String route;

  const _ToolCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 10)],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel,
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
