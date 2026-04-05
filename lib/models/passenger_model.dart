import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/date_time_serializer.dart';

class Passenger {
  final String id;
  final String name;
  final String phone;
  final String email;
  final DateTime createdAt;

  Passenger({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.createdAt,
  });

  factory Passenger.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Passenger(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      createdAt: DateTimeSerializer.fromFirestore(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'role': 'passenger',
    };
  }
}
