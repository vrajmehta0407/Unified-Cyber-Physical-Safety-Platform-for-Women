import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.push('/awareness'); break;
      case 2: context.push('/sos'); break;
      case 3: context.push('/community'); break;
      case 4: context.push('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', index: 0, current: currentIndex, onTap: (i) => _onTap(context, i)),
                  _NavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield, label: 'Safety', index: 1, current: currentIndex, onTap: (i) => _onTap(context, i)),
                  const Expanded(child: SizedBox()), // SOS space
                  _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Community', index: 3, current: currentIndex, onTap: (i) => _onTap(context, i)),
                  _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', index: 4, current: currentIndex, onTap: (i) => _onTap(context, i)),
                ],
              ),
              // Central SOS button — raised above bar
              Positioned(
                top: -22,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _onTap(context, 2),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.dangerGradient,
                        ),
                        border: Border.all(color: AppColors.surface, width: 3),
                        boxShadow: [
                          BoxShadow(color: AppColors.danger.withOpacity(0.5), blurRadius: 16, spreadRadius: 2),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emergency, color: Colors.white, size: 22),
                          Text('SOS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
