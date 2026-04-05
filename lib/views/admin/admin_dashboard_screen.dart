import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/driver_model.dart';
import '../../models/ride_model.dart';
import '../../models/payout_model.dart';
import '../../utils/app_colors.dart';
import '../../legal/legal_texts.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final AdminController adminController = Get.find<AdminController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    // Statik e-posta yerine AuthController'dan gelen dinamik rolü kontrol et
    if (authController.userRole.value != 'admin') {
      Get.snackbar(
        'Erişim Reddedildi',
        'Bu sayfaya erişim yetkiniz bulunmamaktadır.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      // Eğer kullanıcı admin değilse ana sayfaya yönlendir
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed('/role-selection');
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'YÖNETİM MERKEZİ',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textDisabled,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 11),
          isScrollable: true,
          tabs: const [
            Tab(text: 'PANEL'),
            Tab(text: 'SÜRÜCÜLER'),
            Tab(text: 'ÖDEMELER'),
            Tab(text: 'YOLCULUKLAR'),
            Tab(text: 'CEZALAR'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),

            onPressed: () {
              adminController.fetchDrivers();
              adminController.fetchPayouts();
              adminController.fetchRides();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: AppColors.primary),

            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDriversTab(),
          _buildPayoutsTab(),
          _buildRidesTab(),
          _buildPenaltiesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Sistem Özeti', 'Canlı veriler ve performans'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              LegalTexts.adminDashboardNotice,
              style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 30),
          _sectionHeader('Finansal Analiz', 'Hizmet bazlı kazanç dağılımı'),
          const SizedBox(height: 15),
          _buildSegmentBar(),
          const SizedBox(height: 30),
          _sectionHeader('Son Aktiviteler', 'Sistemdeki güncel hareketler'),
          const SizedBox(height: 15),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Text(subtitle, style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Sürücüler', adminController.drivers.length.toString(), Icons.people_rounded, AppColors.info),
        _buildStatCard('Bekleyen', adminController.getDriversCountByStatus(DriverStatus.pending).toString(), Icons.pending_rounded, AppColors.warning),
        _buildStatCard('Komisyon', '₺${adminController.totalCommission.toStringAsFixed(0)}', Icons.account_balance_rounded, AppColors.primary),
        _buildStatCard('Brüt Ciro', '₺${adminController.totalGrossRevenue.toStringAsFixed(0)}', Icons.trending_up_rounded, AppColors.success),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(title, style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBar() {
    return Obx(() {
      final stats = adminController.segmentDistribution;
      if (stats.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.entries.map((e) => Column(
            children: [
              Text(e.value.toString(), style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(e.key.toUpperCase(), style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          )).toList(),
        ),
      );
    });
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      final recent = adminController.drivers.take(5).toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final driver = recent[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Icon(Icons.person_rounded, color: AppColors.primary, size: 20)),

                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Yeni Sürücü Kaydı', style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                )),
                Text(DateFormat('HH:mm').format(driver.createdAt), style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.textDisabled)),
              ],
            ),
          );
        },
      );
    });
  }

  // --- Diğer Tablar (Özetlenmiş Versiyon) ---
  Widget _buildDriversTab() {
     return Obx(() {
       final drivers = adminController.filteredDrivers;
       return ListView.builder(
         padding: const EdgeInsets.all(15),
         itemCount: drivers.length,
         itemBuilder: (context, index) => _driverListItem(drivers[index]),
       );
     });
  }

  Widget _driverListItem(Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _statusColor(driver.status).withValues(alpha: 0.2))),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: _statusColor(driver.status).withValues(alpha: 0.1), child: Icon(Icons.person, color: _statusColor(driver.status))),
              const SizedBox(width: 15),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(driver.phone, style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                decoration: BoxDecoration(color: _statusColor(driver.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), 
                child: Text(driver.statusText, style: TextStyle(color: _statusColor(driver.status), fontSize: 10, fontWeight: FontWeight.bold))
              ),
            ],
          ),
          if (driver.status == DriverStatus.pending) ...[
            const SizedBox(height: 15),
            Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => adminController.updateDriverStatus(driver.id, DriverStatus.approved), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white), child: const Text('ONAYLA'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: () => adminController.updateDriverStatus(driver.id, DriverStatus.rejected), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white), child: const Text('REDDET'))),
            ])
          ]
        ],
      ),
    );
  }

  Widget _buildPayoutsTab() {
    return Obx(() {
      final payouts = adminController.payouts;
      if (payouts.isEmpty) return _emptyState(Icons.money_off_rounded, 'Kayıt bulunamadı');
      
      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: payouts.length,
        itemBuilder: (context, index) {
          final payout = payouts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getPayoutStatusColor(payout.status).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getPayoutStatusColor(payout.status).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getPayoutStatusIcon(payout.status), color: _getPayoutStatusColor(payout.status), size: 20),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('₺${payout.amount.toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(payout.description, style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(DateFormat('dd.MM.yyyy').format(payout.createdAt), style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.textDisabled)),
                  ],
                ),
                if (payout.status == PayoutStatus.pending) ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => adminController.updatePayoutStatus(payout.id, PayoutStatus.transferring),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.info, side: BorderSide(color: AppColors.info)),
                          child: const Text('AKTARIYOR'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => adminController.updatePayoutStatus(payout.id, PayoutStatus.completed),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                          child: const Text('TAMAMLA'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildRidesTab() {
    return Obx(() {
      final rides = adminController.rides;
      if (rides.isEmpty) return _emptyState(Icons.route_rounded, 'Yolculuk bulunamadı');

      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd.MM HH:mm').format(ride.createdAt), style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textDisabled)),
                    _statusBadge(ride.statusText, _getRideStatusColor(ride.status)),
                  ],
                ),
                const SizedBox(height: 12),
                _locationRow(Icons.my_location, Colors.green, ride.pickupAddress),
                const SizedBox(height: 8),
                _locationRow(Icons.location_on, AppColors.primary, ride.destAddress),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ride.passengerId.substring(0, 8), style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary)),
                    Text('₺${ride.grossTotal.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildPenaltiesTab() {
    return Obx(() {
      final penalties = adminController.penalties;
      if (penalties.isEmpty) return _emptyState(Icons.article_rounded, 'Ceza raporu bulunamadı');

      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: penalties.length,
        itemBuilder: (context, index) {
          final penalty = penalties[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(penalty['title'] ?? 'Ceza Raporu', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
                    _statusBadge(penalty['status']?.toUpperCase() ?? 'PENDING', AppColors.warning),
                  ],
                ),
                const SizedBox(height: 8),
                Text(penalty['description'] ?? 'Detay yok', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Miktar: ₺${penalty['amount']?.toString() ?? '0'}', style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                    Text(penalty['createdAt'] != null ? DateFormat('dd.MM.yyyy').format(DateTime.parse(penalty['createdAt'])) : '', style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textDisabled)),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.publicSans(color: AppColors.textDisabled)),
        ],
      ),
    );
  }

  Widget _locationRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(address, style: GoogleFonts.publicSans(fontSize: 12, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Color _getPayoutStatusColor(PayoutStatus s) {
    switch (s) {
      case PayoutStatus.completed: return AppColors.success;
      case PayoutStatus.pending: return AppColors.warning;
      case PayoutStatus.transferring: return AppColors.info;
      case PayoutStatus.rejected: return AppColors.error;
    }
  }

  IconData _getPayoutStatusIcon(PayoutStatus s) {
    switch (s) {
      case PayoutStatus.completed: return Icons.check_circle_rounded;
      case PayoutStatus.pending: return Icons.hourglass_empty_rounded;
      case PayoutStatus.transferring: return Icons.sync_rounded;
      case PayoutStatus.rejected: return Icons.cancel_rounded;
    }
  }

  Color _getRideStatusColor(RideStatus s) {
    switch (s) {
      case RideStatus.completed: return AppColors.success;
      case RideStatus.inProgress: return AppColors.info;
      case RideStatus.searching: return AppColors.warning;
      case RideStatus.cancelled: return AppColors.error;
      default: return AppColors.textDisabled;
    }
  }

  Color _statusColor(DriverStatus s) {
    switch (s) {
      case DriverStatus.approved: return AppColors.success;
      case DriverStatus.pending: return AppColors.warning;
      case DriverStatus.rejected: return AppColors.error;
      case DriverStatus.suspended: return Colors.blueGrey;
    }
  }
}
