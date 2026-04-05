import 'package:flutter/material.dart';
import 'brand_config.dart';

class AppColors {
  // Brand Colors - Now dynamic!
  static Color get primary => BrandConfig.current.primaryColor;
  static Color get primaryDark => BrandConfig.current.secondaryColor;
  
  // Background Colors
  static const Color background = Color(0xFF1C1C1C); // Deep Charcoal/Black
  static const Color cardBg = Color(0xFF2C2C2C);
  static const Color surface = Color(0xFF333333);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF666666);

  // Accents
  static const Color divider = Color(0xFF3D3D3D);
  static const Color overlay = Color(0x99000000);
}
