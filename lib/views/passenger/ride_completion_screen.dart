import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../legal/legal_texts.dart';
import '../../utils/app_colors.dart';
import '../../utils/brand_config.dart';

/// Ekran 2 — Yolculuk Tamamlandı · Ücret Özeti
/// Yolcu + Sürücü Ortak Görünüm
class RideCompletionScreen extends StatelessWidget {
  final Ride ride;
  const RideCompletionScreen({super.key, required this.ride});

  // Aristokrat Renk Paleti
  static Color get _monsieurGold => AppColors.primary;
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _deepAnthracite = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _richBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20), 
          onPressed: () => Get.offAllNamed('/passenger-home')
        ),
        title: Text(
          'YOLCULUK TAMAMLANDI', 
          style: GoogleFonts.spaceGrotesk(
            color: _monsieurGold, 
            fontWeight: FontWeight.w900, 
            fontSize: 14,
            letterSpacing: 2,
          )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Başarı ikonu (Aristokrat Mühür)
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.05), 
                shape: BoxShape.circle,
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'YASAL TAŞIT KİRALAMA ÖZETİ', 
              style: GoogleFonts.spaceGrotesk(
                color: Colors.grey[600], 
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )
            ),
            const SizedBox(height: 30),

            // ── ÜST BLOK: Yolculuk Bilgileri ──
            _card([
              _row('Yolculuk No', ride.invoiceNo.isNotEmpty ? ride.invoiceNo : 'OY-2026-XXXX'),
              _row('Tarih / Saat', _formatDate(ride.createdAt)),
              _routeRow(),
              _row('Gerçekleşen Mesafe', '${ride.distanceKm.toStringAsFixed(1)} km'),
              _row('Gerçekleşen Süre', '${ride.estimatedMinutes} dk'),
              _row('Araç Segmenti', SegmentConfig.get(ride.segment).label),
            ]),
            const SizedBox(height: 16),

            // ── ÜCRET KIRILIMI ──
            _card([
              _sectionHeader('ÜCRET KIRILIMI'),
              const SizedBox(height: 15),
              _fareRow('Açılış Bedeli', ride.openingFee),
              _fareRow('Mesafe Bedeli', ride.distanceFee),
              if (ride.segmentSurcharge > 0) _fareRow('Segment Farkı', ride.segmentSurcharge),
              if (ride.marketAdjustment > 0) _fareRow('Piyasa Ayarı', ride.marketAdjustment),
              if (ride.discount > 0) _fareRow('İndirim', -ride.discount, isDiscount: true),
              const Divider(color: Colors.white10, height: 30),
              _fareRow('KESİNLEŞEN TOPLAM BEDEL', ride.grossTotal, isBold: true),
            ]),
            const SizedBox(height: 16),


            // ── E-FATURA / E-BELGE ──
            _card([
              _sectionHeader('E-FATURA / E-BELGE'),
              const SizedBox(height: 10),
              _row('Belge Tipi', 'Bilgilendirme Ekranı (Demo)'),
              _row('Belge No', ride.invoiceNo.isNotEmpty ? ride.invoiceNo : 'DEMO-XXXX'),
              _row('Belge Tarihi', _formatDate(ride.completedAt ?? ride.createdAt)),
              const SizedBox(height: 8),
              _row('Not', LegalTexts.passengerInvoiceInfo),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.snackbar("Bilgi", "E-fatura indirme henüz entegre edilmedi."),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('İndir', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _monsieurGold,
                        side: BorderSide(color: _monsieurGold.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.snackbar("Bilgi", "QR doğrulama henüz entegre edilmedi."),
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('QR Doğrula', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[400],
                        side: BorderSide(color: Colors.grey[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            // Ana ekrana dön
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed('/passenger-home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _monsieurGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text(
                  'ANA EKRANA DÖN', 
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(String text) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: _monsieurGold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(
          text, 
          style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(width: 10),
          Flexible(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _routeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rota', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 8),
              const SizedBox(width: 6),
              Expanded(child: Text(ride.pickupAddress, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(width: 1, height: 14, color: Colors.grey[600]),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 8),
              const SizedBox(width: 6),
              Expanded(child: Text(ride.destAddress, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, double amount, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: GoogleFonts.publicSans(
            color: isBold ? Colors.white : Colors.grey[500],
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ))),
          Text(
            '${isDiscount ? "-" : ""}₺${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              color: isDiscount ? Colors.greenAccent : (isBold ? _monsieurGold : Colors.white),
              fontSize: isBold ? 20 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
