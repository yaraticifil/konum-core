import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class InsuranceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _endpoint = String.fromEnvironment('SEAT_INSURANCE_API_URL',
      defaultValue: 'https://insurance.konum.app/mock/policies');
  static const _token = String.fromEnvironment('SEAT_INSURANCE_API_TOKEN',
      defaultValue: 'dev-token');

  Future<void> issueSeatInsurance({
    required String rideId,
    required String driverId,
    required String passengerId,
    required DateTime scheduledPickupTime,
  }) async {
    final payload = {
      'rideId': rideId,
      'driverId': driverId,
      'passengerId': passengerId,
      'scheduledPickupTime': scheduledPickupTime.toIso8601String(),
      'policyType': 'seat_accident',
      'provider': 'mock_allianz_aksigorta',
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      await _firestore.collection('insurance_policies').doc(rideId).set({
        ...payload,
        'statusCode': response.statusCode,
        'responseBody': response.body,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await _firestore.collection('insurance_policies').doc(rideId).set({
        ...payload,
        'status': 'failed',
        'error': e.toString(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      rethrow;
    }
  }
}
