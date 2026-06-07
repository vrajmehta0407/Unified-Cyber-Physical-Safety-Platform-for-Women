import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  final _devices = [
    {'name': 'Apple Watch Series 9', 'connected': true},
    {'name': 'Wear OS by Google', 'connected': true},
    {'name': 'Smart Band 7', 'connected': false},
  ];
  final _toggles = {'SOS Alerts': true, 'Fall Detection': true, 'Heart Rate Monitoring': false, 'Location Sharing': true};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connected Devices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._devices.map((d) => Card(
            child: ListTile(
              leading: const Icon(Icons.watch, color: AppColors.primary),
              title: Text(d['name'] as String),
              trailing: Text(
                d['connected'] == true ? 'Connected' : 'Disconnected',
                style: TextStyle(color: d['connected'] == true ? AppColors.success : AppColors.textSecondary),
              ),
            ),
          )),
          const SizedBox(height: 24),
          const Text('Feature Toggles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ..._toggles.entries.map((e) => SwitchListTile(
            title: Text(e.key),
            value: e.value,
            onChanged: (v) => setState(() => _toggles[e.key] = v),
          )),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () {}, child: const Text('Add New Device')),
        ],
      ),
    );
  }
}
