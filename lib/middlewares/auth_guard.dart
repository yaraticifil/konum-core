import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthGuard extends GetMiddleware {
  final Map<String, List<String>> _routePermissions = {
    '/admin-dashboard': ['admin', 'founder'],
    '/admin-audit': ['admin', 'founder'],
    '/compensation': ['admin', 'founder'],
    '/dashboard': ['driver'],
    '/trip-management': ['driver'],
    '/operational-status': ['driver', 'admin', 'founder'],
    '/ai-assistant': ['driver'],
    '/driver-kyc': ['driver'],
    '/digital-id': ['driver'],
    '/legal-contract': ['driver'],
    '/report-penalty': ['driver'],
    '/legal-defense': ['driver'],
    '/fair-earnings': ['driver'],
    '/ride-detail': ['driver', 'passenger', 'admin', 'founder'],
    '/passenger-home': ['passenger'],
    '/ride-history': ['passenger', 'admin', 'founder'],
  };

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;
    if (route == '/login' || route == '/role-selection' || route == '/' || route == '/register' ||
        route == '/admin-login' || route == '/waiting' || route.startsWith('/privacy') ||
        route.startsWith('/clarification') || route.startsWith('/terms') || route.startsWith('/data-deletion')) {
      return null; 
    }
    if (!Get.isRegistered<AuthController>()) return const RouteSettings(name: '/login');
    final auth = Get.find<AuthController>();
    if (auth.user == null) return const RouteSettings(name: '/login');
    final role = auth.userRole.value;
    if (role.isEmpty) return null;

    if (_routePermissions.containsKey(route)) {
      if (!_routePermissions[route]!.contains(role)) {
        switch (role) {
          case 'admin': case 'founder': return const RouteSettings(name: '/admin-dashboard');
          case 'driver': return const RouteSettings(name: '/dashboard');
          case 'passenger': return const RouteSettings(name: '/passenger-home');
          default: return const RouteSettings(name: '/login');
        }
      }
    }
    return null;
  }
}
