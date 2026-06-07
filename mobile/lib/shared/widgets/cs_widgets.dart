import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Animated pulsing circle used for the SOS button and alerts
class PulseCircle extends StatefulWidget {
  final Color color;
  final double size;
  final Widget child;
  final bool pulsing;

  const PulseCircle({
    super.key,
    required this.color,
    required this.size,
    required this.child,
    this.pulsing = true,
  });

  @override
  State<PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<PulseCircle> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulsing) {
      return _buildCircle(1.0);
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: widget.size * _anim.value * 1.2,
            height: widget.size * _anim.value * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.15 * (2 - _anim.value)),
            ),
          ),
          // Middle ring
          Container(
            width: widget.size * _anim.value * 1.05,
            height: widget.size * _anim.value * 1.05,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.25 * (2 - _anim.value)),
            ),
          ),
          _buildCircle(1.0),
        ],
      ),
    );
  }

  Widget _buildCircle(double scale) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
        boxShadow: [
          BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: Center(child: widget.child),
    );
  }
}

/// Risk badge chip — colored label for High/Medium/Low risk
class RiskBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const RiskBadge({super.key, required this.label, required this.color, this.fontSize = 12});

  factory RiskBadge.high({String label = 'High'}) =>
      RiskBadge(label: label, color: AppColors.riskHigh);
  factory RiskBadge.medium({String label = 'Medium'}) =>
      RiskBadge(label: label, color: AppColors.riskMedium);
  factory RiskBadge.low({String label = 'Low', Color color = AppColors.riskLow}) =>
      RiskBadge(label: label, color: color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Gradient icon container card for quick action tiles
class ActionIconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color> gradient;
  final String? subtitle;

  const ActionIconCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient = AppColors.primaryGradient,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width action list tile with gradient icon
class ActionListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final List<Color> gradient;

  const ActionListTile({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

/// Section header with optional "View All" link
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}

/// Cybershield app bar with gradient title
PreferredSizeWidget csAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
}) {
  return AppBar(
    backgroundColor: AppColors.surface,
    elevation: 0,
    centerTitle: true,
    leading: showBack && context != null
        ? IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null,
    title: ShaderMask(
      shaderCallback: (b) => const LinearGradient(colors: AppColors.primaryGradient).createShader(b),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: AppColors.border),
    ),
  );
}
