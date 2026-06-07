import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class CommunitySafetyPage extends StatelessWidget {
  const CommunitySafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final volunteers = <Map<String, dynamic>>[
      {'name': 'Priya M.', 'distance': '1.2 km', 'rating': 4.9, 'status': 'Available'},
      {'name': 'Anjali S.', 'distance': '2.1 km', 'rating': 4.7, 'status': 'Available'},
      {'name': 'Meera K.', 'distance': '3.0 km', 'rating': 4.8, 'status': 'Busy'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Community')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Nearby Verified Volunteers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...volunteers.map((v) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.volunteer_activism)),
              title: Text(v['name'] as String),
              subtitle: Text('${v['distance']} away · ⭐ ${v['rating']}'),
              trailing: Text(v['status'] as String, style: TextStyle(color: v['status'] == 'Available' ? AppColors.success : AppColors.warning)),
            ),
          )),
          const SizedBox(height: 24),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _ActionChip(Icons.emergency, 'Emergency Assistance', () => context.push('/sos')),
            _ActionChip(Icons.check_circle, 'Safety Check-in', () {}),
            _ActionChip(Icons.report, 'Report Incident', () => context.push('/report')),
            _ActionChip(Icons.notifications, 'Community Alerts', () {}),
          ]),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Check-in with your loved ones', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Let guardians know you are safe', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => context.push('/guardians'), child: const Text('Check-in Now')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
