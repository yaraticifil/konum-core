import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/brand_config.dart';

class LegalContractScreen extends StatelessWidget {
  const LegalContractScreen({super.key});

  // Aristokrat Renk Paleti
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _deepAnthracite = Color(0xFF121212);
  static const Color _monsieurGold = Color(0xFFD4AF37);
  static const Color _bronzeAccent = Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final driver = authController.driver;

    return Scaffold(
      backgroundColor: _richBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'HUKUKİ KALKAN VE SÖZLEŞME',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
            color: _monsieurGold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _monsieurGold, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan Radyal Gradyan
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [_deepAnthracite, _richBlack],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık Bölümü
                _buildHeader(),
                
                const SizedBox(height: 40),
                
                // Sözleşme Metni Konteynırı (Parşömen Etkisi)
                _buildContractPaper(driver),
                
                const SizedBox(height: 30),
                
                // Dijital İmza ve Onay Mührü
                _buildDigitalSeal(driver),
                
                const SizedBox(height: 40),
                
                // Acil Destek Butonu
                _buildEmergencyButton(authController),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _monsieurGold.withValues(alpha: 0.3), width: 1),
              color: _monsieurGold.withValues(alpha: 0.05),
            ),
            child: const Icon(Icons.gavel_rounded, size: 50, color: _monsieurGold),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          'DİJİTAL TAŞIT KİRA SÖZLEŞMESİ',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'YASAL GÜVENCE VE HUKUKİ KORUMA ALTINDADIR',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _monsieurGold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(width: 40, height: 2, color: _monsieurGold),
      ],
    );
  }

  Widget _buildContractPaper(dynamic driver) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegalSection('1. AKİT TARAFLAR', 
            'İşbu sözleşme, bir tarafta ${BrandConfig.current.appName} Teknoloji Platformu (bundan böyle "PLATFORM" olarak anılacaktır) ile diğer tarafta sistemde kayıtlı bağımsız hizmet sağlayıcı ${driver?.name?.toUpperCase() ?? 'SÜRÜCÜ'} (bundan böyle "HİZMET SAĞLAYICI" olarak anılacaktır) arasında akdedilmiştir.'),
          
          _buildLegalSection('2. HUKUKİ STATÜ VE KONU', 
            '6098 sayılı Türk Borçlar Kanunu Madde 299 ve devamı uyarınca düzenlenen işbu belge, "Taşıt Kira Sözleşmesi" hükmündedir. Hizmet sağlayıcı, platform üzerinden aldığı talepler doğrultusunda kendi yönetim ve sorumluluğunda olan aracı, yolcuya "Kısa Süreli Tahsis" yöntemiyle kiralamaktadır.'),
          
          _buildLegalSection('3. YASAL BEYAN VE TAAHHÜT', 
            'PLATFORM, taşımacılık hizmetinin tarafı olmayıp; taraflar arasındaki kira sözleşmesinin kurulmasına dijital aracılık etmektedir. Tüm operasyonel süreçler, mülkiyet ve tasarruf hakkı hizmet sağlayıcıya aittir.'),
            
          _buildLegalSection('4. DENETİM VE İBRAZ', 
            'İşbu dijital sözleşme, kolluk kuvvetleri tarafından yapılan denetimlerde yasal dayanak teşkil eder. Sürücü, platform üyeliği boyunca bu belgenin tüm hükümlerini kabul etmiş sayılır.'),
        ],
      ),
    );
  }

  Widget _buildLegalSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _monsieurGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.publicSans(
              fontSize: 12,
              color: Colors.grey[400],
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 15),
          Container(width: 20, height: 1, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildDigitalSeal(dynamic driver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [_deepAnthracite, _richBlack],
        ),
        border: Border.all(color: _monsieurGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSealRow('DİJİTAL ONAY', 'DOĞRULANDI'),
                  const SizedBox(height: 12),
                  _buildSealRow('SÜRÜCÜ ID', driver?.id.substring(0, 8).toUpperCase() ?? '-'),
                  const SizedBox(height: 12),
                  _buildSealRow('TARİH', DateFormat('dd.MM.yyyy').format(DateTime.now())),
                ],
              ),
              _buildSmallGoldSeal(),
            ],
          ),
          const Divider(color: Colors.white10, height: 40),
          Text(
            'BU BELGE ELEKTRONİK İMZA KANUNU UYARINCA GEÇERLİDİR.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8,
              color: Colors.grey[600],
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSealRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.grey[700], fontWeight: FontWeight.w800),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSmallGoldSeal() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [_monsieurGold, _bronzeAccent]),
        boxShadow: [BoxShadow(color: _bronzeAccent.withValues(alpha: 0.2), blurRadius: 8)],
      ),
      child: const Center(
        child: Icon(Icons.verified_rounded, color: Colors.black54, size: 24),
      ),
    );
  }

  Widget _buildEmergencyButton(AuthController authController) {
    return GestureDetector(
      onTap: () => authController.launchEmergencySupport(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          color: Colors.redAccent.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent_rounded, color: Colors.redAccent, size: 22),
            const SizedBox(width: 15),
            Text(
              'ACİL AVUKAT DESTEĞİ (7/24)',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
