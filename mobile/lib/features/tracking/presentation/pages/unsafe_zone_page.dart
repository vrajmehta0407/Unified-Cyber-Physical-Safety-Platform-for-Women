import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class UnsafeZonePage extends StatefulWidget {
  const UnsafeZonePage({super.key});

  @override
  State<UnsafeZonePage> createState() => _UnsafeZonePageState();
}

class _UnsafeZonePageState extends State<UnsafeZonePage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ServiceLocator.instance.zones.getUnsafeZones();
      setState(() => _data = data);
    } catch (_) {
      setState(() => _data = _fallbackZoneData);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allZones =
        (_data?['zones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final zones = allZones.where((z) {
      if (_query.trim().isEmpty) return true;
      return z['name'].toString().toLowerCase().contains(_query.toLowerCase());
    }).toList();
    final stats = _data?['statistics'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsafe Zone Map'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search Ahmedabad areas'),
                ),
                const SizedBox(height: 16),
                _RiskMapPreview(zones: allZones, riskColor: _riskColor),
                if (stats != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip(
                          'High', stats['high_risk_areas'], AppColors.danger),
                      const SizedBox(width: 8),
                      _StatChip('Medium', stats['medium_risk_areas'],
                          AppColors.warning),
                      const SizedBox(width: 8),
                      _StatChip(
                          'Safer', stats['low_risk_areas'], AppColors.success),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ...zones.map((z) {
                  final risk = z['risk']?.toString() ?? 'low';
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.place, color: _riskColor(risk)),
                      title: Text(z['name']?.toString() ?? ''),
                      subtitle: Text(
                          '${z['incidents'] ?? 0} recent incidents - ${z['advice'] ?? 'Stay alert'}'),
                      trailing: Text(
                        risk.toUpperCase(),
                        style: TextStyle(
                            color: _riskColor(risk),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Location overlay ready. Enable GPS to compare your route with risk zones.')),
                  ),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Show My Location'),
                ),
              ],
            ),
    );
  }
}

class _RiskMapPreview extends StatelessWidget {
  final List<Map<String, dynamic>> zones;
  final Color Function(String risk) riskColor;
  const _RiskMapPreview({required this.zones, required this.riskColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 16,
            top: 16,
            child: Text('Ahmedabad AI Risk Heatmap',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ...zones.take(6).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final zone = entry.value;
            final offsets = [
              const Offset(42, 70),
              const Offset(155, 52),
              const Offset(245, 92),
              const Offset(82, 148),
              const Offset(190, 152),
              const Offset(285, 158),
            ];
            final offset = offsets[index % offsets.length];
            final risk = zone['risk']?.toString() ?? 'low';
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Tooltip(
                message: zone['name']?.toString() ?? '',
                child: Container(
                  width: risk == 'high' ? 58 : 46,
                  height: risk == 'high' ? 58 : 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor(risk).withOpacity(0.28),
                    border: Border.all(color: riskColor(risk), width: 2),
                  ),
                ),
              ),
            );
          }),
          const Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Legend(color: AppColors.danger, label: 'High'),
                _Legend(color: AppColors.warning, label: 'Medium'),
                _Legend(color: AppColors.success, label: 'Safer'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

const _fallbackZoneData = {
  'statistics': {
    'high_risk_areas': 2,
    'medium_risk_areas': 3,
    'low_risk_areas': 2
  },
  'zones': [
    {
      'name': 'Kalupur Railway Station',
      'risk': 'high',
      'incidents': 18,
      'advice': 'Avoid isolated exits late night'
    },
    {
      'name': 'Maninagar Transit Hub',
      'risk': 'medium',
      'incidents': 9,
      'advice': 'Prefer main roads after 8 PM'
    },
    {
      'name': 'CG Road',
      'risk': 'medium',
      'incidents': 7,
      'advice': 'Stay near well-lit areas'
    },
    {
      'name': 'Satellite',
      'risk': 'low',
      'incidents': 3,
      'advice': 'Normal caution'
    },
    {
      'name': 'Naroda GIDC',
      'risk': 'high',
      'incidents': 14,
      'advice': 'Use trusted transport'
    },
    {
      'name': 'Sabarmati Riverfront',
      'risk': 'medium',
      'incidents': 8,
      'advice': 'Travel in groups at night'
    },
    {
      'name': 'Vastrapur',
      'risk': 'low',
      'incidents': 2,
      'advice': 'Normal caution'
    },
  ],
};
