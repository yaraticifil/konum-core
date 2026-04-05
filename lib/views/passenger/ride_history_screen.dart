import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../utils/app_colors.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final AuthController authController = Get.find<AuthController>();
  final PassengerController pc = Get.find<PassengerController>();

  // Aristokrat Renk Paleti
  static Color get _monsieurGold => AppColors.primary;
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _deepAnthracite = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    if (authController.user != null) {
      pc.fetchRideHistory(authController.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _richBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), 
          onPressed: () => Get.back()
        ),
        title: Text(
          'YOLCULUK GEÇMİŞİ', 
          style: GoogleFonts.spaceGrotesk(
            color: _monsieurGold, 
            fontWeight: FontWeight.w900, 
            fontSize: 14,
            letterSpacing: 2,
          )
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (pc.rideHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car_outlined, color: Colors.grey[900], size: 60),
                const SizedBox(height: 16),
                Text(
                  'Henüz yolculuk kaydınız bulunmuyor.', 
                  style: GoogleFonts.publicSans(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pc.rideHistory.length,
          itemBuilder: (context, index) {
            final ride = pc.rideHistory[index];
            return _rideCard(ride);
          },
        );
      }),
    );
  }

  Widget _rideCard(Ride ride) {
    final config = SegmentConfig.get(ride.segment);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: tarih + durum + segment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride.createdAt.day.toString().padLeft(2, '0')}.${ride.createdAt.month.toString().padLeft(2, '0')}.${ride.createdAt.year} | ${ride.createdAt.hour.toString().padLeft(2, '0')}:${ride.createdAt.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.publicSans(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _monsieurGold.withValues(alpha: 0.1), 
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _monsieurGold.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      '${config.icon} ${config.label}'.toUpperCase(), 
                      style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)
                    ),
                  ),
                  const SizedBox(width: 6),
                  _statusBadge(ride.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rota
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
              const SizedBox(width: 10),
              Expanded(child: Text(ride.pickupAddress, style: GoogleFonts.publicSans(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(width: 1, height: 12, color: Colors.white10),
          ),
          Row(
            children: [
              Icon(Icons.location_on, color: _monsieurGold, size: 8),
              const SizedBox(width: 10),
              Expanded(child: Text(ride.destAddress, style: GoogleFonts.publicSans(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Divider(color: Colors.white10, height: 25),

          // Bilgiler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo('Mesafe', '${ride.distanceKm.toStringAsFixed(1)} km'),
              _miniInfo('Fiyat', '₺${ride.grossTotal.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value, 
          style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontSize: 14, fontWeight: FontWeight.w900)
        ),
        Text(
          label.toUpperCase(), 
          style: GoogleFonts.spaceGrotesk(color: Colors.grey[700], fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
      ],
    );
  }

  Widget _statusBadge(RideStatus status) {
    Color color;
    String text;
    switch (status) {
      case RideStatus.completed:
        color = Colors.green; text = 'Tamamlandı'; break;
      case RideStatus.cancelled:
        color = Colors.red; text = 'İptal'; break;
      case RideStatus.inProgress:
        color = Colors.blue; text = 'Devam'; break;
      default:
        color = Colors.orange; text = 'Bekliyor'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Text(
        text.toUpperCase(), 
        style: GoogleFonts.spaceGrotesk(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)
      ),
    );
  }
}
