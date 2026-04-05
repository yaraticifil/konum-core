import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum BrandType { konum, emekTaksi, mesutBahtiyar }

class BrandConfig {
  final BrandType type;
  final String appName;
  final Color primaryColor;
  final Color secondaryColor;
  final String logoAsset;
  final String supportEmail;
  final String welcomeSlogan;

  BrandConfig({
    required this.type,
    required this.appName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoAsset,
    required this.supportEmail,
    required this.welcomeSlogan,
  });

  static BrandConfig get current => Get.find<BrandManager>().currentConfig;
}

class BrandManager extends GetxController {
  final Rx<BrandType> _activeBrand = BrandType.konum.obs;

  BrandType get activeBrand => _activeBrand.value;

  final Map<BrandType, BrandConfig> configs = {
    BrandType.konum: BrandConfig(
      type: BrandType.konum,
      appName: 'KONUM',
      primaryColor: const Color(0xFFFFD700), // Gold
      secondaryColor: const Color(0xFFC5A300),
      logoAsset: 'assets/icon.png',
      supportEmail: 'destek@konum.app',
      welcomeSlogan: 'Özel Asistanın, Yasal Yolculuğun.',
    ),
    BrandType.emekTaksi: BrandConfig(
      type: BrandType.emekTaksi,
      appName: 'EMEK TAKSİ',
      primaryColor: const Color(0xFF2ECC71), // Emerald Green
      secondaryColor: const Color(0xFF27AE60),
      logoAsset: 'assets/icon.png', // Temporary
      supportEmail: 'destek@emektaksi.com',
      welcomeSlogan: 'Alın terimiz, güvenli yolculuğunuz.',
    ),
    BrandType.mesutBahtiyar: BrandConfig(
      type: BrandType.mesutBahtiyar,
      appName: 'MESUT BAHTİYAR',
      primaryColor: const Color(0xFF3498DB), // Bright Blue
      secondaryColor: const Color(0xFF2980B9),
      logoAsset: 'assets/icon.png', // Temporary
      supportEmail: 'destek@mesutbahtiyar.com',
      welcomeSlogan: 'Mutlu yolculuklar, mutlu sürücüler.',
    ),
  };

  BrandConfig get currentConfig => configs[_activeBrand.value]!;

  void setBrand(BrandType type) {
    _activeBrand.value = type;
    Get.forceAppUpdate();
  }
}
