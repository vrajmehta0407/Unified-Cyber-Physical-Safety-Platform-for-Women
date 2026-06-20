import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/shake_sos_service.dart';

/// Global SOS FAB Wrapper
/// Wraps any scaffold to add a persistent floating SOS button (#FF3B6B)
/// and optional shake-to-SOS gesture detection at the app shell level.
/// 
/// Usage: wrap your Scaffold or page widget with this widget.
class SosShellWrapper extends StatefulWidget {
  final Widget child;
  final bool showFab;
  final bool enableShake;

  const SosShellWrapper({
    super.key,
    required this.child,
    this.showFab = true,
    this.enableShake = false,
  });

  @override
  State<SosShellWrapper> createState() => _SosShellWrapperState();
}

class _SosShellWrapperState extends State<SosShellWrapper>
    with SingleTickerProviderStateMixin {
  final _shakeService = ShakeSosService();
  late AnimationController _fabPulseCtrl;
  late Animation<double> _fabPulse;

  @override
  void initState() {
    super.initState();

    _fabPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _fabPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _fabPulseCtrl, curve: Curves.easeInOut),
    );

    if (widget.enableShake) {
      _shakeService.startListening(
        onShake: _triggerSos,
        minimumShakeCount: 2,
      );
    }
  }

  void _triggerSos() {
    if (!mounted) return;
    context.push('/sos');
  }

  @override
  void dispose() {
    _fabPulseCtrl.dispose();
    if (widget.enableShake) _shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showFab) return widget.child;

    return Stack(
      children: [
        widget.child,
        // Floating SOS FAB — bottom right
        Positioned(
          bottom: 90, // above bottom nav bar
          right: 16,
          child: AnimatedBuilder(
            animation: _fabPulse,
            builder: (_, child) => Transform.scale(
              scale: _fabPulse.value,
              child: child,
            ),
            child: _SosFab(onTap: _triggerSos),
          ),
        ),
      ],
    );
  }
}

class _SosFab extends StatelessWidget {
  final VoidCallback onTap;
  const _SosFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFF3B6B), Color(0xFFCC1A47)],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B6B).withOpacity(0.6),
              blurRadius: 18,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
            const SizedBox(height: 1),
            Text(
              'SOS',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
