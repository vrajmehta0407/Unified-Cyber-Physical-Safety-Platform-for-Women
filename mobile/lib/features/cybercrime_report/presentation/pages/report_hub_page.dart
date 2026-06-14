import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/cs_widgets.dart';

class ReportHubPage extends StatefulWidget {
  const ReportHubPage({super.key});

  @override
  State<ReportHubPage> createState() => _ReportHubPageState();
}

class _ReportHubPageState extends State<ReportHubPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static final _categories = [
    _CrimeCategory(
      emoji: '🔍',
      name: 'Cyberstalking',
      subtitle: 'Track & monitor online',
      code: 'cyberstalking',
      gradient: [const Color(0xFF7C3AED), const Color(0xFF5B21B6)],
      nearbyCases: 14,
    ),
    _CrimeCategory(
      emoji: '😤',
      name: 'Online Harassment',
      subtitle: 'Threats & abuse',
      code: 'online_harassment',
      gradient: [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
      nearbyCases: 28,
    ),
    _CrimeCategory(
      emoji: '👤',
      name: 'Fake Profile',
      subtitle: 'Impersonation',
      code: 'fake_profile',
      gradient: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      nearbyCases: 9,
    ),
    _CrimeCategory(
      emoji: '🔐',
      name: 'Identity Theft',
      subtitle: 'Personal data stolen',
      code: 'identity_theft',
      gradient: [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      nearbyCases: 6,
    ),
    _CrimeCategory(
      emoji: '💸',
      name: 'Financial Fraud',
      subtitle: 'Online scams',
      code: 'financial_fraud',
      gradient: [const Color(0xFFEAB308), const Color(0xFFCA8A04)],
      nearbyCases: 42,
    ),
    _CrimeCategory(
      emoji: '🎭',
      name: 'Blackmail/Sextortion',
      subtitle: 'Image-based abuse',
      code: 'blackmail_sextortion',
      gradient: [const Color(0xFFDC2626), const Color(0xFF991B1B)],
      nearbyCases: 7,
    ),
    _CrimeCategory(
      emoji: '🤖',
      name: 'Deepfake Abuse',
      subtitle: 'AI-manipulated content',
      code: 'deepfake_abuse',
      gradient: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      nearbyCases: 3,
    ),
    _CrimeCategory(
      emoji: '🎣',
      name: 'Phishing Attack',
      subtitle: 'Fake links & emails',
      code: 'phishing',
      gradient: [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      nearbyCases: 21,
    ),
    _CrimeCategory(
      emoji: '📱',
      name: 'SIM Swap Fraud',
      subtitle: 'Mobile hijacking',
      code: 'sim_swap',
      gradient: [const Color(0xFFF97316), const Color(0xFFEA580C)],
      nearbyCases: 5,
    ),
    _CrimeCategory(
      emoji: '💌',
      name: 'Morphed Images',
      subtitle: 'Photo manipulation',
      code: 'morphed_images',
      gradient: [const Color(0xFFD946EF), const Color(0xFFA21CAF)],
      nearbyCases: 11,
    ),
    _CrimeCategory(
      emoji: '📞',
      name: 'Vishing/Call Fraud',
      subtitle: 'Fake voice calls',
      code: 'vishing',
      gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
      nearbyCases: 18,
    ),
    _CrimeCategory(
      emoji: '🌐',
      name: 'Social Media Hacking',
      subtitle: 'Account takeover',
      code: 'social_hacking',
      gradient: [const Color(0xFFEF4444), const Color(0xFF7C3AED)],
      nearbyCases: 33,
    ),
  ];

  List<_CrimeCategory> get _filtered {
    if (_searchQuery.isEmpty) return _categories;
    final q = _searchQuery.toLowerCase();
    return _categories
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: csAppBar(
        title: 'Report Cybercrime',
        context: context,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.filter_list, size: 18, color: AppColors.textPrimary),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: _SosFab(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search crime category...',
                        hintStyle: GoogleFonts.inter(
                            color: AppColors.textHint, fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.info, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select crime type — your report will be sent to Ahmedabad Cyber Crime Cell.',
                            style: GoogleFonts.inter(
                                color: AppColors.info.withOpacity(0.9), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${filtered.length} categories',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        'Nearby cases shown',
                        style: GoogleFonts.inter(
                            color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _CrimeTile(
                  category: filtered[i],
                  onTap: () => context.push('/report',
                      extra: {'category': filtered[i].code}),
                ),
                childCount: filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrimeTile extends StatefulWidget {
  final _CrimeCategory category;
  final VoidCallback onTap;
  const _CrimeTile({required this.category, required this.onTap});

  @override
  State<_CrimeTile> createState() => _CrimeTileState();
}

class _CrimeTileState extends State<_CrimeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2A1F4A),
                const Color(0xFF1A1230),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Gradient accent strip at top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: cat.gradient),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Emoji in gradient container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: cat.gradient
                                .map((c) => c.withOpacity(0.2))
                                .toList(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: cat.gradient[0].withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(cat.emoji,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cat.name,
                        maxLines: 2,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat.subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      // Nearby cases badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cat.gradient[0].withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: cat.gradient[0].withOpacity(0.35)),
                        ),
                        child: Text(
                          '${cat.nearbyCases} nearby',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: cat.gradient[0],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cat.gradient[0].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.arrow_forward_ios,
                        size: 10, color: cat.gradient[0]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SosFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/sos'),
      backgroundColor: AppColors.danger,
      icon: const Icon(Icons.emergency_rounded, color: Colors.white),
      label: Text(
        'SOS',
        style: GoogleFonts.spaceGrotesk(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class _CrimeCategory {
  final String emoji;
  final String name;
  final String subtitle;
  final String code;
  final List<Color> gradient;
  final int nearbyCases;
  const _CrimeCategory({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.code,
    required this.gradient,
    required this.nearbyCases,
  });
}
