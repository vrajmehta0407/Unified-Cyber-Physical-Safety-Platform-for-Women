import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class PhishingCheckerPage extends StatefulWidget {
  const PhishingCheckerPage({super.key});

  @override
  State<PhishingCheckerPage> createState() => _PhishingCheckerPageState();
}

class _PhishingCheckerPageState extends State<PhishingCheckerPage>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
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
    _urlController.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final result = await _ai.checkPhishing(input);
      setState(() => _result = result);
      _scoreCtrl.forward(from: 0);
    } catch (e) {
      final r = _localAnalysis(input);
      setState(() => _result = r);
      _scoreCtrl.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _localAnalysis(String input) {
    var score = 12;
    final lower = input.toLowerCase();
    for (final f in ['verify', 'urgent', 'password', 'otp', 'bank', 'prize', 'free', 'bit.ly', 'login']) {
      if (lower.contains(f)) score += 10;
    }
    if (!lower.startsWith('https://') && lower.contains('.')) score += 12;
    if (RegExp(r'\d{1,3}(\.\d{1,3}){3}').hasMatch(lower)) score += 18;
    score = score.clamp(0, 96);
    return {
      'risk_score': score,
      'verdict': score >= 60 ? 'phishing' : score >= 30 ? 'suspicious' : 'safe',
      'message': score >= 60 ? 'Multiple phishing indicators found' : score >= 30 ? 'Some caution indicators' : 'No major red flags found',
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
                  Text('Phishing Checker',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Check if a link or message is safe',
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
          Text('Enter URL or SMS Text',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextField(
            controller: _urlController,
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'https://example.com or paste SMS content...',
              hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _loading ? null : _check,
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
                          const Icon(Icons.radar_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('Analyze',
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

    final isPhishing = score >= 60;
    final isSuspicious = score >= 30 && score < 60;
    final riskColor = isPhishing ? AppColors.danger : isSuspicious ? AppColors.warning : AppColors.success;
    final riskLabel = isPhishing ? 'Phishing Detected' : isSuspicious ? 'Suspicious' : 'Safe';
    final riskIcon = isPhishing ? Icons.dangerous_rounded : isSuspicious ? Icons.warning_rounded : Icons.check_circle_rounded;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: riskColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Verdict badge
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
                    Icon(riskIcon, color: riskColor, size: 18),
                    const SizedBox(width: 8),
                    Text(riskLabel,
                        style: GoogleFonts.outfit(color: riskColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Score gauge
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (_, __) {
                  final d = score * _scoreAnim.value;
                  return SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: _PhishingGaugePainter(progress: d / 100, color: riskColor),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${d.toInt()}%',
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
              Text(message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              // Risk indicators
              _buildIndicatorRow('Phishing Indicators', isPhishing ? 'Found' : 'None', isPhishing ? AppColors.danger : AppColors.success),
              const SizedBox(height: 8),
              _buildIndicatorRow('URL Safety', !isPhishing ? 'Verified' : 'Suspicious', !isPhishing ? AppColors.success : AppColors.danger),
              const SizedBox(height: 8),
              _buildIndicatorRow('Domain Check', isSuspicious || isPhishing ? 'Flagged' : 'Clear', isSuspicious || isPhishing ? AppColors.warning : AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(String label, String status, Color color) {
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

class _PhishingGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  _PhishingGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false,
        Paint()..color = AppColors.surface..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * progress, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PhishingGaugePainter old) => old.progress != progress;
}
