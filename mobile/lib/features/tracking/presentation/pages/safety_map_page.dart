import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Map dark style JSON ───
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

// ─── Ahmedabad Center ───
const _kAhmedabadCenter = LatLng(23.0225, 72.5714);

// ─── Safe Zone data ───
const _kSafeZones = [
  _ZonePoint(id: 'ps1', name: 'Ahmedabad City Police HQ', type: ZoneType.police, lat: 23.0300, lng: 72.5876),
  _ZonePoint(id: 'ps2', name: 'Navrangpura Police Station', type: ZoneType.police, lat: 23.0390, lng: 72.5580),
  _ZonePoint(id: 'ps3', name: 'Cyber Crime Cell Ahmedabad', type: ZoneType.police, lat: 23.0225, lng: 72.5714),
  _ZonePoint(id: 'ps4', name: 'Maninagar Police Station', type: ZoneType.police, lat: 22.9966, lng: 72.6003),
  _ZonePoint(id: 'h1', name: 'Civil Hospital Ahmedabad', type: ZoneType.hospital, lat: 23.0400, lng: 72.5828),
  _ZonePoint(id: 'h2', name: 'VS General Hospital', type: ZoneType.hospital, lat: 23.0285, lng: 72.5870),
  _ZonePoint(id: 'h3', name: 'Sterling Hospital', type: ZoneType.hospital, lat: 23.0550, lng: 72.5325),
  _ZonePoint(id: 'w1', name: 'Abhayam Women Helpline 181', type: ZoneType.women, lat: 23.0350, lng: 72.5900),
  _ZonePoint(id: 'w2', name: 'Sakhi One Stop Centre', type: ZoneType.women, lat: 23.0360, lng: 72.5895),
];

// ─── Incident heat data ───
const _kIncidents = [
  _HeatPoint(lat: 23.0150, lng: 72.5800, severity: 'high', category: 'Online Fraud'),
  _HeatPoint(lat: 23.0560, lng: 72.5350, severity: 'medium', category: 'Cyberstalking'),
  _HeatPoint(lat: 22.9950, lng: 72.6100, severity: 'medium', category: 'Financial Fraud'),
  _HeatPoint(lat: 23.0700, lng: 72.5200, severity: 'low', category: 'Phishing'),
  _HeatPoint(lat: 23.0250, lng: 72.6200, severity: 'high', category: 'SIM Swap'),
];

enum ZoneType { police, hospital, women, fire }
enum MapLayer { all, safeZones, caution, danger }

class SafetyMapPage extends StatefulWidget {
  const SafetyMapPage({super.key});

  @override
  State<SafetyMapPage> createState() => _SafetyMapPageState();
}

class _SafetyMapPageState extends State<SafetyMapPage> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  MapLayer _activeLayer = MapLayer.all;
  bool _loadingLocation = false;
  _ZonePoint? _selectedZone;
  late DraggableScrollableController _sheetController;
  bool _routeMode = false;
  final TextEditingController _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _buildOverlays();
    _goToUserLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _sheetController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _buildOverlays() {
    final markers = <Marker>{};
    final circles = <Circle>{};

    for (final z in _kSafeZones) {
      if (_activeLayer == MapLayer.caution || _activeLayer == MapLayer.danger) continue;

      final color = switch (z.type) {
        ZoneType.police => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ZoneType.hospital => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ZoneType.women => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ZoneType.fire => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      };

      markers.add(Marker(
        markerId: MarkerId(z.id),
        position: LatLng(z.lat, z.lng),
        icon: color,
        infoWindow: InfoWindow(title: z.name, snippet: z.type.label),
        onTap: () => setState(() => _selectedZone = z),
      ));
    }

    if (_activeLayer == MapLayer.all || _activeLayer == MapLayer.caution || _activeLayer == MapLayer.danger) {
      for (final inc in _kIncidents) {
        final (fillColor, strokeColor) = switch (inc.severity) {
          'high' => (const Color(0x33FF4545), const Color(0x88FF4545)),
          'medium' => (const Color(0x33FFB547), const Color(0x88FFB547)),
          _ => (const Color(0x2200E5A0), const Color(0x6600E5A0)),
        };
        circles.add(Circle(
          circleId: CircleId('inc_${inc.lat}_${inc.lng}'),
          center: LatLng(inc.lat, inc.lng),
          radius: 400,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: 1,
        ));
      }
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  Future<void> _goToUserLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(pos.latitude, pos.longitude),
        14,
      ));
    } catch (_) {
      // Fallback to Ahmedabad center
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_kAhmedabadCenter, 12));
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _mapController = ctrl;
    ctrl.setMapStyle(_kMapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Map ───
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kAhmedabadCenter,
              zoom: 12,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            style: _kMapStyle,
          ),

          // ─── AppBar overlay ───
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _MapBtn(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '🛡️  Safety Map — Ahmedabad',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Layer chips ───
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: MapLayer.values.map((layer) {
                    final active = _activeLayer == layer;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _activeLayer = layer);
                        _buildOverlays();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? layer.color.withOpacity(0.9)
                              : AppColors.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: active ? layer.color : AppColors.border),
                        ),
                        child: Text(
                          '${layer.emoji} ${layer.label}',
                          style: GoogleFonts.inter(
                            color: active ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ─── Legend ───
          Positioned(
            top: 130,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(color: Colors.blue, label: 'Police'),
                  const SizedBox(height: 6),
                  _LegendItem(color: Colors.green, label: 'Hospital'),
                  const SizedBox(height: 6),
                  _LegendItem(color: Colors.pink, label: 'Women Help'),
                  const SizedBox(height: 6),
                  _LegendItem(color: Colors.red.withOpacity(0.6), label: 'High Risk', isDot: false),
                  const SizedBox(height: 6),
                  _LegendItem(color: Colors.orange.withOpacity(0.5), label: 'Caution', isDot: false),
                ],
              ),
            ),
          ),

          // ─── FABs ───
          Positioned(
            right: 12,
            bottom: 280,
            child: Column(
              children: [
                _MapBtn(
                  icon: _loadingLocation ? Icons.hourglass_empty : Icons.my_location,
                  onTap: _goToUserLocation,
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.sos,
                  color: AppColors.danger,
                  onTap: () => context.push('/sos'),
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.report,
                  color: AppColors.warning,
                  onTap: () => _showMarkUnsafeDialog(context),
                ),
              ],
            ),
          ),

          // ─── Bottom sheet ───
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.2,
            minChildSize: 0.15,
            maxChildSize: 0.55,
            builder: (ctx, scroll) => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedZone != null ? '📍 ${_selectedZone!.name}' : '🗺️ Plan Safe Route',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (_selectedZone != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _selectedZone!.type.label,
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.directions, size: 16),
                            label: const Text('Navigate'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call, size: 16),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => setState(() => _selectedZone = null),
                          icon: const Icon(Icons.close, size: 18),
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _destController,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Where do you want to go?',
                        hintStyle: GoogleFonts.inter(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['Safest', 'Fastest', 'Balanced'].map((opt) {
                        final active = opt == 'Safest';
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: active ? AppColors.primary.withOpacity(0.15) : AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active ? AppColors.primary.withOpacity(0.5) : AppColors.border,
                                ),
                              ),
                              child: Text(
                                opt,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: active ? AppColors.primary : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shield, size: 18),
                        label: const Text('Plan Safe Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Quick safe spots
                  Text(
                    'NEAREST SAFE SPOTS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._kSafeZones.take(3).map((z) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: z.type.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(z.type.emoji, style: const TextStyle(fontSize: 18))),
                    ),
                    title: Text(z.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: Text(z.type.label, style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 11)),
                    trailing: const Icon(Icons.directions, color: AppColors.primary, size: 18),
                    onTap: () {
                      setState(() => _selectedZone = z);
                      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(z.lat, z.lng), 15));
                    },
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkUnsafeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚠️ Mark Unsafe Spot', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            ...['Unsafe Area', 'Harassment Reported', 'Suspicious Activity', 'Poor Lighting'].map((cat) =>
              ListTile(
                leading: const Icon(Icons.report_gmailerrorred, color: AppColors.warning),
                title: Text(cat, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📍 Report submitted. Community will be alerted after 3 confirmations.'),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ───

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _MapBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color?.withOpacity(0.4) ?? AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
        ),
        child: Icon(icon, color: color != null ? Colors.white : AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDot;
  const _LegendItem({required this.color, required this.label, this.isDot = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isDot
            ? Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color))
            : Container(width: 16, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: color)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ─── Data models ───

class _ZonePoint {
  final String id;
  final String name;
  final ZoneType type;
  final double lat;
  final double lng;
  const _ZonePoint({required this.id, required this.name, required this.type, required this.lat, required this.lng});
}

class _HeatPoint {
  final double lat;
  final double lng;
  final String severity;
  final String category;
  const _HeatPoint({required this.lat, required this.lng, required this.severity, required this.category});
}

extension on ZoneType {
  String get label => switch (this) {
    ZoneType.police => 'Police Station',
    ZoneType.hospital => 'Hospital',
    ZoneType.women => 'Women Help Center',
    ZoneType.fire => 'Fire Station',
  };

  String get emoji => switch (this) {
    ZoneType.police => '👮',
    ZoneType.hospital => '🏥',
    ZoneType.women => '🤝',
    ZoneType.fire => '🚒',
  };

  Color get color => switch (this) {
    ZoneType.police => Colors.blue,
    ZoneType.hospital => Colors.green,
    ZoneType.women => Colors.pink,
    ZoneType.fire => Colors.orange,
  };
}

extension on MapLayer {
  String get label => switch (this) {
    MapLayer.all => 'All',
    MapLayer.safeZones => 'Safe Zones',
    MapLayer.caution => 'Caution',
    MapLayer.danger => 'Danger',
  };

  String get emoji => switch (this) {
    MapLayer.all => '🗺️',
    MapLayer.safeZones => '🟢',
    MapLayer.caution => '🟡',
    MapLayer.danger => '🔴',
  };

  Color get color => switch (this) {
    MapLayer.all => AppColors.primary,
    MapLayer.safeZones => AppColors.success,
    MapLayer.caution => AppColors.warning,
    MapLayer.danger => AppColors.danger,
  };
}
