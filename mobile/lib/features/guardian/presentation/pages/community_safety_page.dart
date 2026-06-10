import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

const _volunteers = [
  _Volunteer('Riya Patel', '1.2 km away', 4.9, true),
  _Volunteer('Mehul Sharma', '2.4 km away', 4.8, true),
  _Volunteer('Neha Trivedi', '3.1 km away', 4.7, false),
];

class _Volunteer {
  final String name;
  final String distance;
  final double rating;
  final bool available;
  const _Volunteer(this.name, this.distance, this.rating, this.available);
}

class CommunitySafetyPage extends StatelessWidget {
  const CommunitySafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeroBanner(),
                  const SizedBox(height: 24),
                  _buildSectionRow('Nearby Verified Volunteers', 'View All', context),
                  const SizedBox(height: 12),
                  ..._volunteers.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _VolunteerCard(volunteer: v),
                      )),
                  const SizedBox(height: 24),
                  _buildSafetyCheckIn(context),
                  const SizedBox(height: 24),
                  _buildActionGrid(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 14),
              Text('Safety Community',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are not alone!',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Connect with verified volunteers and community helpers near you.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionRow(String title, String action, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: () {},
          child: Text(action, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildSafetyCheckIn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Safety Check-In',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                    Text('Let others know you are safe',
                        style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Check-in sent to your guardians!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.success, AppColors.successDark]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('Check-in Now',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(Icons.local_police_outlined, 'Emergency\nAssistance', AppColors.danger),
      _ActionItem(Icons.check_circle_outline, 'Safety\nCheck-in', AppColors.success),
      _ActionItem(Icons.report_outlined, 'Report\nIncident', AppColors.warning),
      _ActionItem(Icons.campaign_outlined, 'Community\nAlerts', AppColors.info),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: actions.map((a) => GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(a.icon, color: a.color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(a.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionItem(this.icon, this.label, this.color);
}

class _VolunteerCard extends StatelessWidget {
  final _Volunteer volunteer;
  const _VolunteerCard({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                volunteer.name[0],
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(volunteer.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 12),
                    const SizedBox(width: 3),
                    Text('${volunteer.rating}', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(volunteer.distance, style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: volunteer.available ? AppColors.success.withOpacity(0.12) : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: volunteer.available ? AppColors.success.withOpacity(0.4) : AppColors.border,
              ),
            ),
            child: Text(
              volunteer.available ? 'Available' : 'Busy',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: volunteer.available ? AppColors.success : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
