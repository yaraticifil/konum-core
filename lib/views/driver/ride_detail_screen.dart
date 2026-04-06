import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

class RideDetailScreen extends StatelessWidget {
  const RideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Ride ride = Get.arguments as Ride;
    final config = SegmentConfig.get(ride.segment);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: const Text('Yolculuk Detayı', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card('BİLGİLER', [
              _info('Fatura No', ride.invoiceNo),
              _info('Başlangıç', ride.createdAt.toString()),
              _info('Mesafe', '${ride.distanceKm} km'),
              _info('Segment', config.label),
            ]),
            const SizedBox(height: 16),
            _card('FİNANSAL KIRILIM', [
              _financialRow('Brüt Toplam', ride.grossTotal, isBold: true),
              _financialRow('Komisyon (%12)', -ride.commission, isNeg: true),
              _financialRow('Hukuk Fonu (%4)', -ride.legalFund, isNeg: true),
              _financialRow('Denge Fonu (%3)', -ride.balanceFund, isNeg: true),
              _financialRow('KONUM Payı (%5)', -ride.platformShare, isNeg: true),
              _financialRow('E-Arşiv KDV (%20)', 0, note: 'Beyan Edildi'),
              const Divider(color: Color(0xFFFFD700)),
              _financialRow('Sürücü Net', ride.driverNet, isBold: true, isGold: true),
            ]),
            if (ride.legalHash != null) ...[
              const SizedBox(height: 16),
              _card('DİJİTAL MÜHÜR', [
                Text(ride.legalHash!, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _info(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(color: Colors.grey[500], fontSize: 12)), Text(v, style: const TextStyle(color: Colors.white, fontSize: 12))]));
  Widget _financialRow(String l, double a, {bool isBold = false, bool isNeg = false, bool isGold = false, String? note}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(color: isBold ? Colors.white : Colors.grey[400], fontSize: 12)), Text(note ?? '₺${a.toStringAsFixed(2)}', style: TextStyle(color: isGold ? const Color(0xFFFFD700) : (isNeg ? Colors.red : Colors.white), fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13))]));
}
