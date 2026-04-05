import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ride_service.dart';

enum RideStatus {
  searching,
  matched,
  preReserved,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

class Ride {
  final String id;
  final String passengerId;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double destLat;
  final double destLng;
  final String destAddress;
  final RideStatus status;
  final VehicleSegment segment;
  final double distanceKm;
  final int estimatedMinutes;
  final String invoiceNo;
  final int personCount;
  final double perPersonFee;

  final double openingFee;
  final double distanceFee;
  final double segmentSurcharge;
  final double marketAdjustment;
  final double discount;
  final double grossTotal;
  final double commission;
  final double driverNet;
  final double marketRate;
  final String paymentMethod;

  final DateTime createdAt;
  final DateTime? scheduledPickupTime;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String legalHash;
  final String invoiceUrl;

  Ride({
    required this.id,
    required this.passengerId,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.destLat,
    required this.destLng,
    required this.destAddress,
    required this.status,
    this.segment = VehicleSegment.standard,
    this.distanceKm = 0,
    this.estimatedMinutes = 0,
    this.invoiceNo = '',
    this.personCount = 1,
    this.perPersonFee = 0,
    this.openingFee = 0,
    this.distanceFee = 0,
    this.segmentSurcharge = 0,
    this.marketAdjustment = 0,
    this.discount = 0,
    this.grossTotal = 0,
    this.commission = 0,
    this.driverNet = 0,
    this.marketRate = 1.0,
    this.paymentMethod = '',
    required this.createdAt,
    this.scheduledPickupTime,
    this.startedAt,
    this.completedAt,
    this.legalHash = '',
    this.invoiceUrl = '',
  });

  factory Ride.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Ride(
      id: doc.id,
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'],
      driverName: data['driverName'],
      driverPhone: data['driverPhone'],
      pickupLat: (data['pickupLat'] ?? 0).toDouble(),
      pickupLng: (data['pickupLng'] ?? 0).toDouble(),
      pickupAddress: data['pickupAddress'] ?? '',
      destLat: (data['destLat'] ?? 0).toDouble(),
      destLng: (data['destLng'] ?? 0).toDouble(),
      destAddress: data['destAddress'] ?? '',
      status: _parseStatus(data['status']),
      segment: _parseSegment(data['segment']),
      distanceKm: (data['distanceKm'] ?? 0).toDouble(),
      estimatedMinutes: data['estimatedMinutes'] ?? 0,
      invoiceNo: data['invoiceNo'] ?? '',
      personCount: data['personCount'] ?? 1,
      perPersonFee: (data['perPersonFee'] ?? 0).toDouble(),
      openingFee: (data['openingFee'] ?? 0).toDouble(),
      distanceFee: (data['distanceFee'] ?? 0).toDouble(),
      segmentSurcharge: (data['segmentSurcharge'] ?? 0).toDouble(),
      marketAdjustment: (data['marketAdjustment'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      grossTotal: (data['grossTotal'] ?? 0).toDouble(),
      commission: (data['commission'] ?? 0).toDouble(),
      driverNet: (data['driverNet'] ?? 0).toDouble(),
      marketRate: (data['marketRate'] ?? 1.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      createdAt: _parseDate(data['createdAt']),
      scheduledPickupTime: data['scheduledPickupTime'] != null ? _parseDate(data['scheduledPickupTime']) : null,
      startedAt: data['startedAt'] != null ? _parseDate(data['startedAt']) : null,
      completedAt: data['completedAt'] != null ? _parseDate(data['completedAt']) : null,
      legalHash: data['legalHash'] ?? '',
      invoiceUrl: data['invoiceUrl'] ?? '',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static RideStatus _parseStatus(String? status) {
    switch (status) {
      case 'matched': return RideStatus.matched;
      case 'pre_reserved': return RideStatus.preReserved;
      case 'driver_arriving': return RideStatus.driverArriving;
      case 'in_progress': return RideStatus.inProgress;
      case 'completed': return RideStatus.completed;
      case 'cancelled': return RideStatus.cancelled;
      default: return RideStatus.searching;
    }
  }

  static VehicleSegment _parseSegment(String? s) {
    switch (s) {
      case 'wide': return VehicleSegment.wide;
      case 'luxury': return VehicleSegment.luxury;
      default: return VehicleSegment.standard;
    }
  }

  String get statusText {
    switch (status) {
      case RideStatus.searching: return 'Sürücü Aranıyor';
      case RideStatus.matched: return 'Sürücü Bulundu';
      case RideStatus.preReserved: return 'Ön Rezervasyon';
      case RideStatus.driverArriving: return 'Sürücü Yolda';
      case RideStatus.inProgress: return 'Yolculuk Devam Ediyor';
      case RideStatus.completed: return 'Tamamlandı';
      case RideStatus.cancelled: return 'İptal Edildi';
    }
  }

  String get segmentLabel => SegmentConfig.get(segment).label;

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      'destLat': destLat,
      'destLng': destLng,
      'destAddress': destAddress,
      'status': _statusToString(status),
      'segment': segment.name,
      'distanceKm': distanceKm,
      'estimatedMinutes': estimatedMinutes,
      'invoiceNo': invoiceNo,
      'personCount': personCount,
      'perPersonFee': perPersonFee,
      'openingFee': openingFee,
      'distanceFee': distanceFee,
      'segmentSurcharge': segmentSurcharge,
      'marketAdjustment': marketAdjustment,
      'discount': discount,
      'grossTotal': grossTotal,
      'commission': commission,
      'driverNet': driverNet,
      'marketRate': marketRate,
      'paymentMethod': paymentMethod,
      'legalHash': legalHash,
      'invoiceUrl': invoiceUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'scheduledPickupTime': scheduledPickupTime != null ? Timestamp.fromDate(scheduledPickupTime!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  static String _statusToString(RideStatus s) {
    switch (s) {
      case RideStatus.preReserved: return 'pre_reserved';
      case RideStatus.driverArriving: return 'driver_arriving';
      case RideStatus.inProgress: return 'in_progress';
      default: return s.name;
    }
  }
}
