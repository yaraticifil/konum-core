import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createEArsivInvoice({
    required String rideId,
    required String driverId,
    required String passengerId,
    required double grossTotal,
  }) async {
    final vatAmount = grossTotal * 0.20;
    final netAmount = grossTotal - vatAmount;

    final invoiceRef = await _firestore.collection('invoices').add({
      'rideId': rideId,
      'driverId': driverId,
      'passengerId': passengerId,
      'netAmount': netAmount,
      'vatAmount': vatAmount,
      'grossAmount': grossTotal,
      'vatRate': 0.20,
      'provider': 'mock_earsiv',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'generated',
      'permanentUrl': 'https://invoice.konum.app/e-arsiv/$rideId',
    });

    return 'https://invoice.konum.app/e-arsiv/${invoiceRef.id}';
  }
}
