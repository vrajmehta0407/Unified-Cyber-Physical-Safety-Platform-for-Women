import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() { _loading = true; _error = null; });
    try {
      final pos = await ServiceLocator.instance.location.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLocation)],
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
                        ? Text(_error!, style: const TextStyle(color: AppColors.danger))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map, size: 64, color: AppColors.primary),
                              const SizedBox(height: 16),
                              const Text('Your Current Location'),
                              Text('📍 $_lat, $_lng', style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _lat == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Location shared: $_lat, $_lng')),
                        );
                      },
                icon: const Icon(Icons.share_location),
                label: const Text('Share Live Location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
