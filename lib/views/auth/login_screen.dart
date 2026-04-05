import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/brand_config.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Aristokrat Renk Paleti
  static const Color _deepAnthracite = Color(0xFF121212);
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _monsieurGold = Color(0xFFD4AF37); // Classic Gold
  static const Color _bronzeAccent = Color(0xFFCD7F32);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen e-posta adresinizi girin');
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen şifrenizi girin');
      return;
    }

    authController.login(
      emailController.text.trim(),
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _richBlack,
      body: Stack(
        children: [
          // Arka Plan Gradyanı
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [_deepAnthracite, _richBlack],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
          // Dekoratif Gold Detay (Üst Köşe)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _monsieurGold.withValues(alpha: 0.15),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo & Otoriter Başlık
                  Center(
                    child: Column(
                      children: [
                        _buildAristocratLogo(),
                        const SizedBox(height: 30),
                        Text(
                          'YOLUN HAKİMİYETİNE\nHOŞ GELDİNİZ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: 40,
                          height: 2,
                          color: _monsieurGold,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '${BrandConfig.current.appName}\nYasal ve Vizyoner Ulaşım Ağı',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[400],
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Glassmorphism Form Alanları
                  _buildGlassInput(
                    child: CustomTextField(
                      controller: emailController,
                      label: 'E-posta',
                      hint: 'Kurumsal veya bireysel adresiniz',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGlassInput(
                    child: CustomTextField(
                      controller: passwordController,
                      label: 'Şifre',
                      hint: 'Güvenli erişim anahtarınız',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (emailController.text.trim().isEmpty) {
                          Get.snackbar('Uyarı', 'Önce e-posta adresinizi girin');
                          return;
                        }
                        authController.resetPassword(emailController.text.trim());
                      },
                      child: Text(
                        'Şifremi Unuttum',
                        style: GoogleFonts.publicSans(
                          color: _monsieurGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Modern Aristokrat Buton
                  Obx(() => _buildPrimaryButton()),
                  
                  const SizedBox(height: 10),
                  
                  const SizedBox(height: 25),
                  
                  // Kayıt Ol Yönlendirmesi
                  Center(
                    child: TextButton(
                      onPressed: () => Get.offAllNamed('/register'),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Henüz bir hesabınız yok mu? ',
                          style: GoogleFonts.publicSans(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'AYRICALIKLI DÜNYAMIZA KATILIN',
                              style: GoogleFonts.publicSans(
                                color: _monsieurGold,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  // Alttaki Mühür Slogan
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_rounded, size: 14, color: _monsieurGold.withValues(alpha: 0.5)),
                        const SizedBox(width: 8),
                        Text(
                          'DİREKSİYON BAŞINDA, HUKUK ZEMİNİNDE.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAristocratLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _monsieurGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _monsieurGold.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _monsieurGold.withValues(alpha: 0.05),
            ),
          ),
          const Icon(
            Icons.handshake_rounded,
            size: 45,
            color: _monsieurGold,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [_monsieurGold, _bronzeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _monsieurGold.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: authController.isLoading.value ? null : _login,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: authController.isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'SİSTEME GİRİŞ YAP',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
