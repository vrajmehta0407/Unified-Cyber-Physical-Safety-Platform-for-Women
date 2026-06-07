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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ServiceLocator.instance.zones.getUnsafeZones();
      setState(() => _data = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'high': return AppColors.danger;
      case 'medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = (_data?['zones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final stats = _data?['statistics'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text('Unsafe Zone Prediction')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search Ahmedabad...')),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🗺️ Zone Heatmap — Ahmedabad')),
                ),
                if (stats != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip('High', stats['high_risk_areas'], AppColors.danger),
                      const SizedBox(width: 8),
                      _StatChip('Medium', stats['medium_risk_areas'], AppColors.warning),
                      const SizedBox(width: 8),
                      _StatChip('Safe', stats['low_risk_areas'], AppColors.success),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ...zones.map((z) => Card(
                  child: ListTile(
                    leading: Icon(Icons.place, color: _riskColor(z['risk'] as String)),
                    title: Text(z['name'] as String),
                    subtitle: Text('${z['incidents']} incidents'),
                    trailing: Text((z['risk'] as String).toUpperCase(), style: TextStyle(color: _riskColor(z['risk'] as String), fontWeight: FontWeight.bold)),
                  ),
                )),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Show My Location')),
              ],
            ),
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
          child: Column(children: [
            Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
