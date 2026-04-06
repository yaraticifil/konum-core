import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/role_selection_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/driver/waiting_screen.dart';
import '../views/driver/dashboard_screen.dart';
import '../views/admin/admin_login_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../bindings/auth_binding.dart';
import '../bindings/driver_binding.dart';
import '../bindings/admin_binding.dart';
import '../bindings/passenger_binding.dart';
import '../middlewares/auth_guard.dart';
import '../views/driver/digital_id_screen.dart';
import '../views/driver/legal_contract_screen.dart';
import '../views/driver/penalty_report_screen.dart';
import '../views/driver/legal_defense_screen.dart';
import '../views/passenger/passenger_home_screen.dart';
import '../views/passenger/ride_history_screen.dart';
import '../views/driver/fair_earnings_screen.dart';
import '../views/admin/compensation_screen.dart';
import '../views/driver/ride_detail_screen.dart';
import '../views/driver/driver_kyc_screen.dart';
import '../views/driver/trip_management_screen.dart';
import '../views/driver/operational_status_screen.dart';
import '../views/driver/ai_assistant_screen.dart';
import '../views/admin/admin_audit_screen.dart';
import '../legal/privacy_policy_page.dart';
import '../legal/clarification_page.dart';
import '../legal/terms_page.dart';
import '../legal/data_deletion_page.dart';

class AppPages {
  static const initial = '/';
  static final routes = [
    GetPage(name: '/', page: () => const SplashScreen(), binding: AuthBinding()),
    GetPage(name: '/operational-status', page: () => const OperationalStatusScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/ai-assistant', page: () => const AiAssistantScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/trip-management', page: () => const TripManagementScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/compensation', page: () => const CompensationScreen(), binding: AdminBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/admin-audit', page: () => const AdminAuditScreen(), binding: AdminBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/role-selection', page: () => const RoleSelectionScreen(), binding: AuthBinding()),
    GetPage(name: '/driver-kyc', page: () => const DriverKycScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/register', page: () => const RegisterScreen(), binding: AuthBinding()),
    GetPage(name: '/login', page: () => const LoginScreen(), binding: AuthBinding()),
    GetPage(name: '/waiting', page: () => const WaitingScreen(), binding: DriverBinding()),
    GetPage(name: '/dashboard', page: () => const DashboardScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/admin-login', page: () => const AdminLoginScreen(), binding: AdminBinding()),
    GetPage(name: '/admin-dashboard', page: () => const AdminDashboardScreen(), binding: AdminBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/digital-id', page: () => const DigitalIdScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/legal-contract', page: () => const LegalContractScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/report-penalty', page: () => const PenaltyReportScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/legal-defense', page: () => const LegalDefenseScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/passenger-home', page: () => const PassengerHomeScreen(), binding: PassengerBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/ride-history', page: () => const RideHistoryScreen(), binding: PassengerBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/fair-earnings', page: () => const FairEarningsScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/ride-detail', page: () => const RideDetailScreen(), binding: DriverBinding(), middlewares: [AuthGuard()]),
    GetPage(name: '/privacy-policy', page: () => const PrivacyPolicyPage()),
    GetPage(name: '/clarification', page: () => const ClarificationPage()),
    GetPage(name: '/terms', page: () => const TermsPage()),
    GetPage(name: '/data-deletion', page: () => const DataDeletionPage()),
  ];
}
