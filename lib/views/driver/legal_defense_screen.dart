import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ride_model.dart';

class LegalDefenseScreen extends StatelessWidget {
  const LegalDefenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Ride? ride = Get.arguments is Ride ? Get.arguments as Ride : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('DENETİM MODU', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BU ARAÇ T.C. BORÇLAR KANUNU MADDE 299 UYARINCA TAHSİS EDİLMİŞTİR.',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              '5070 SAYILI KANUN: Dijital imza ve mühür yasaldır.',
              style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _line('Sürücü', ride?.driverName ?? '-'),
            _line('Yolcu', ride?.passengerId ?? '-'),
            _line('Plaka', '34 KONUM 299'),
            _line('Planlanan Alım', _fmt(ride?.scheduledPickupTime ?? ride?.createdAt)),
            _line('Legal Hash', ride?.legalHash.isNotEmpty == true ? ride!.legalHash : 'Üretilecek'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                final url = ride?.invoiceUrl.isNotEmpty == true ? ride!.invoiceUrl : 'https://invoice.konum.app/e-arsiv/mock';
                Get.defaultDialog(title: 'E-Arşiv', middleText: url);
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('E-ARŞİV FATURA LİNKİ'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), side: const BorderSide(color: Colors.white)),
              onPressed: () => Get.defaultDialog(
                title: 'Hukuk Merkezi (Avukat)',
                middleText: '+90 850 000 29 90',
              ),
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('Hukuk Merkezi (Avukat)', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '$k: ', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              TextSpan(text: v, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

  String _fmt(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
