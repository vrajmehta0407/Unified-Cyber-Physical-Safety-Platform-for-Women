import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

const _devices = [
  _Device('Apple Watch Series 9', Icons.watch_rounded, 'smartwatch', true),
  _Device('Wear OS by Google', Icons.watch_outlined, 'smartwatch', true),
  _Device('Smart Band 7', Icons.fitbit_outlined, 'fitness', false),
];

class _Device {
  final String name;
  final IconData icon;
  final String type;
  final bool connected;
  const _Device(this.name, this.icon, this.type, this.connected);
}

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  bool _sosAlerts = true;
  bool _fallDetection = true;
  bool _heartRate = false;
  bool _locationSharing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSectionLabel('Paired Devices'),
                  const SizedBox(height: 12),
                  ..._devices.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DeviceCard(device: d),
                      )),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Features'),
                  const SizedBox(height: 12),
                  _buildFeaturesCard(),
                  const SizedBox(height: 24),
                  _buildAddDeviceButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 14),
              Text('Connected Devices',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  }

  Widget _buildFeaturesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _FeatureToggle(
            icon: Icons.emergency_rounded,
            label: 'SOS Alerts',
            subtitle: 'Send SOS from your device',
            value: _sosAlerts,
            onChanged: (v) => setState(() => _sosAlerts = v),
            isFirst: true,
          ),
          _FeatureToggle(
            icon: Icons.personal_injury_outlined,
            label: 'Fall Detection',
            subtitle: 'Auto SOS on sudden fall',
            value: _fallDetection,
            onChanged: (v) => setState(() => _fallDetection = v),
          ),
          _FeatureToggle(
            icon: Icons.favorite_outline,
            label: 'Heart Rate Monitoring',
            subtitle: 'Track stress & anomalies',
            value: _heartRate,
            onChanged: (v) => setState(() => _heartRate = v),
          ),
          _FeatureToggle(
            icon: Icons.share_location_outlined,
            label: 'Location Sharing',
            subtitle: 'Share GPS from wearable',
            value: _locationSharing,
            onChanged: (v) => setState(() => _locationSharing = v),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddDeviceButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Searching for nearby devices...')),
        );
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Add New Device',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final _Device device;
  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: device.connected ? AppColors.success.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: device.connected
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              device.icon,
              color: device.connected ? AppColors.success : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(device.type,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: device.connected
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: device.connected
                    ? AppColors.success.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: device.connected ? AppColors.success : AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  device.connected ? 'Connected' : 'Offline',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: device.connected ? AppColors.success : AppColors.textHint,
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

class _FeatureToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const _FeatureToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: value ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: value ? AppColors.primary : AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
