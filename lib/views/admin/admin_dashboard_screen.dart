import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/driver_model.dart';
import '../../utils/app_colors.dart';
import '../../services/app_notifier.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final AdminController adminController = Get.find<AdminController>();

  final Completer<GoogleMapController> _mapController = Completer();
  
  // Aristokrat Renk Paleti
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _deepAnthracite = Color(0xFF121212);
  static const Color _monsieurGold = Color(0xFFD4AF37);
  static const Color _bronzeAccent = Color(0xFFCD7F32);
  static const Color _alertRed = Color(0xFFE74C3C);

  // Istanbul / Center Map
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(41.0082, 28.9784), // Istanbul default
    zoom: 11.5,
  );

  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [{"color": "#181818"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#3c3c3c"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    if (authController.userRole.value != 'admin') {
      AppNotifier.snackbar(
        'KRİTİK UYARI',
        'Strateji Odasına giriş yetkiniz bulunmamaktadır.',
        backgroundColor: _alertRed,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed('/role-selection');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _richBlack,
      extendBodyBehindAppBar: true,
      appBar: _buildCommandAppBar(),
      body: Stack(
        children: [
          // 1. Katman: Canlı Operasyon Haritası
          _buildLiveOperationsMap(),
          
          // 2. Katman: Glassmorphism Strateji Odası / Paneller
          _buildDraggableStrategyPanel(),
        ],
      ),
    );
  }

  AppBar _buildCommandAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.satellite_alt_rounded, color: _monsieurGold, size: 20),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(
                'DİJİTAL HAREKAT MERKEZİ',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  color: _monsieurGold,
                  letterSpacing: 2.5,
                  fontSize: 14,
                ),
              ),
              Text(
                'CANLI OPERASYON RADARI',
                style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 1.5,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app_rounded, color: _alertRed),
          onPressed: () => authController.logout(),
        ),
      ],
    );
  }

  Widget _buildLiveOperationsMap() {
    return StreamBuilder<QuerySnapshot>(
      // Yalnızca aktif 'konum_app' araçlarını canlı çekiyoruz
      stream: FirebaseFirestore.instance
          .collection('driver_locations')
          .where('isOnline', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        Set<Marker> markers = {};

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final lat = (data['lat'] ?? 0).toDouble();
            final lng = (data['lng'] ?? 0).toDouble();

            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange), // Gold'a yakın
                infoWindow: InfoWindow(title: data['name'] ?? 'AKTİF ARAÇ'),
              ),
            );
          }
        }

        return GoogleMap(
          initialCameraPosition: _initialCamera,
          onMapCreated: (controller) {
            controller.setMapStyle(_darkMapStyle);
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
          markers: markers,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        );
      },
    );
  }

  Widget _buildDraggableStrategyPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.15,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: _richBlack.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(top: BorderSide(color: _monsieurGold.withValues(alpha: 0.3), width: 1)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sürükleme Çubuğu
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    _buildSectionTitle('FİNANSAL MONİTÖR', Icons.account_balance_rounded),
                    const SizedBox(height: 15),
                    _buildFinancialMonitor(),

                    const SizedBox(height: 30),
                    _buildSectionTitle('OPERASYONEL OTORİTE (THE GAVEL)', Icons.gavel_rounded),
                    const SizedBox(height: 15),
                    _buildDriverAuthorityList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _monsieurGold, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialMonitor() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _monsieurGold.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFinanceStat('TOPLAM CİRO', '₺${adminController.totalGrossRevenue.toStringAsFixed(0)}', Colors.white),
                _buildFinanceStat('KOMİSYON', '₺${adminController.totalCommission.toStringAsFixed(0)}', _monsieurGold),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Divider(color: Colors.white.withValues(alpha: 0.1)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFinanceStat('DEVLET VERGİSİ (KDV+STOPAJ)', '- ₺${adminController.totalTaxDeduction.toStringAsFixed(0)}', _alertRed),
                _buildFinanceStat('PLATFORM NET KAR', '₺${adminController.totalNetProfit.toStringAsFixed(0)}', Colors.greenAccent),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFinanceStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 9,
            color: Colors.grey[500],
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverAuthorityList() {
    return Obx(() {
      final drivers = adminController.drivers;
      if (drivers.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Sistemde sürücü bulunmuyor.', style: TextStyle(color: Colors.white54)),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                // Profil Sembolü
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _monsieurGold.withValues(alpha: 0.5)),
                  ),
                  child: const Center(child: Icon(Icons.person, color: _monsieurGold, size: 20)),
                ),
                const SizedBox(width: 15),
                
                // Kimlik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name.toUpperCase(),
                        style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'KN-${driver.id.substring(0, 5).toUpperCase()} | Durum: ${driver.status.name.toUpperCase()}',
                        style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                
                // ASKIYA AL (The Gavel) Butonu
                if (driver.status != DriverStatus.suspended)
                  InkWell(
                    onTap: () {
                      _showGavelDialog(driver.id, driver.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _alertRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _alertRed.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.block_rounded, color: _alertRed, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'ASKIYA AL',
                            style: GoogleFonts.spaceGrotesk(
                              color: _alertRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Kurtar (Unsuspend)
                   InkWell(
                    onTap: () {
                      adminController.updateDriverStatus(driver.id, DriverStatus.approved);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'YETKİ VER',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showGavelDialog(String driverId, String driverName) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _richBlack.withValues(alpha: 0.9),
                border: Border.all(color: _alertRed.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gavel_rounded, color: _alertRed, size: 50),
                  const SizedBox(height: 15),
                  Text(
                    'İHRAÇ VE ASKIYA ALMA',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Kurucu yetkilerinizi kullanarak "$driverName" isimli sürücünün KONUM ağına erişimini derhal kesmek üzeresiniz. Bu işlem yasal ihlal ve şikayetlerde kullanılır.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.publicSans(color: Colors.grey[400], fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('İPTAL', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _alertRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            adminController.updateDriverStatus(driverId, DriverStatus.suspended);
                            Get.back();
                            AppNotifier.snackbar(
                              'OTORİTE KULLANILDI',
                              'Sürücü $driverName sistemden başarıyla atıldı.',
                              backgroundColor: _monsieurGold,
                              colorText: _richBlack,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Text('MÜDAHALE ET', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
