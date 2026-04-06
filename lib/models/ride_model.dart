import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ride_service.dart';
import '../utils/date_time_serializer.dart';

enum RideStatus { searching, matched, preReserved, driverArriving, inProgress, completed, cancelled }

class Ride {
  final String id;
  final String passengerId;
  final String? driverId, driverName, driverPhone;
  final double pickupLat, pickupLng;
  final String pickupAddress;
  final double destLat, destLng;
  final String destAddress;
  final RideStatus status;
  final VehicleSegment segment;
  final double distanceKm;
  final int estimatedMinutes;
  final String invoiceNo;
  final int personCount;
  final double perPersonFee;
  final double openingFee, distanceFee, segmentSurcharge, marketAdjustment, discount, grossTotal, commission, driverNet, marketRate;
  final double legalFund, balanceFund, platformShare;
  final String paymentMethod;
  final String? legalHash, invoiceUrl;
  final DateTime createdAt;
  final DateTime? scheduledPickupTime, startedAt, completedAt;

  Ride({
    required this.id, required this.passengerId, this.driverId, this.driverName, this.driverPhone,
    required this.pickupLat, required this.pickupLng, required this.pickupAddress,
    required this.destLat, required this.destLng, required this.destAddress,
    required this.status, this.segment = VehicleSegment.standard, this.distanceKm = 0,
    this.estimatedMinutes = 0, this.invoiceNo = '', this.personCount = 1, this.perPersonFee = 0,
    this.openingFee = 0, this.distanceFee = 0, this.segmentSurcharge = 0, this.marketAdjustment = 0,
    this.discount = 0, this.grossTotal = 0, this.commission = 0, this.driverNet = 0, this.marketRate = 1.0,
    this.legalFund = 0, this.balanceFund = 0, this.platformShare = 0,
    this.paymentMethod = '', this.legalHash, this.invoiceUrl,
    required this.createdAt, this.scheduledPickupTime, this.startedAt, this.completedAt,
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
      legalFund: (data['legalFund'] ?? 0).toDouble(),
      balanceFund: (data['balanceFund'] ?? 0).toDouble(),
      platformShare: (data['platformShare'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      legalHash: data['legalHash'],
      invoiceUrl: data['invoiceUrl'],
      createdAt: DateTimeSerializer.fromFirestore(data['createdAt']),
      scheduledPickupTime: data['scheduledPickupTime'] != null ? DateTimeSerializer.fromFirestore(data['scheduledPickupTime']) : null,
      startedAt: data['startedAt'] != null ? DateTimeSerializer.fromFirestore(data['startedAt']) : null,
      completedAt: data['completedAt'] != null ? DateTimeSerializer.fromFirestore(data['completedAt']) : null,
    );
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

  String get segmentLabel => SegmentConfig.get(segment).label;
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

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId, 'driverId': driverId, 'driverName': driverName, 'driverPhone': driverPhone,
      'pickupLat': pickupLat, 'pickupLng': pickupLng, 'pickupAddress': pickupAddress,
      'destLat': destLat, 'destLng': destLng, 'destAddress': destAddress,
      'status': status.name, 'segment': segment.name, 'distanceKm': distanceKm,
      'estimatedMinutes': estimatedMinutes, 'invoiceNo': invoiceNo,
      'openingFee': openingFee, 'distanceFee': distanceFee, 'grossTotal': grossTotal,
      'commission': commission, 'driverNet': driverNet, 'legalFund': legalFund,
      'balanceFund': balanceFund, 'platformShare': platformShare,
      'createdAt': DateTimeSerializer.toTimestamp(createdAt),
      'scheduledPickupTime': scheduledPickupTime != null ? DateTimeSerializer.toTimestamp(scheduledPickupTime!) : null,
      'startedAt': startedAt != null ? DateTimeSerializer.toTimestamp(startedAt!) : null,
      'completedAt': completedAt != null ? DateTimeSerializer.toTimestamp(completedAt!) : null,
    };
  }
}
