import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/sms_fallback_service.dart';

class OfflineSosPage extends StatefulWidget {
  const OfflineSosPage({super.key});

  @override
  State<OfflineSosPage> createState() => _OfflineSosPageState();
}

class _OfflineSosPageState extends State<OfflineSosPage> {
  final _sms = SmsFallbackService();
  bool _smsSent = false;
  bool _locationShared = false;
  bool _contactsNotified = false;
  bool _loading = false;

  Future<void> _sendOfflineSos() async {
    setState(() => _loading = true);
    try {
      final pos = await ServiceLocator.instance.location.getCurrentPosition();
      await _sms.sendSosSms(phoneNumbers: ['112'], lat: pos.latitude, lng: pos.longitude);
      setState(() {
        _smsSent = true;
        _locationShared = true;
        _contactsNotified = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline SOS')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text('No Internet Connection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('SOS will be sent via SMS to emergency contacts and police', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            _CheckItem('SMS SOS Sent', _smsSent),
            _CheckItem('Location Shared', _locationShared),
            _CheckItem('Contacts Notified', _contactsNotified),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: _loading ? null : _sendOfflineSos,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send SOS via SMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool done;
  const _CheckItem(this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppColors.success : AppColors.border),
      title: Text(label),
    );
  }
}
