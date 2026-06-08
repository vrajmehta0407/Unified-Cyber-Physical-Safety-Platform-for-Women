import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class CommunitySafetyPage extends StatefulWidget {
  const CommunitySafetyPage({super.key});

  @override
  State<CommunitySafetyPage> createState() => _CommunitySafetyPageState();
}

class _CommunitySafetyPageState extends State<CommunitySafetyPage> {
  bool _checkedIn = false;
  DateTime? _lastCheckIn;

  void _checkIn() {
    setState(() {
      _checkedIn = true;
      _lastCheckIn = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Safety check-in sent to guardians and nearby volunteer network.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final volunteers = <Map<String, dynamic>>[
      {
        'name': 'Priya M.',
        'distance': '1.2 km',
        'rating': 4.9,
        'status': 'Available'
      },
      {
        'name': 'Anjali S.',
        'distance': '2.1 km',
        'rating': 4.7,
        'status': 'Available'
      },
      {
        'name': 'Meera K.',
        'distance': '3.0 km',
        'rating': 4.8,
        'status': 'Busy'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Community')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CheckInCard(
              checkedIn: _checkedIn,
              lastCheckIn: _lastCheckIn,
              onCheckIn: _checkIn),
          const SizedBox(height: 18),
          const Text('Nearby Verified Volunteers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...volunteers.map((v) => Card(
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.volunteer_activism)),
                  title: Text(v['name'] as String),
                  subtitle:
                      Text('${v['distance']} away - rating ${v['rating']}'),
                  trailing: Text(
                    v['status'] as String,
                    style: TextStyle(
                        color: v['status'] == 'Available'
                            ? AppColors.success
                            : AppColors.warning),
                  ),
                ),
              )),
          const SizedBox(height: 24),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _ActionChip(Icons.emergency, 'Emergency Assistance',
                () => context.push('/sos')),
            _ActionChip(Icons.check_circle, 'Safety Check-in', _checkIn),
            _ActionChip(
                Icons.report, 'Report Incident', () => context.push('/report')),
            _ActionChip(Icons.notifications, 'Community Alerts', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('No new high-risk community alerts nearby.')),
              );
            }),
          ]),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final bool checkedIn;
  final DateTime? lastCheckIn;
  final VoidCallback onCheckIn;
  const _CheckInCard(
      {required this.checkedIn,
      required this.lastCheckIn,
      required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(checkedIn ? Icons.verified : Icons.shield_outlined,
                    color: checkedIn ? AppColors.success : AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    checkedIn
                        ? 'You are checked in as safe'
                        : 'Check in with guardians',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              checkedIn && lastCheckIn != null
                  ? 'Last check-in: ${lastCheckIn!.hour.toString().padLeft(2, '0')}:${lastCheckIn!.minute.toString().padLeft(2, '0')}'
                  : 'Notify guardians and community volunteers that you are safe.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: onCheckIn, child: const Text('Check-in Now')),
          ],
        ),
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
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
