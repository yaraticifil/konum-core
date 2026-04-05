import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverStatus { pending, approved, rejected, suspended }

class Driver {
  final String id;
  final String name;
  final String phone;
  final DriverStatus status;
  final DateTime createdAt;
  final String iban;
  final double walletBalance;

  // Add uid getter as an alias for id to fix UI references
  String get uid => id;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.iban = '',
    this.walletBalance = 0.0,
  });

  factory Driver.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Driver(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      status: _parseStatus(data['status']),
      createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : (data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now()),
      iban: data['iban'] ?? '',
      walletBalance: (data['walletBalance'] ?? 0).toDouble(),
    );
  }

  static DriverStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved': return DriverStatus.approved;
      case 'rejected': return DriverStatus.rejected;
      case 'suspended': return DriverStatus.suspended;
      default: return DriverStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'status': status.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'iban': iban,
      'walletBalance': walletBalance,
    };
  }

  String get statusText {
    switch (status) {
      case DriverStatus.approved: return 'Onaylandı';
      case DriverStatus.rejected: return 'Reddedildi';
      case DriverStatus.suspended: return 'Askıya Alındı';
      default: return 'Beklemede';
    }
  }
}
