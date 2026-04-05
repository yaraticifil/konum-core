import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/brand_config.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildFeatureHighlights(),
              const SizedBox(height: 45),
              Text(
                'Giriş Yöntemi Seçin',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDisabled,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Role Cards
              _buildRoleCard(
                context,
                title: 'Sürücü',
                description: 'Kendi aracınızla kazanç sağlayın ve hukuki güvence altına alın.',
                icon: Icons.directions_car_filled_rounded,
                onTap: () => Get.toNamed('/login'), // Default to login then it redirects
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: 'Yolcu',
                description: 'Güvenli, şeffaf ve adil fiyatlı yolculukların tadını çıkarın.',
                icon: Icons.person_pin_circle_rounded,
                onTap: () => Get.toNamed('/login'),
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: 'Yönetici',
                description: 'Sistemi denetleyin, onayları yönetin ve finansal verileri izleyin.',
                icon: Icons.admin_panel_settings_rounded,
                onTap: () => Get.toNamed('/admin-login'),
                isSecondary: true,
              ),
              
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '© 2026 ${BrandConfig.current.appName} - Hukuki ve Teknolojik Altyapı',

                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    color: AppColors.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.handshake_rounded, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Hoş Geldiniz',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Geleceğin Hukuki Taşıma Altyapısı',
          style: GoogleFonts.publicSans(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureItem(Icons.receipt_long_rounded, 'E-FATURA', 'Anlık Mali Onay'),
        _buildFeatureItem(Icons.gavel_rounded, 'AVUKAT', '7/24 Acil Destek'),
        _buildFeatureItem(Icons.security_rounded, 'SÖZLEŞME', 'TBK Güvencesi'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String sub) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        Text(
          sub,
          style: GoogleFonts.publicSans(
            fontSize: 9,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSecondary ? Colors.transparent : AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSecondary ? AppColors.divider : AppColors.divider.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: isSecondary ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSecondary 
                      ? AppColors.textDisabled.withValues(alpha: 0.1) 
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSecondary ? AppColors.textSecondary : AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.publicSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isSecondary ? AppColors.textDisabled : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
