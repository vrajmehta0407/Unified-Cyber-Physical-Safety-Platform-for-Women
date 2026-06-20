import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/sms_fallback_service.dart';
import '../../../../core/services/voice_sos_service.dart';
import '../../../../core/services/shake_sos_service.dart';
import '../../../../core/services/firebase_rtdb_service.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'fake_call_sos_page.dart';
import 'live_stream_page.dart';

enum SosState { idle, countdown, active, resolved }

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  SosState _state = SosState.idle;
  bool _silentSos = false;
  bool _voiceSos = false;
  bool _shakeSos = false;
  bool _loading = false;
  String? _activeIncidentId;
  int _countdownValue = 3;
  Timer? _countdownTimer;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _countdownCtrl;
  late final Animation<double> _countdownScale;

  final _voiceService = VoiceSosService();
  final _smsService = SmsFallbackService();
  final _shakeService = ShakeSosService();
  final _rtdb = FirebaseRtdbService();
  final _locator = ServiceLocator.instance;

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _countdownCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _countdownScale = Tween<double>(begin: 2.0, end: 1.0).animate(
        CurvedAnimation(parent: _countdownCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _countdownCtrl.dispose();
    _countdownTimer?.cancel();
    _voiceService.stopListening();
    _shakeService.stopListening();
    if (_activeIncidentId != null) {
      _rtdb.stopStreaming(incidentId: _activeIncidentId!);
    }
    super.dispose();
  }

  void _startCountdown() {
    if (_loading || _state != SosState.idle) return;
    setState(() {
      _state = SosState.countdown;
      _countdownValue = 3;
    });
    _countdownCtrl.forward(from: 0);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue <= 1) {
        timer.cancel();
        _triggerSos();
      } else {
        setState(() => _countdownValue--);
        _countdownCtrl.forward(from: 0);
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() => _state = SosState.idle);
  }

  Future<void> _triggerSos() async {
    setState(() {
      _state = SosState.active;
      _loading = true;
    });
    try {
      final position = await _locator.location.getCurrentPosition();
      final result = await _locator.sos.triggerSos(
        lat: position.latitude,
        lng: position.longitude,
        isSilent: _silentSos,
      );
      final incidentId = result['id']?.toString();
      setState(() {
        _activeIncidentId = incidentId;
        _loading = false;
      });
      // Start Firebase RTDB live location streaming
      if (incidentId != null) {
        await _rtdb.startStreaming(
          incidentId: incidentId,
          userId: result['user_id']?.toString() ?? 'unknown',
          getPosition: () async {
            final p = await _locator.location.getCurrentPosition();
            return {'lat': p.latitude, 'lng': p.longitude};
          },
        );
      }
      // Haptic feedback
      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() {
        _state = SosState.idle;
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _cancelSos() async {
    if (_activeIncidentId == null) return;
    try {
      await _locator.sos.cancelSos(_activeIncidentId!);
      await _rtdb.stopStreaming(incidentId: _activeIncidentId!, status: 'cancelled');
      setState(() {
        _state = SosState.idle;
        _activeIncidentId = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('SOS cancelled'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
      }
    }
  }

  /// Share SOS location via WhatsApp
  Future<void> _shareViaWhatsApp() async {
    try {
      final position = await _locator.location.getCurrentPosition();
      final lat = position.latitude.toStringAsFixed(6);
      final lng = position.longitude.toStringAsFixed(6);
      final msg = Uri.encodeComponent(
        '🚨 EMERGENCY SOS — I need help!\n'
        'My location: https://maps.google.com/?q=$lat,$lng\n'
        'Case ID: ${_activeIncidentId ?? "PENDING"}\n'
        'CyberShield • Ahmedabad Cyber Crime Cell • 1930',
      );
      final uri = Uri.parse('https://wa.me/?text=$msg');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('WhatsApp error: $e')));
      }
    }
  }

  /// Open fake call SOS
  void _openFakeCall() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FakeCallSosPage()),
    );
  }

  /// Open live stream
  void _openLiveStream() {
    if (_activeIncidentId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveStreamPage(incidentId: _activeIncidentId!),
      ),
    );
  }

  Future<void> _resolveImSafe() async {
    if (_activeIncidentId == null) return;
    try {
      await _locator.sos.resolveSos(_activeIncidentId!);
      setState(() {
        _state = SosState.resolved;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You are safe! Guardians notified.'),
              backgroundColor: AppColors.success),
        );
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _state = SosState.idle;
            _activeIncidentId = null;
          });
        }
      });
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
      if (numbers.isEmpty) numbers = ['112', '1091'];
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
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _state == SosState.active
                    ? [const Color(0xFF2A0A0A), const Color(0xFF1A0505)]
                    : _state == SosState.resolved
                        ? [const Color(0xFF0A2A1A), const Color(0xFF051A0F)]
                        : [const Color(0xFF1A0A0A), const Color(0xFF0F0A1A)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: _state == SosState.active
                        ? _buildActiveEmergencyView()
                        : _state == SosState.resolved
                            ? _buildResolvedView()
                            : _buildIdleView(),
                  ),
                ],
              ),
            ),
          ),
          // Countdown overlay
          if (_state == SosState.countdown) _buildCountdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.dividerTheme.color ?? AppColors.border))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: t.cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.dividerTheme.color ?? AppColors.border),
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
          if (_state == SosState.active)
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

  Widget _buildIdleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildInfoBanner(),
          const SizedBox(height: 32),
          _buildSosButton(),
          const SizedBox(height: 8),
          Text(
            'Tap to Send SOS',
            style: GoogleFonts.outfit(
                color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildToggles(),
          const SizedBox(height: 16),
          _buildSosAlternatives(),
          const SizedBox(height: 24),
          _buildOfflineSos(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActiveEmergencyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Pulsing SOS indicator
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Container(
              width: 100 * _pulseAnim.value,
              height: 100 * _pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withOpacity(0.15),
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.danger, Color(0xFFB91C1C)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.emergency, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('SOS ACTIVE',
              style: GoogleFonts.spaceGrotesk(
                  color: AppColors.danger,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3)),
          const SizedBox(height: 4),
          if (_activeIncidentId != null)
            Text('Case ID: INC-${_activeIncidentId!.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 20),
          // Status chips
          _StatusChip(icon: Icons.local_police, label: 'Police Notified', color: AppColors.danger, time: DateTime.now()),
          _StatusChip(icon: Icons.people, label: 'Guardians Alerted', color: AppColors.warning, time: DateTime.now()),
          _StatusChip(icon: Icons.location_on, label: 'Location Streaming Active', color: AppColors.info, time: DateTime.now()),
          const SizedBox(height: 24),
          // Live stream button
          GestureDetector(
            onTap: _openLiveStream,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Text('Stream Live to Police',
                      style: GoogleFonts.outfit(
                          color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // WhatsApp share
          GestureDetector(
            onTap: _shareViaWhatsApp,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF25D366).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                  const SizedBox(width: 8),
                  Text('Share via WhatsApp',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF25D366), fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // I'm Safe button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: GestureDetector(
              onTap: _resolveImSafe,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.success, Color(0xFF00B87A)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text("I'm Safe",
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _cancelSos,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.5)),
              ),
              child: Center(
                child: Text('Cancel SOS',
                    style: GoogleFonts.outfit(
                        color: AppColors.danger,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResolvedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withOpacity(0.15),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
          ),
          const SizedBox(height: 20),
          Text('You Are Safe',
              style: GoogleFonts.spaceGrotesk(
                  color: AppColors.success,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Guardians have been notified that you are safe.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: AppColors.danger.withOpacity(0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text('SENDING SOS IN',
                style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 3)),
            const SizedBox(height: 20),
            ScaleTransition(
              scale: _countdownScale,
              child: Text(
                '$_countdownValue',
                style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: GestureDetector(
                  onTap: _cancelCountdown,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('CANCEL',
                          style: GoogleFonts.outfit(
                              color: AppColors.danger,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
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
        onTap: _loading ? null : _startCountdown,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220 * _pulseAnim.value,
              height: 220 * _pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withOpacity(0.08 * (2 - _pulseAnim.value)),
              ),
            ),
            Container(
              width: 195 * _pulseAnim.value,
              height: 195 * _pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withOpacity(0.15 * (2 - _pulseAnim.value)),
              ),
            ),
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
                          Text('TAP',
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

  Widget _buildToggles() {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.dividerTheme.color ?? AppColors.border),
      ),
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
              color: t.dividerTheme.color ?? AppColors.border,
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
                      _voiceService.startListening(onTrigger: _startCountdown);
                    } else {
                      _voiceService.stopListening();
                    }
                  },
          ),
          Container(
              height: 1,
              color: t.dividerTheme.color ?? AppColors.border,
              margin: const EdgeInsets.symmetric(vertical: 12)),
          _ToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Shake SOS',
            subtitle: 'Shake phone 2x to trigger',
            value: _shakeSos,
            onChanged: _loading
                ? null
                : (v) {
                    setState(() => _shakeSos = v);
                    if (v) {
                      _shakeService.startListening(
                        onShake: _startCountdown,
                        shakeSensitivity: 15.0,
                        minimumShakeCount: 2,
                      );
                    } else {
                      _shakeService.stopListening();
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildSosAlternatives() {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.dividerTheme.color ?? AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Discreet Modes',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: t.textTheme.bodySmall?.color)),
          const SizedBox(height: 10),
          // Fake Call button
          GestureDetector(
            onTap: _openFakeCall,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded,
                        color: Color(0xFF667EEA), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fake Call SOS',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Disguise as incoming call while sending SOS',
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: t.textTheme.bodySmall?.color)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 13, color: Color(0xFF667EEA)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSos() {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: _loading ? null : _sendSmsFallback,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.dividerTheme.color ?? AppColors.border),
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
                          color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final DateTime time;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.jetBrainsMono(color: color, fontSize: 11),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
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
    final t = Theme.of(context);
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: t.textTheme.titleMedium?.color)),
              Text(subtitle,
                  style: GoogleFonts.outfit(
                      color: t.textTheme.bodySmall?.color, fontSize: 12)),
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
