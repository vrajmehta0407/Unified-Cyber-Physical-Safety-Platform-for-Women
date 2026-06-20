import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/sms_fallback_service.dart';

/// Fake Call SOS Page
/// Displays a realistic incoming call screen that secretly triggers SOS.
/// Use case: victim surrounded by attacker, needs to trigger SOS discreetly.
class FakeCallSosPage extends StatefulWidget {
  const FakeCallSosPage({super.key});

  @override
  State<FakeCallSosPage> createState() => _FakeCallSosPageState();
}

class _FakeCallSosPageState extends State<FakeCallSosPage>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ring1;
  late Animation<double> _ring2;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  bool _sosSent = false;
  bool _declined = false;
  Timer? _autoDeclineTimer;
  Timer? _ringTimer;
  int _ringsLeft = 5;

  final _locator = ServiceLocator.instance;
  final _smsService = SmsFallbackService();

  // Fake caller names for disguise
  static const _callerName = 'Mom';
  static const _callerNumber = '+91 98765 43210';

  @override
  void initState() {
    super.initState();

    // Pulsing ring animation
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _ring1 = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );
    _ring2 = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _ringCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Slide animation for accept/decline buttons
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    // Vibrate phone like a real call
    _startRinging();

    // Auto-decline after 30s (realistic call behavior)
    _autoDeclineTimer = Timer(const Duration(seconds: 30), _onDecline);

    // Silently trigger SOS immediately when screen opens
    _silentlyTriggerSos();
  }

  void _startRinging() {
    _ringTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_ringsLeft > 0 && !_sosSent && !_declined) {
        HapticFeedback.vibrate();
        setState(() => _ringsLeft--);
      }
    });
    HapticFeedback.vibrate();
  }

  Future<void> _silentlyTriggerSos() async {
    try {
      final position = await _locator.location.getCurrentPosition();
      await _locator.sos.triggerSos(
        lat: position.latitude,
        lng: position.longitude,
        isSilent: true, // silent — no sound, no visible alert
      );

      // Also send SMS fallback
      List<String> numbers = [];
      try {
        final gs = await _locator.guardians.listGuardians();
        numbers =
            gs.map((g) => g['phone']?.toString() ?? '').where((p) => p.isNotEmpty).toList();
      } catch (_) {}
      if (numbers.isNotEmpty) {
        await _smsService.sendSosSms(
          phoneNumbers: numbers,
          lat: position.latitude,
          lng: position.longitude,
        );
      }

      if (mounted) setState(() => _sosSent = true);
    } catch (e) {
      debugPrint('[FakeCall] SOS trigger failed: $e');
    }
  }

  void _onDecline() {
    if (!mounted) return;
    setState(() => _declined = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _onAccept() {
    // Show "connected" screen briefly, then pop
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _slideCtrl.dispose();
    _autoDeclineTimer?.cancel();
    _ringTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Status bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _sosSent ? '🔴 SOS Sent Silently' : '📡 Connecting...',
                        style: GoogleFonts.outfit(
                          color: _sosSent ? AppColors.success : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'CyberShield',
                        style: GoogleFonts.outfit(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Caller avatar with pulsing rings
                AnimatedBuilder(
                  animation: _ringCtrl,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring 1
                      Transform.scale(
                        scale: _ring1.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                  (1 - _ringCtrl.value).clamp(0.0, 0.15)),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Outer ring 2
                      Transform.scale(
                        scale: _ring2.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                  (1 - _ringCtrl.value * 0.7).clamp(0.0, 0.2)),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Avatar
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          border: Border.all(color: Colors.white24, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _callerName[0],
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Caller name
                Text(
                  _callerName,
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _callerNumber,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 12),

                // Status
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _declined
                      ? Text(
                          'Call ended',
                          key: const ValueKey('ended'),
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        )
                      : Row(
                          key: const ValueKey('ringing'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_in_talk_rounded,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 6),
                            Text(
                              'Incoming call...',
                              style: GoogleFonts.outfit(
                                color: AppColors.success,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),

                const Spacer(flex: 3),

                // Accept / Decline buttons
                SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Decline
                        _CallButton(
                          icon: Icons.call_end_rounded,
                          label: 'Decline',
                          color: AppColors.danger,
                          onTap: _onDecline,
                        ),

                        // Silent SOS indicator (shows only after SOS sent)
                        if (_sosSent)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.success.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SOS Active',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // Accept
                        _CallButton(
                          icon: Icons.call_rounded,
                          label: 'Accept',
                          color: AppColors.success,
                          onTap: _onAccept,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
