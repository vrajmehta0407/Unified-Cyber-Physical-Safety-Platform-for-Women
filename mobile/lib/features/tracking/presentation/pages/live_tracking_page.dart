import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  double? _lat;
  double? _lng;
  bool _loading = true;
  String? _error;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await ServiceLocator.instance.location.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _updatedAt = DateTime.now();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationUrl = _lat == null || _lng == null
        ? null
        : 'https://maps.google.com/?q=$_lat,$_lng';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLocation)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.surface,
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_error!,
                                style: const TextStyle(color: AppColors.danger),
                                textAlign: TextAlign.center),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map,
                                  size: 64, color: AppColors.primary),
                              const SizedBox(height: 16),
                              const Text('Your Current Location',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              SelectableText('$_lat, $_lng',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                              if (_updatedAt != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Updated ${_updatedAt!.hour.toString().padLeft(2, '0')}:${_updatedAt!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: AppColors.textHint, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (locationUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SelectableText(locationUrl,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ElevatedButton.icon(
                  onPressed: locationUrl == null
                      ? null
                      : () async {
                          await launchUrl(Uri.parse(locationUrl),
                              mode: LaunchMode.externalApplication);
                        },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open in Maps'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: locationUrl == null
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Share this live location: $locationUrl')),
                          );
                        },
                  icon: const Icon(Icons.share_location),
                  label: const Text('Share Live Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
