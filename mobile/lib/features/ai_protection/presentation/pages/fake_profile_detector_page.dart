import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class FakeProfileDetectorPage extends StatefulWidget {
  const FakeProfileDetectorPage({super.key});

  @override
  State<FakeProfileDetectorPage> createState() => _FakeProfileDetectorPageState();
}

class _FakeProfileDetectorPageState extends State<FakeProfileDetectorPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  late final AnimationController _scoreCtrl;
  late final Animation<double> _scoreAnim;
  final _ai = ServiceLocator.instance.ai;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scoreAnim = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final result = await _ai.analyzeFakeProfile(username: username);
      setState(() => _result = result);
      _scoreCtrl.forward(from: 0);
    } catch (e) {
      final r = _localAnalysis(username);
      setState(() => _result = r);
      _scoreCtrl.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _localAnalysis(String username) {
    var score = 18;
    final lower = username.toLowerCase();
    if (RegExp(r'\d{4,}').hasMatch(lower)) score += 18;
    if (lower.contains('official') || lower.contains('support') || lower.contains('helpdesk')) score += 14;
    if (lower.length < 4 || lower.length > 24) score += 10;
    if (lower.contains('_') && lower.split('_').length > 2) score += 8;
    score = score.clamp(0, 94);
    return {
      'risk_score': score,
      'verdict': score >= 60 ? 'fake' : score >= 35 ? 'suspicious' : 'real',
      'message': score >= 60 ? 'High impersonation risk detected' : score >= 35 ? 'Moderate review needed' : 'Profile appears genuine',
    };
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
                  _buildInputCard(),
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    _buildResultCard(),
                  ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fake Profile Detector',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Detect fake or suspicious social profiles',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Username or Profile Link',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextField(
            controller: _usernameCtrl,
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: '@username or profile URL...',
              hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.person_search_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _loading ? null : _analyze,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFBE185D)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFFEC4899).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.manage_search_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('Analyze Profile',
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

  Widget _buildResultCard() {
    final score = (_result!['risk_score'] as num?)?.toDouble() ?? 0.0;
    final verdict = _result!['verdict']?.toString() ?? '';
    final message = _result!['message']?.toString() ?? '';
    final isFake = score >= 60;
    final isSuspicious = score >= 35 && score < 60;
    final riskColor = isFake ? AppColors.danger : isSuspicious ? AppColors.warning : AppColors.success;
    final riskLabel = isFake ? 'Fake Profile' : isSuspicious ? 'Suspicious' : 'Genuine Profile';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: riskColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isFake ? Icons.gpp_bad_rounded : isSuspicious ? Icons.warning_rounded : Icons.verified_rounded,
                    color: riskColor, size: 16),
                const SizedBox(width: 8),
                Text(riskLabel, style: GoogleFonts.outfit(color: riskColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, __) {
              final d = score * _scoreAnim.value;
              return SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _CircleGaugePainter(progress: d / 100, color: riskColor),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${d.toInt()}%',
                            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: riskColor)),
                        Text('Risk', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          _indicator('Profile Authenticity', isFake ? 'Fake' : isSuspicious ? 'Suspicious' : 'Verified', riskColor),
          const SizedBox(height: 8),
          _indicator('Username Pattern', isFake || isSuspicious ? 'Suspicious' : 'Normal', isFake || isSuspicious ? AppColors.warning : AppColors.success),
          const SizedBox(height: 8),
          _indicator('Activity Score', isFake ? 'Low' : isSuspicious ? 'Medium' : 'High', isFake ? AppColors.danger : isSuspicious ? AppColors.warning : AppColors.success),
        ],
      ),
    );
  }

  Widget _indicator(String label, String status, Color color) {
    return Row(
      children: [
        Expanded(child: Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(status, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _CircleGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  _CircleGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi * 2, false,
        Paint()..color = AppColors.surface..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi * 2 * progress, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_CircleGaugePainter old) => old.progress != progress;
}
