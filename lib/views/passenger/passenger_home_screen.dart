import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../utils/app_colors.dart';
import '../../legal/legal_texts.dart';
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
  static const Color _deepAnthracite = Color(0xFF121212);

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
          infoWindow: const InfoWindow(title: 'Bulunduğunuz Konum'),
        ));
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_pickupLocation!, 15));
      try {
        List<Placemark> pms = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (pms.isNotEmpty) {
          final p = pms.first;
          setState(() => _pickupAddress = '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}');
        }
      } catch (_) {}
    }
  }

  Future<void> _searchDest(String query) async {
    if (query.length < 3) return;
    try {
      List<Location> locs = await locationFromAddress(query);
      if (locs.isNotEmpty) {
        final loc = locs.first;
        setState(() {
          _destLocation = LatLng(loc.latitude, loc.longitude);
          _destAddress = query;
          _markers.removeWhere((m) => m.markerId.value == 'destination');
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: _destLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: _destAddress),
          ));
          _showFarePanel = true;
        });

        if (_pickupLocation != null) {
          _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                _pickupLocation!.latitude < _destLocation!.latitude ? _pickupLocation!.latitude : _destLocation!.latitude,
                _pickupLocation!.longitude < _destLocation!.longitude ? _pickupLocation!.longitude : _destLocation!.longitude,
              ),
              northeast: LatLng(
                _pickupLocation!.latitude > _destLocation!.latitude ? _pickupLocation!.latitude : _destLocation!.latitude,
                _pickupLocation!.longitude > _destLocation!.longitude ? _pickupLocation!.longitude : _destLocation!.longitude,
              ),
            ),
            80,
          ));

          pc.calculateEstimate(
            _pickupLocation!.latitude, _pickupLocation!.longitude,
            _destLocation!.latitude, _destLocation!.longitude,
          );

          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: [_pickupLocation!, _destLocation!],
            color: _monsieurGold,
            width: 4,
          ));
        }
      }
    } catch (e) {
      Get.snackbar("Hata", "Adres bulunamadı.");
    }
  }

  void _showRentalAgreement() {
    if (_pickupLocation == null || _destLocation == null || pc.fareBreakdown.value == null) return;
    final fb = pc.fareBreakdown.value!;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: _richBlack.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _monsieurGold.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: _monsieurGold.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 2),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mühürlü Başlık
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _monsieurGold.withValues(alpha: 0.3)),
                            ),
                            child: Icon(Icons.gavel_rounded, color: _monsieurGold, size: 30),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'KİRALAMA CEREMONİSİ',
                            style: GoogleFonts.spaceGrotesk(
                              color: _monsieurGold,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'TAŞIT KİRA SÖZLEŞMESİ TASDİKİ',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.grey[600],
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Rota Bilgisi
                    _ceremonySection('1. OPERASYONEL ROTA', '$_pickupAddress → $_destAddress'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _ceremonySection('2. ARAÇ SEGMENTİ', SegmentConfig.get(fb.segment).label)),
                        Expanded(child: _ceremonySection('3. TAHMİNİ SÜRE', '${fb.estimatedMinutes} Dakika')),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 40),
                    
                    // Fiyat Kırılımı
                    Text(
                      'FİNANSAL KOŞULLAR',
                      style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 15),
                    _fareRow('Açılış Bedeli', fb.openingFee),
                    _fareRow('Mesafe Bedeli', fb.distanceFee),
                    if (fb.segmentSurcharge > 0) _fareRow('Segment Farkı', fb.segmentSurcharge),
                    _fareRow('Toplam Brüt Bedel', fb.grossTotal, isBold: true, isGold: true),
                    
                    const SizedBox(height: 25),
                    
                    // Yasal Metin
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Bu kiralama işlemi, Türk Borçlar Kanunu hükümleri uyarınca dijital olarak mühürlenmektedir. Devam ederek, kiralama koşullarını ve yasal statüyü kabul etmiş sayılırsınız.',
                        style: GoogleFonts.publicSans(color: Colors.grey[500], fontSize: 10, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Aksiyonlar
                    ElevatedButton(
                      onPressed: () { Get.back(); _confirmRide(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _monsieurGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'TASDİK ET VE KİRALA',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'VAZGEÇ',
                        style: GoogleFonts.publicSans(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ceremonySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.grey[700], fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        Text(content, style: GoogleFonts.publicSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _confirmRide() {
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
          // Google Maps
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

          // Üst Çubuk
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

          // Aktif Yolculuk Paneli
          Obx(() {
            final ride = pc.currentRide.value;
            if (ride != null && ride.status != RideStatus.completed && ride.status != RideStatus.cancelled) {
              return _buildActiveRidePanel(ride);
            }
            return const SizedBox.shrink();
          }),

          // Alt Panel (Fiyat & Segment)
          if (_showFarePanel)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFarePanel()),

          // Konum Butonu
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

          // Segment Seçici
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
                        Text(
                          '×${config.multiplier}',
                          style: GoogleFonts.publicSans(
                            fontSize: 10, 
                            color: isSelected ? Colors.black54 : Colors.grey[600],
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

          // Fiyat Özeti
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
                      Text(
                        _destAddress, 
                        style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fb.distanceKm.toStringAsFixed(1)} km • ~${fb.estimatedMinutes} dakika',
                        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${fb.grossTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Buton
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: pc.isLoading.value ? null : _showRentalAgreement,
              style: ElevatedButton.styleFrom(
                backgroundColor: _monsieurGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: pc.isLoading.value
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'ONAYLA VE KİRALA',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
            )),
          ),
        ],
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
                        Text(
                          ride.driverName!,
                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          ride.driverPhone ?? '',
                          style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 13),
                        ),
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
                Text(
                  '₺${ride.grossTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontWeight: FontWeight.w900, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (ride.status == RideStatus.searching || ride.status == RideStatus.matched)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => pc.cancelRide(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'YOLCULUĞU İPTAL ET',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
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

  // ── Yardımcı widgetlar ──
  Widget _summaryRow(String label, String value, {bool isRoute = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.publicSans(color: AppColors.textDisabled, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.publicSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isRoute ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, double amount, {bool isBold = false, bool isGold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.publicSans(
              color: isBold ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}₺${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              color: isGold ? AppColors.primary : (isDiscount ? AppColors.success : Colors.white),
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
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

  static const String _darkMapStyle = '''
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
