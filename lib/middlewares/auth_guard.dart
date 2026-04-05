import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthGuard extends GetMiddleware {
  // Rota izinleri matrisi
  final Map<String, List<String>> _routePermissions = {
    '/admin-dashboard': ['admin'],
    '/dashboard': ['driver'], // Driver Home
    '/trip-management': ['driver'],
    '/passenger-home': ['passenger'],
    '/ride-history': ['passenger', 'admin'],
  };

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;

    // Herkese açık (veya auth öncesi) rotalar kontrol edilmez
    if (route == '/login' || route == '/role-selection' || route == '/splash') {
      return null; 
    }

    // Middleware çalışırken AuthController'ı bulamıyorsa ana kapıya at
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: '/login');
    }

    final auth = Get.find<AuthController>();

    // Eğer giriş yapılmamışsa doğrudan giriş sayfasına at
    if (auth.user == null) {
      return const RouteSettings(name: '/login');
    }

    // Rolü henüz belli değilse yüklenmesine izin ver (Role tespiti beklenmeli)
    final role = auth.userRole.value;
    if (role.isEmpty) {
      return null; 
    }

    // Mevcut rota için kısıtlama var mı?
    if (_routePermissions.containsKey(route)) {
      final allowedRoles = _routePermissions[route]!;
      
      if (!allowedRoles.contains(role)) {
        debugPrint("Güvenlik İhlali: $role yetkisiyle $route rotasına erişmeye çalışıldı.");
        
        // Yetkisiz erişim denendi! Herkesi ait olduğu merkeze zorla geri at.
        switch (role) {
          case 'admin':
            return const RouteSettings(name: '/admin-dashboard');
          case 'driver':
            return const RouteSettings(name: '/dashboard');
          case 'passenger':
            return const RouteSettings(name: '/passenger-home');
          default:
            return const RouteSettings(name: '/login');
        }
      }
    }

    return null; // Yetki var, geçişe izin ver.
  }
}
