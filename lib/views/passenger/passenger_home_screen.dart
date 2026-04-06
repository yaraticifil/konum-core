import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/brand_config.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final PassengerController pc = Get.find<PassengerController>();

  GoogleMapController? _mapController;
  final TextEditingController _destController = TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _destLocation;
  String _pickupAddress = 'Konumunuz alınıyor...';
  String _destAddress = '';
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _showFarePanel = false;

  // Aristokrat Renk Paleti
  static Color get _monsieurGold => AppColors.primary;
  static const Color _richBlack = Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    _initLocation();
    if (authController.user != null) {
      pc.checkActiveRide(authController.user!.uid);
    }
  }

  Future<void> _initLocation() async {
    final position = await pc.getCurrentLocation();
    if (position != null) {
      setState(() {
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      });
      // Mock address for now since getAddressFromLatLng is missing
      _pickupAddress = "Mevcut Konum";
      if (mounted) setState(() {});
    }
  }

  Future<void> _searchDest(String query) async {
    if (query.isEmpty) return;
    // Mock destination search
    setState(() {
      _destLocation = LatLng(_pickupLocation!.latitude + 0.01, _pickupLocation!.longitude + 0.01);
      _destAddress = query;
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      _showFarePanel = true;
    });
    _drawRoute();
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(min(_pickupLocation!.latitude, _destLocation!.latitude), min(_pickupLocation!.longitude, _destLocation!.longitude)),
        northeast: LatLng(max(_pickupLocation!.latitude, _destLocation!.latitude), max(_pickupLocation!.longitude, _destLocation!.longitude)),
      ),
      100,
    ));
    pc.calculateEstimate(_pickupLocation!.latitude, _pickupLocation!.longitude, _destLocation!.latitude, _destLocation!.longitude);
  }

  void _drawRoute() {
    if (_pickupLocation == null || _destLocation == null) return;
    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [_pickupLocation!, _destLocation!],
        color: _monsieurGold,
        width: 5,
      ));
    });
  }

  void _showRentalAgreement() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: _richBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KİRALAMA VE TAHSİS SÖZLEŞMESİ', style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              "TBK Madde 299 uyarınca şoförlü araç kiralama hizmeti almaktasınız. "
              "Bu işlem bir taksi faaliyeti değil, 5070 Sayılı Kanun uyarınca dijital mühürlenmiş bir özel tahsis sözleşmesidir. "
              "Onaylayarak şartları kabul etmiş sayılırsınız.",
              style: GoogleFonts.publicSans(color: Colors.grey[400], fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('İPTAL'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _confirmRide();
                    },
                    child: const Text('ONAYLIYORUM'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRide() {
    if (authController.user == null) return;
    pc.requestRide(
      passengerId: authController.user!.uid,
      pickupLat: _pickupLocation!.latitude,
      pickupLng: _pickupLocation!.longitude,
      pickupAddress: _pickupAddress,
      destLat: _destLocation!.latitude,
      destLng: _destLocation!.longitude,
      destAddress: _destAddress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLocation ?? const LatLng(41.0082, 28.9784),
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: _darkMapStyle,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 15),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),
          Obx(() {
            final ride = pc.currentRide.value;
            if (ride != null && ride.status != RideStatus.completed && ride.status != RideStatus.cancelled) {
              return _buildActiveRidePanel(ride);
            }
            return const SizedBox.shrink();
          }),
          if (_showFarePanel)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFarePanel()),
          Positioned(
            bottom: _showFarePanel ? 320 : 30,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.cardBg,
              onPressed: _initLocation,
              child: Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _monsieurGold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.handshake_rounded, color: _monsieurGold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    BrandConfig.current.appName.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      color: _monsieurGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            _topBtn(Icons.history_rounded, () => Get.toNamed('/ride-history')),
            const SizedBox(width: 10),
            _topBtn(Icons.sos_rounded, () => authController.launchEmergencySupport()),
          ],
        ),
      ],
    );
  }

  Widget _topBtn(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: Colors.grey[400], size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              _searchRow(Icons.my_location_rounded, Colors.greenAccent, _pickupAddress, isReadOnly: true),
              const Divider(color: Colors.white10, height: 1),
              _searchRow(
                Icons.location_on_rounded, 
                _monsieurGold, 
                'Nereye gitmek istiyorsun?',
                controller: _destController,
                onSubmitted: _searchDest,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchRow(IconData icon, Color iconColor, String hint, {bool isReadOnly = false, TextEditingController? controller, Function(String)? onSubmitted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: isReadOnly 
                ? Text(hint, style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 14), overflow: TextOverflow.ellipsis)
                : TextField(
                    controller: controller,
                    style: GoogleFonts.publicSans(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.publicSans(color: AppColors.textDisabled),
                      border: InputBorder.none,
                    ),
                    onSubmitted: onSubmitted,
                  ),
          ),
          if (!isReadOnly)
            IconButton(
              icon: Icon(Icons.search_rounded, color: AppColors.primary),
              onPressed: () => onSubmitted?.call(controller?.text ?? ''),
            ),
        ],
      ),
    );
  }

  Widget _buildFarePanel() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _richBlack.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: _monsieurGold.withValues(alpha: 0.3))),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30, offset: const Offset(0, -10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Obx(() => Row(
                children: VehicleSegment.values.map((seg) {
                  final config = SegmentConfig.get(seg);
                  final isSelected = pc.selectedSegment.value == seg;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => pc.setSegment(seg),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? _monsieurGold : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? _monsieurGold : Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          children: [
                            Text(config.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(
                              config.label,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: 20),
              Obx(() {
                final fb = pc.fareBreakdown.value;
                if (fb == null) return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_destAddress, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${fb.distanceKm.toStringAsFixed(1)} km • ~${fb.estimatedMinutes} dk', style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('₺${fb.grossTotal.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900)),
                  ],
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: pc.isLoading.value ? null : _showRentalAgreement,
                  child: pc.isLoading.value
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('ONAYLA VE KİRALA'),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRidePanel(Ride ride) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _richBlack.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: _statusColor(ride.status).withValues(alpha: 0.5))),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30, offset: const Offset(0, -10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _statusColor(ride.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _statusColor(ride.status).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_statusIcon(ride.status), color: _statusColor(ride.status), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        ride.statusText.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(color: _statusColor(ride.status), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (ride.driverName != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ride.driverName!, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                            Text(ride.driverPhone ?? '', style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (ride.driverPhone != null)
                        _actionBtn(Icons.phone_rounded, Colors.green, () async => await launchUrl(Uri.parse('tel:${ride.driverPhone}'))),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kiralama Bedeli', style: GoogleFonts.publicSans(color: Colors.grey[600], fontSize: 14)),
                    Text('₺${ride.grossTotal.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontWeight: FontWeight.w900, fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 24),
                if (ride.status == RideStatus.searching || ride.status == RideStatus.matched)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => pc.cancelRide(),
                      child: const Text('YOLCULUĞU İPTAL ET'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Color _statusColor(RideStatus s) {
    switch (s) {
      case RideStatus.searching: return _monsieurGold;
      case RideStatus.matched: case RideStatus.driverArriving: return Colors.blueAccent;
      case RideStatus.inProgress: case RideStatus.completed: return Colors.greenAccent;
      case RideStatus.cancelled: return Colors.redAccent;
    }
  }

  IconData _statusIcon(RideStatus s) {
    switch (s) {
      case RideStatus.searching: return Icons.radar_rounded;
      case RideStatus.matched: return Icons.check_circle_rounded;
      case RideStatus.driverArriving: return Icons.directions_car_rounded;
      case RideStatus.inProgress: return Icons.navigation_rounded;
      case RideStatus.completed: return Icons.flag_rounded;
      case RideStatus.cancelled: return Icons.cancel_rounded;
    }
  }

  String get _darkMapStyle => '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''';
}
