import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/brand_config.dart';

class DigitalIdScreen extends StatelessWidget {
  const DigitalIdScreen({super.key});

  // Aristokrat Renk Paleti
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _deepAnthracite = Color(0xFF121212);
  static const Color _monsieurGold = Color(0xFFD4AF37);
  static const Color _bronzeAccent = Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final driver = authController.driver;

    if (driver == null) {
      return Scaffold(
        backgroundColor: _richBlack,
        appBar: AppBar(
          title: const Text('Dijital Kimlik'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('Sürücü bilgisi bulunamadı.', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: _richBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'YASAL YETKİ BELGESİ',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
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
            child: Column(
              children: [
                const SizedBox(height: 120),
                
                // Mühürlü Kimlik Kartı
                _buildSealCard(driver),
                
                const SizedBox(height: 40),
                
                // Doğrulama Bölümü
                _buildVerificationSection(driver),
                
                const SizedBox(height: 40),
                
                // Alt Bilgi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'BU BELGE, T.C. ANAYASASI VE İLGİLİ MEVZUAT ÇERÇEVESİNDE ${BrandConfig.current.appName} PLATFORMU TARAFINDAN DİJİTAL OLARAK TASDİK EDİLMİŞTİR.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSealCard(dynamic driver) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [_deepAnthracite, _richBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _monsieurGold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: _monsieurGold.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arka Plan Deseni (Hafif Logo)
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.03,
              child: Icon(Icons.handshake_rounded, size: 200, color: _monsieurGold),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                // Profil ve Mühür
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileFrame(),
                    const Spacer(),
                    _buildGoldSeal(),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Kişisel Bilgiler
                _buildInfoRow('TAM ADI', driver.name.toUpperCase()),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow('BELGE NO', 'KN-${driver.id.substring(0, 8).toUpperCase()}')),
                    Expanded(child: _buildInfoRow('DURUM', 'TASDİKLİ')),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow('PLATFORM', BrandConfig.current.appName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileFrame() {
    return Container(
      width: 90,
      height: 110,
      decoration: BoxDecoration(
        color: _richBlack,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: const Icon(Icons.person, size: 60, color: Colors.white10),
    );
  }

  Widget _buildGoldSeal() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [_monsieurGold, _bronzeAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: _bronzeAccent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: const Center(
            child: Icon(Icons.verified_user_rounded, color: Colors.black54, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            color: Colors.grey[600],
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        Container(
          width: 40,
          height: 1,
          color: _monsieurGold.withValues(alpha: 0.3),
          margin: const EdgeInsets.only(top: 6),
        ),
      ],
    );
  }

  Widget _buildVerificationSection(dynamic driver) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            'ANLIK DOĞRULAMA SİSTEMİ',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _monsieurGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 30),
          
          // QR Kod Çerçevesi
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: QrImageView(
              data: 'https://konum.app/verify/${driver.id}',
              version: QrVersions.auto,
              size: 160.0,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ),
          
          const SizedBox(height: 30),
          Text(
            'YOLCU VE KOLLUK KUVVETLERİ TARAFINDAN OKUTULDUĞUNDA\nYASAL STATÜNÜZÜ VE ÜYELİĞİNİZİ ONAYLAR.',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              fontSize: 9,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
