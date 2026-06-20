import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

// Dark map style matching safety_map_page
const _kMapStyle = '''
[
  {"featureType":"all","elementType":"labels.text.fill","stylers":[{"color":"#7c93a3"},{"lightness":"-10"}]},
  {"featureType":"administrative.country","elementType":"geometry","stylers":[{"visibility":"on"}]},
  {"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#a0a4a5"}]},
  {"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#62838e"}]},
  {"featureType":"landscape","elementType":"geometry.fill","stylers":[{"color":"#1a1a2e"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#16213e"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#23232e"},{"weight":"1"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#0f3460"},{"lightness":"10"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1a1a2e"}]},
  {"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#0f3460"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1a1a2e"}]},
  {"featureType":"poi","elementType":"geometry.fill","stylers":[{"color":"#1a1a2e"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#0d0d0d"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#0a0a1a"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}
]
''';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  double? _lat;
  double? _lng;
  bool _loading = true;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fetchLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() { _loading = true; });
    try {
      final pos = await ServiceLocator.instance.location.getCurrentPosition();
      _lat = pos.latitude;
      _lng = pos.longitude;
    } catch (e) {
      _lat = 23.0225;
      _lng = 72.5714;
    }
    _buildMapOverlays();
    if (_mapController != null && _lat != null && _lng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_lat!, _lng!), 15.5),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  void _buildMapOverlays() {
    if (_lat == null || _lng == null) return;
    final userPos = LatLng(_lat!, _lng!);
    _markers = {
      Marker(
        markerId: const MarkerId('user_location'),
        position: userPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    };
    _circles = {
      Circle(
        circleId: const CircleId('user_accuracy'),
        center: userPos,
        radius: 80,
        fillColor: AppColors.primary.withOpacity(0.12),
        strokeColor: AppColors.primary.withOpacity(0.4),
        strokeWidth: 2,
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    controller.setMapStyle(_kMapStyle);
    if (_lat != null && _lng != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_lat!, _lng!), 15.5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationUrl = _lat == null || _lng == null
        ? null
        : 'https://maps.google.com/?q=$_lat,$_lng';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          // Live Google Map
          Expanded(
            child: Stack(
              children: [
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_lat ?? 23.0225, _lng ?? 72.5714),
                          zoom: 15.5,
                        ),
                        markers: _markers,
                        circles: _circles,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                // User info card at top
                if (!_loading)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _buildUserCard(),
                  ),
                // "I Am Safe" floating button
                if (!_loading)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: _buildIAmSafeButton(context),
                  ),
              ],
            ),
          ),
          _buildBottomPanel(context, locationUrl),
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
              Text('Live Tracking',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: _fetchLocation,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIAmSafeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Confirm Safety',
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            content: Text('Are you safe? This will stop location sharing and notify your guardians.',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ You are safe! Guardians have been notified.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('I Am Safe', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text("I'm Safe", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ananya Sharma',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                if (_lat != null)
                  Text('${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('Live Now', style: GoogleFonts.outfit(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, String? locationUrl) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maninagar, Ahmedabad',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                    Text('Gujarat, India', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Accuracy', style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 10)),
                  Text('10m', style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: locationUrl == null
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: locationUrl!));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('📍 Live location link copied to clipboard!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_location_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Share Live Location',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
