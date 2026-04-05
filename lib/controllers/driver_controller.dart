import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/driver_model.dart';
import '../models/payout_model.dart';
import '../models/ride_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../services/ride_service.dart';
import '../services/invoice_service.dart';
import '../services/error_logger_service.dart';
import '../services/insurance_service.dart';
import '../models/error_model.dart';

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RideService _rideService = RideService();
  final InvoiceService _invoiceService = InvoiceService();
  final ErrorLoggerService _errorLogger = ErrorLoggerService();
  final InsuranceService _insuranceService = InsuranceService();

  // UI'da çarkın dönmesi ve butonun kilitlenmesi için gerekli
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;

  final Rx<Driver?> driver = Rx<Driver?>(null);
  final RxList<Payout> payouts = <Payout>[].obs;
  final Rx<Ride?> currentRide = Rx<Ride?>(null);
  final Rx<Ride?> incomingRide = Rx<Ride?>(null);

  StreamSubscription? _locationSubscription;
  StreamSubscription? _rideSubscription;

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _rideSubscription?.cancel();
    super.onClose();
  }

  /// Çevrimiçi / çevrimdışı geçiş
  Future<void> goOnline() async {
    if (driver.value == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await _firestore.collection('driver_locations').doc(driver.value!.id).set({
        'lat': position.latitude,
        'lng': position.longitude,
        'isOnline': true,
        'name': driver.value!.name,
        'phone': driver.value!.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      isOnline.value = true;

      // Konumu periyodik güncelle
      _locationSubscription?.cancel();
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // 50 metre hareket edince güncelle
        ),
      ).listen((position) {
        _firestore.collection('driver_locations').doc(driver.value!.id).update({
          'lat': position.latitude,
          'lng': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Gelen çağrıları dinle
      _listenForRides();

      Get.snackbar("Çevrimiçi", "Artık yolculuk çağrıları alabilirsiniz.",
          backgroundColor: const Color(0xFF2C2C2C));
    } catch (e) {
      debugPrint("Çevrimiçi hatası: $e");
      await _errorLogger.log(ErrorModel(code: "DRIVER_ONLINE_FAIL", message: e.toString(), source: "DriverController.goOnline", occurredAt: DateTime.now()));
      Get.snackbar("Hata", "Çevrimiçi olunamadı: $e");
    }
  }

  Future<void> goOffline() async {
    if (driver.value == null) return;
    try {
      await _firestore.collection('driver_locations').doc(driver.value!.id).update({
        'isOnline': false,
      });
      isOnline.value = false;
      _locationSubscription?.cancel();
      _rideSubscription?.cancel();
      Get.snackbar("Çevrimdışı", "Artık yolculuk çağrıları almıyorsunuz.");
    } catch (e) {
      debugPrint("Çevrimdışı hatası: $e");
    }
  }

  /// Gelen yolculuk çağrılarını dinle
  void _listenForRides() {
    if (driver.value == null) return;
    _rideSubscription?.cancel();
    _rideSubscription = _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driver.value!.id)
        .where('status', isEqualTo: 'matched')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        incomingRide.value = Ride.fromFirestore(snapshot.docs.first);
      }
    });
  }

  /// Çağrıyı kabul et
  Future<void> acceptRide(String rideId) async {
    try {
      final scheduledPickupTime = DateTime.now().add(const Duration(minutes: 15));
      await _firestore.collection('rides').doc(rideId).update({
        'status': 'pre_reserved',
        'scheduledPickupTime': Timestamp.fromDate(scheduledPickupTime),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      currentRide.value = incomingRide.value;
      incomingRide.value = null;
      Get.snackbar("Kabul Edildi", "Hazırlık Süresi: 15 Dakika (Ön Rezervasyon)");
    } catch (e) {
      debugPrint("Kabul hatası: $e");
      await _errorLogger.log(ErrorModel(code: "RIDE_ACCEPT_FAIL", message: e.toString(), source: "DriverController.acceptRide", occurredAt: DateTime.now(), metadata: {"rideId": rideId}));
    }
  }

  /// Çağrıyı reddet
  Future<void> rejectRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverId': null,
        'driverName': null,
        'driverPhone': null,
        'status': 'searching',
      });
      incomingRide.value = null;
    } catch (e) {
      debugPrint("Red hatası: $e");
    }
  }

  /// Yolcuya vardım
  Future<void> arrivedAtPickup() async {
    if (currentRide.value == null) return;
    // Durumu güncellemiyoruz ama UI'da gösteriyoruz
  }

  /// Yolculuğu başlat
  Future<void> startRide() async {
    if (currentRide.value == null) return;
    try {
      await _firestore.collection('rides').doc(currentRide.value!.id).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final ride = currentRide.value!;
      await _insuranceService.issueSeatInsurance(
        rideId: ride.id,
        driverId: ride.driverId ?? '',
        passengerId: ride.passengerId,
        scheduledPickupTime: ride.scheduledPickupTime ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint("Başlatma hatası: $e");
      await _errorLogger.log(ErrorModel(code: "RIDE_START_FAIL", message: e.toString(), source: "DriverController.startRide", occurredAt: DateTime.now(), metadata: {"rideId": currentRide.value?.id}));
    }
  }

  /// Yolculuğu tamamla
  Future<void> completeRide() async {
    if (currentRide.value == null) return;
    try {
      final ride = currentRide.value!;
      
      // Şoförden platform komisyonunu cari hesap (dijital cüzdan) üzerinden düşme işlemi.
      // Sadece asıl hesaptan (walletBalance) komisyon eksiltilir.
      final newBalance = (driver.value?.walletBalance ?? 0) - ride.commission;

      final legalHash = _rideService.generateLegalHash(
        rideId: ride.id,
        driverId: ride.driverId ?? '',
        passengerId: ride.passengerId,
        pickupTime: ride.scheduledPickupTime ?? ride.createdAt,
      );
      final invoiceUrl = await _invoiceService.createEArsivInvoice(
        rideId: ride.id,
        driverId: ride.driverId ?? '',
        passengerId: ride.passengerId,
        grossTotal: ride.grossTotal,
      );

      await _firestore.collection('rides').doc(ride.id).update({
        'status': 'completed',
        'legalHash': legalHash,
        'invoiceUrl': invoiceUrl,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Bakiye düşümü (cari hesap mantığı, sadece borç kaydı olarak cüzdandan eksiltilir)
      if (ride.commission > 0 && driver.value != null) {
         await _firestore.collection('drivers').doc(driver.value!.id).update({
           'walletBalance': newBalance,
         });
      }

      currentRide.value = null;
      await fetchDriverData(driver.value!.id); // Güncel cüzdan bakiyesini çek
      Get.snackbar("Tamamlandı", "Yolculuk başarıyla tamamlandı. Komisyon tahakkuk ettirildi.");
    } catch (e) {
      debugPrint("Tamamlama hatası: $e");
      await _errorLogger.log(ErrorModel(code: "RIDE_COMPLETE_FAIL", message: e.toString(), source: "DriverController.completeRide", occurredAt: DateTime.now(), metadata: {"rideId": currentRide.value?.id}));
    }
  }

  /// IBAN Güncelleme (Dijital Kimlikten vb.)
  Future<void> updateIban(String newIban) async {
    if (driver.value == null) return;
    isLoading.value = true;
    try {
      await _firestore.collection('drivers').doc(driver.value!.id).update({
        'iban': newIban,
      });
      await fetchDriverData(driver.value!.id); // Cihaza geri çek
      Get.snackbar("Başarılı", "IBAN numaranız hukuki kayıtlarımıza işlendi.");
    } catch (e) {
      Get.snackbar("Hata", "IBAN güncellenemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Sürücü verilerini çeken metod
  Future<void> fetchDriverData(String driverId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore
          .collection('drivers')
          .doc(driverId)
          .get();
      if (doc.exists) {
        driver.value = Driver.fromFirestore(doc);
      }

    } catch (e) {
      debugPrint("Sürücü hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reportPenalty({
    required XFile image,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;
    try {
      final String driverId = driver.value?.id ?? 'unknown';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final Reference storageRef = FirebaseStorage.instance.ref().child('penalties/$driverId/$fileName');

      // Upload file
      final String contentType = p.extension(image.path).replaceAll('.', '');
      final SettableMetadata metadata = SettableMetadata(contentType: 'image/$contentType');
      
      final UploadTask uploadTask;
      final byteData = await image.readAsBytes();
      uploadTask = storageRef.putData(byteData, metadata);

      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save to Firestore
      await _firestore.collection('penalties').add({
        'driverId': driverId,
        'driverName': driver.value?.name ?? 'Anonim',
        'imageUrl': downloadUrl,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Başarılı", "Ceza bildirimi avukatlarımıza iletildi.");
    } catch (e) {
      Get.snackbar("Hata", "Bildirim gönderilemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayouts([String? driverId]) async {
    String id = driverId ?? driver.value?.id ?? '';
    if (id.isEmpty) return;
    try {
      final snap = await _firestore
          .collection('payouts').where('driverId', isEqualTo: id).get();
      payouts.value = snap.docs.map((doc) => Payout.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Payout hatası: $e");
    }
  }

  double getTotalEarnings() {
    return payouts
        .where((p) => p.status == PayoutStatus.completed)
        .fold(0.0, (total, item) => total + item.amount);
  }

  double getPendingPayouts() {
    return payouts
        .where((p) => p.status == PayoutStatus.pending)
        .fold(0.0, (total, item) => total + item.amount);
  }

  Future<void> requestPayout(double amount, String description) async {
    isLoading.value = true;
    try {
      await _firestore.collection('payouts').add({
        'driverId': driver.value?.id ?? '',
        'amount': amount,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchPayouts();
      Get.snackbar("Başarılı", "Talebiniz iletildi");
    } catch (e) {
      Get.snackbar("Hata", "Talep gönderilemedi");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleOnlineStatus() async {
    if (isOnline.value) {
      await goOffline();
    } else {
      await goOnline();
    }
  }
}