import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/sms_fallback_service.dart';
import '../../../../core/services/voice_sos_service.dart';
import '../../../../shared/widgets/glass_card.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  bool _silentSos = false;
  bool _voiceSos = false;
  bool _loading = false;
  String? _activeIncidentId;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final _voiceService = VoiceSosService();
  final _smsService = SmsFallbackService();
  final _locator = ServiceLocator.instance;

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  Future<void> _triggerSos() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final position = await _locator.location.getCurrentPosition();
      final result = await _locator.sos.triggerSos(
        lat: position.latitude,
        lng: position.longitude,
        isSilent: _silentSos,
      );
      setState(() => _activeIncidentId = result['id']?.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_silentSos
              ? 'Silent SOS sent! ID: ${result['id']}'
              : '🚨 SOS Alert triggered! Help is on the way.'),
          backgroundColor: AppColors.danger,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancelSos() async {
    if (_activeIncidentId == null) return;
    try {
      await _locator.sos.cancelSos(_activeIncidentId!);
      setState(() => _activeIncidentId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('SOS cancelled'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
      }
    }
  }

  Future<void> _sendSmsFallback() async {
    try {
      final position = await _locator.location.getCurrentPosition();
      List<String> numbers = [];
      try {
        final gs = await _locator.guardians.listGuardians();
        numbers = gs.map((g) => g['phone']?.toString() ?? '').where((p) => p.isNotEmpty).toList();
      } catch (_) {}
      
      if (numbers.isEmpty) {
        numbers = ['112', '1091'];
      }
      
      await _smsService.sendSosSms(
          phoneNumbers: numbers,
          lat: position.latitude,
          lng: position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
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
            colors: [Color(0xFF1A0A0A), Color(0xFF0F0A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildInfoBanner(),
                      const SizedBox(height: 32),
                      _buildSosButton(),
                      const SizedBox(height: 8),
                      Text(
                        _activeIncidentId != null
                            ? 'SOS Active — Tap to Cancel'
                            : 'Tap to Send SOS',
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      if (_activeIncidentId != null) ...[
                        const SizedBox(height: 16),
                        _buildActiveCard(),
                      ],
                      const SizedBox(height: 32),
                      _buildToggles(),
                      const SizedBox(height: 24),
                      _buildOfflineSos(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.danger, Color(0xFFFF6B6B)]).createShader(b),
            child: Text('SOS Emergency',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const Spacer(),
          if (_activeIncidentId != null)
            GestureDetector(
              onTap: _cancelSos,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withOpacity(0.5)),
                ),
                child: Text('Cancel SOS',
                    style: GoogleFonts.outfit(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your SOS will be sent to Police and your Emergency Contacts',
              style: GoogleFonts.outfit(
                  color: AppColors.danger.withOpacity(0.9), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => GestureDetector(
        onTap: _loading
            ? null
            : (_activeIncidentId != null ? _cancelSos : _triggerSos),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 220 * _pulseAnim.value,
              height: 220 * _pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    AppColors.danger.withOpacity(0.08 * (2 - _pulseAnim.value)),
              ),
            ),
            // Middle ring
            Container(
              width: 195 * _pulseAnim.value,
              height: 195 * _pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    AppColors.danger.withOpacity(0.15 * (2 - _pulseAnim.value)),
              ),
            ),
            // Main button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _loading
                      ? [
                          AppColors.danger.withOpacity(0.6),
                          AppColors.dangerDark.withOpacity(0.6)
                        ]
                      : [AppColors.danger, AppColors.dangerDark],
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.danger.withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 5),
                ],
              ),
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SOS',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_activeIncidentId != null ? 'ACTIVE' : 'TAP',
                              style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 2)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOS Active',
                    style: GoogleFonts.outfit(
                        color: AppColors.danger, fontWeight: FontWeight.bold)),
                Text('Incident ID: $_activeIncidentId',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
                color: AppColors.danger, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildToggles() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ToggleRow(
            icon: Icons.volume_off,
            title: 'Silent SOS',
            subtitle: 'Send alert silently without sound',
            value: _silentSos,
            onChanged: _loading ? null : (v) => setState(() => _silentSos = v),
          ),
          Container(
              height: 1,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(vertical: 12)),
          _ToggleRow(
            icon: Icons.mic,
            title: 'Voice SOS',
            subtitle: 'Say "Help Me" to trigger',
            value: _voiceSos,
            onChanged: _loading
                ? null
                : (v) async {
                    setState(() => _voiceSos = v);
                    if (v) {
                      await _voiceService.initialize();
                      _voiceService.startListening(onTrigger: _triggerSos);
                    } else {
                      _voiceService.stopListening();
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSos() {
    return GestureDetector(
      onTap: _loading ? null : _sendSmsFallback,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sms, color: AppColors.warning),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send SOS via SMS',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  Text('Works without internet',
                      style: GoogleFonts.outfit(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle,
                  style: GoogleFonts.outfit(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
