import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/driver_controller.dart';
import '../../utils/brand_config.dart';

class LegalDefenseScreen extends StatelessWidget {
  const LegalDefenseScreen({super.key});

  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _emergencyRed = Color(0xFFD32F2F);
  static const Color _legalGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final driverController = Get.find<DriverController>();
    final ride = driverController.currentRide.value;

    return Scaffold(
      backgroundColor: _richBlack,
      appBar: AppBar(
        backgroundColor: _emergencyRed,
        title: Text(
          'DENETİM MODU: MÜDAHALE ETMEYİN',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningHeader(),
            const SizedBox(height: 30),
            _buildLegalBase(),
            const SizedBox(height: 30),
            if (ride != null) _buildContractSummary(ride) else _buildNoActiveRide(),
            const SizedBox(height: 30),
            _buildOfficialNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _emergencyRed.withValues(alpha: 0.1),
        border: Border.all(color: _emergencyRed, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(Icons.gavel_rounded, color: _emergencyRed, size: 50),
          const SizedBox(height: 15),
          Text(
            'HUKUKİ DOKUNULMAZLIK BİLDİRİMİ',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(color: _emergencyRed, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Bu araç ${BrandConfig.current.appName} üzerinden şoförlü olarak tahsis edilmiştir.',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalBase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legalItem('YASAL DAYANAK 1:', '6098 Sayılı TBK Madde 299 (Kira Akdi)'),
        _legalItem('YASAL DAYANAK 2:', '5070 Sayılı Elektronik İmza Kanunu'),
        _legalItem('YASAL DAYANAK 3:', 'U-ETDS Kayıtlı Sefer Bildirimi'),
      ],
    );
  }

  Widget _legalItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: _legalGold, size: 18),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.spaceGrotesk(color: _legalGold, fontWeight: FontWeight.bold, fontSize: 10)),
              Text(desc, style: GoogleFonts.publicSans(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractSummary(dynamic ride) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AKTİF KİRA ÖZETİ', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(color: Colors.white10, height: 25),
          _summaryRow('SÖZLEŞME NO', ride.invoiceNo),
          _summaryRow('KİRACI ID', ride.passengerId.substring(0, 8).toUpperCase()),
          _summaryRow('BAŞLANGIÇ', DateFormat('HH:mm').format(ride.createdAt)),
          _summaryRow('GÜZERGAH', '${ride.pickupAddress.split(',')[0]} -> ${ride.destAddress.split(',')[0]}'),
        ],
      ),
    );
  }

  Widget _buildNoActiveRide() {
    return Center(
      child: Text(
        'Şu an aktif bir kira sözleşmesi bulunmamaktadır.',
        style: GoogleFonts.publicSans(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.publicSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOfficialNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        'SAYIN MEMUR; bu araç ticari taksi faaliyeti yürütmemektedir. Araç, Türk Borçlar Kanunu uyarınca şoförlü araç kiralama (tahsis) hizmeti için rezerve edilmiştir. Dijital kira sözleşmesi yukarıda sunulmuştur. Lütfen 5070 Sayılı Kanun kapsamındaki dijital imzalı belgeleri dikkate alınız.',
        style: GoogleFonts.publicSans(color: Colors.grey[400], fontSize: 11, height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
