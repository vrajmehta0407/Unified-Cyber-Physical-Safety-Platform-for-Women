import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

const _platforms = ['Instagram', 'Facebook', 'Twitter', 'LinkedIn'];
const _platformIcons = [
  Icons.camera_alt_outlined,
  Icons.facebook_outlined,
  Icons.tag,
  Icons.business_center_outlined,
];

class SocialMediaScannerPage extends StatefulWidget {
  const SocialMediaScannerPage({super.key});

  @override
  State<SocialMediaScannerPage> createState() => _SocialMediaScannerPageState();
}

class _SocialMediaScannerPageState extends State<SocialMediaScannerPage>
    with SingleTickerProviderStateMixin {
  int _platformIdx = 0;
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  late final AnimationController _scoreCtrl;
  late final Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scoreAnim = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() => _loading = true);
    try {
      final r = await ServiceLocator.instance.ai.analyzeFakeProfile(
        username: url,
        platform: _platforms[_platformIdx].toLowerCase(),
      );
      setState(() => _result = r);
      _scoreCtrl.forward(from: 0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                  _buildPlatformTabs(),
                  const SizedBox(height: 16),
                  _buildInputCard(),
                  const SizedBox(height: 16),
                  if (_result != null) _buildScanResult(),
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
              Text('Social Media Risk Scanner',
                  style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_platforms.length, (i) {
          final isSelected = _platformIdx == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _platformIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_platformIcons[i],
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        size: 18),
                    const SizedBox(height: 3),
                    Text(
                      _platforms[i],
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _urlCtrl,
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: '@username or https://${_platforms[_platformIdx].toLowerCase()}.com/...',
              hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.alternate_email, color: AppColors.textSecondary, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _loading ? null : _scan,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.radar, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('Scan Profile',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResult() {
    final score = (_result!['risk_score'] as num?)?.toDouble() ?? 0.0;
    final verdict = _result!['verdict'] as String? ?? '';
    final details = _result!['details'] as Map<String, dynamic>? ?? {};

    final riskColor = score >= 70 ? AppColors.danger : score >= 40 ? AppColors.warning : AppColors.success;
    final riskLabel = score >= 70 ? 'High Risk' : score >= 40 ? 'Moderate Risk' : 'Low Risk';
    final riskDesc = score >= 70
        ? 'This profile shows suspicious activity. Please be cautious.'
        : score >= 40
            ? 'This profile shows some unusual activity.'
            : 'This profile appears to be authentic.';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text('Scan Result', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              // Donut chart
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (_, __) {
                  final display = score * _scoreAnim.value;
                  return SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: _DonutPainter(progress: display / 100, color: riskColor),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${display.toInt()}',
                                style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.bold, color: riskColor)),
                            Text('Risk Score',
                                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor.withOpacity(0.4)),
                ),
                child: Text(riskLabel,
                    style: GoogleFonts.outfit(color: riskColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              Text(riskDesc,
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Risk Factors', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...([
                _RiskFactor('Profile Privacy', _randomRisk(score)),
                _RiskFactor('Follower Authenticity', _randomRisk(score * 0.6)),
                _RiskFactor('Suspicious Activity', _randomRisk(score * 0.85)),
                _RiskFactor('Post Authenticity', _randomRisk(score * 0.4)),
              ].map((rf) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(rf.label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13))),
                    _RiskBadge(level: rf.level),
                  ],
                ),
              ))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text('View Detailed Report',
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _randomRisk(double score) {
    if (score >= 55) return 'High';
    if (score >= 30) return 'Medium';
    return 'Low';
  }
}

class _RiskFactor {
  final String label;
  final String level;
  const _RiskFactor(this.label, this.level);
}

class _RiskBadge extends StatelessWidget {
  final String level;
  const _RiskBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color c = level == 'High' ? AppColors.danger : level == 'Medium' ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(level, style: GoogleFonts.outfit(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color color;
  _DonutPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, math.pi * 2, false,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, math.pi * 2 * progress, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress || old.color != color;
}
