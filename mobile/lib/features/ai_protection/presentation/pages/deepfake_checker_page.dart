import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class DeepfakeCheckerPage extends StatefulWidget {
  const DeepfakeCheckerPage({super.key});

  @override
  State<DeepfakeCheckerPage> createState() => _DeepfakeCheckerPageState();
}

class _DeepfakeCheckerPageState extends State<DeepfakeCheckerPage>
    with SingleTickerProviderStateMixin {
  File? _selectedFile;
  bool _loading = false;
  Map<String, dynamic>? _result;
  late final AnimationController _scoreCtrl;
  late final Animation<double> _scoreAnim;
  final _ai = ServiceLocator.instance.ai;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreAnim = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _selectedFile = File(picked.path);
      _result = null;
    });
  }

  Future<void> _analyze() async {
    if (_selectedFile == null) return;
    setState(() => _loading = true);
    try {
      final r = await _ai.detectDeepfake(_selectedFile!);
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
                  _buildUploadCard(),
                  const SizedBox(height: 16),
                  if (_result != null) _buildResultCard(),
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
                  Text('Deepfake Detector',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('AI-powered media authenticity check',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: _selectedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(_selectedFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_rounded, color: AppColors.primary, size: 28),
                              const SizedBox(height: 6),
                              Text('Upload Image', style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('JPG, PNG, BMP', style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 10)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_outlined, color: AppColors.textSecondary, size: 28),
                        const SizedBox(height: 6),
                        Text('Upload Video', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('MP4, MOV, AVI', style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Select an image or video to analyze for deepfake detection',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: (_selectedFile != null && !_loading) ? _analyze : null,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: _selectedFile != null
                    ? const LinearGradient(colors: AppColors.primaryGradient)
                    : const LinearGradient(colors: [Color(0xFF3A2860), Color(0xFF2A1A50)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.analytics_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('Analyse Media',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
    final verdict = _result!['verdict'] as String? ?? 'unknown';
    final details = _result!['details'] as Map<String, dynamic>? ?? {};
    final isFake = verdict == 'fake';

    final riskColor = score >= 70
        ? AppColors.danger
        : score >= 40
            ? AppColors.warning
            : AppColors.success;
    final riskLabel = score >= 70 ? 'High Risk' : score >= 40 ? 'Medium Risk' : 'Low Risk';

    return Column(
      children: [
        // Score card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text('Analysis Result',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              // Circular gauge
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (_, __) {
                  final displayScore = score * _scoreAnim.value;
                  return SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _RiskGaugePainter(
                        progress: displayScore / 100,
                        color: riskColor,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedFile != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_selectedFile!, width: 48, height: 48, fit: BoxFit.cover),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${displayScore.toInt()}%',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                            Text('Risk Score',
                                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor.withOpacity(0.4)),
                ),
                child: Text(
                  '${isFake ? "⚠️" : "✅"} $riskLabel',
                  style: GoogleFonts.outfit(color: riskColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isFake
                    ? 'Possibility of deepfake content detected'
                    : 'Media appears to be authentic',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Risk bar
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
              Text('Risk Level', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation(riskColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Low', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.success)),
                  Text('Medium', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.warning)),
                  Text('High', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.danger)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Details
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
              Text('Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...details.entries.map((e) {

                final val = e.value.toString();
                Color c = _levelColor(val);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatKey(e.key),
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c.withOpacity(0.4)),
                        ),
                        child: Text(val, style: GoogleFonts.outfit(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // View full report button
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
              child: Text('View Full Report',
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color _levelColor(String val) {
    final v = val.toLowerCase();
    if (v.contains('high') || v.contains('fake') || v.contains('suspicious')) return AppColors.danger;
    if (v.contains('medium') || v.contains('unusual')) return AppColors.warning;
    if (v.contains('low') || v.contains('normal') || v.contains('real')) return AppColors.success;
    return AppColors.textSecondary;
  }

  String _formatKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

class _RiskGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  _RiskGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * progress, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RiskGaugePainter old) => old.progress != progress || old.color != color;
}
