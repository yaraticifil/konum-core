import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/brand_config.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/driver_controller.dart';
import '../../models/payout_model.dart';
import '../payout/payout_request_screen.dart';
import '../payout/payout_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final DriverController driverController = Get.find<DriverController>();

  // Aristokrat Renk Paleti
  static const Color _deepAnthracite = Color(0xFF121212);
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _monsieurGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    
    if (authController.user != null) {
      driverController.fetchPayouts(authController.user!.uid);
      driverController.fetchDriverData(authController.user!.uid);
      if (authController.driver == null) {
        authController.fetchDriverData(authController.user!.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _richBlack,
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
          
          SafeArea(
            child: RefreshIndicator(
              color: _monsieurGold,
              backgroundColor: _deepAnthracite,
              onRefresh: () async {
                if (authController.driver != null) {
                  await driverController.fetchDriverData(authController.driver!.id);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 30),
                    _buildWelcomeHeader(),
                    const SizedBox(height: 30),
                    _buildStatsOverview(),
                    const SizedBox(height: 35),
                    _buildActionSection(),
                    const SizedBox(height: 35),
                    _buildRecentTransactions(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
              BrandConfig.current.appName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _monsieurGold,
                letterSpacing: 3,
              ),
            )),
            Container(
              width: 30,
              height: 2,
              color: _monsieurGold,
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
        Row(
          children: [
            _buildGlassIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _buildGlassIconButton(
              icon: Icons.logout_rounded,
              onTap: () => authController.logout(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
          'HOŞ GELDİNİZ,\n${authController.driver?.name.toUpperCase() ?? 'KAPTAN'}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
            letterSpacing: 1,
          ),
        )),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.green, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'YASAL YETKİLİ SÜRÜCÜ',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildGlassStatCard(
            'TOPLAM KAZANÇ',
            '₺${driverController.getTotalEarnings().toStringAsFixed(2)}',
            Icons.payments_rounded,
            _monsieurGold,
          )),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Obx(() => _buildGlassStatCard(
            'AKTİF BAKİYE',
            '₺${driverController.getPendingPayouts().toStringAsFixed(2)}',
            Icons.account_balance_rounded,
            Colors.white70,
          )),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(String title, String value, IconData icon, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(height: 15),
              Text(
                title,
                style: GoogleFonts.publicSans(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPERASYONEL MERKEZ',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _monsieurGold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        
        // Çevrimiçi Durum Kartı
        Obx(() => _buildStatusToggle()),
        
        const SizedBox(height: 20),
        
        // Hızlı Aksiyonlar Izgarası
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.85,
          children: [
            _buildGridAction('ADİL\nKAZANÇ', Icons.analytics_rounded, _monsieurGold, () => Get.toNamed('/fair-earnings')),
            _buildGridAction('ACİL\nDESTEK', Icons.gavel_rounded, Colors.redAccent, () => authController.launchEmergencySupport()),
            _buildGridAction('CEZA\nBİLDİR', Icons.security_rounded, Colors.orangeAccent, () => Get.toNamed('/report-penalty')),
            _buildGridAction('DİJİTAL\nKİMLİK', Icons.badge_rounded, Colors.blueAccent, () => Get.toNamed('/digital-id')),
            _buildGridAction('SÖZLEŞME\nİBRAZ', Icons.assignment_rounded, Colors.blueGrey, () => Get.toNamed('/legal-contract')),
            _buildGridAction('PARA\nÇEK', Icons.account_balance_wallet_rounded, Colors.greenAccent, () => Get.to(() => const PayoutRequestScreen())),
            _buildGridAction('SİSTEM\nDURUMU', Icons.settings_input_component_rounded, Colors.cyanAccent, () => Get.toNamed('/operational-status')),
            _buildGridAction('AI\nREHBER', Icons.auto_awesome_rounded, _monsieurGold, () => Get.toNamed('/ai-assistant')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    final bool isOnline = driverController.isOnline.value;
    return GestureDetector(
      onTap: () => driverController.toggleOnlineStatus(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: isOnline 
              ? [Colors.green.withValues(alpha: 0.15), Colors.green.withValues(alpha: 0.02)]
              : [Colors.red.withValues(alpha: 0.15), Colors.red.withValues(alpha: 0.02)],
          ),
          border: Border.all(
            color: isOnline ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? Colors.green : Colors.red).withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                isOnline ? Icons.power_rounded : Icons.power_settings_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? 'OPERASYONA HAZIR' : 'SİSTEM ÇEVRİMDIŞI',
                    style: GoogleFonts.spaceGrotesk(
                      color: isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    isOnline ? 'Yolculuk çağrıları aktif.' : 'Göreve başlamak için dokunun.',
                    style: GoogleFonts.publicSans(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color.withValues(alpha: 0.8), size: 26),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 1,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SON İŞLEMLER',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _monsieurGold,
                letterSpacing: 2,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const PayoutHistoryScreen()),
              child: Text(
                'ARŞİV',
                style: GoogleFonts.spaceGrotesk(
                  color: _monsieurGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (driverController.payouts.isEmpty) {
            return _buildEmptyTransactions();
          }

          return Column(
            children: driverController.payouts.take(3).map((payout) {
              return _buildTransactionItem(payout);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 40, color: Colors.grey[800]),
          const SizedBox(height: 15),
          Text(
            'Henüz bir işlem kaydı bulunamadı.',
            style: GoogleFonts.publicSans(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Payout payout) {
    final Color statusColor = _getStatusColor(payout.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(payout.status), color: statusColor, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payout.description.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  DateFormat('dd MMMM yyyy').format(payout.createdAt),
                  style: GoogleFonts.publicSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${payout.amount.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _monsieurGold,
                ),
              ),
              Text(
                payout.statusText,
                style: GoogleFonts.spaceGrotesk(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending: return Colors.orangeAccent;
      case PayoutStatus.completed: return Colors.greenAccent;
      case PayoutStatus.transferring: return Colors.blueAccent;
      case PayoutStatus.rejected: return Colors.redAccent;
    }
  }

  IconData _getStatusIcon(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending: return Icons.hourglass_top_rounded;
      case PayoutStatus.completed: return Icons.check_circle_outline_rounded;
      case PayoutStatus.transferring: return Icons.swap_horiz_rounded;
      case PayoutStatus.rejected: return Icons.cancel_outlined;
    }
  }
}
