import 'package:cloud_firestore/cloud_firestore.dart';

class HubOwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int calculateScore({required int referredDrivers, required int completedRides}) {
    return referredDrivers + ((completedRides ~/ 1000) * 5);
  }

  double calculateEquityRate(int score) {
    if (score >= 200) return 0.0005; // %0.05
    if (score >= 50) return 0.0001; // %0.01
    return 0.0;
  }

  Future<void> upsertHubOwner({
    required String ownerId,
    required String name,
    required int referredDrivers,
    required int completedRides,
  }) async {
    final score = calculateScore(
      referredDrivers: referredDrivers,
      completedRides: completedRides,
    );

    final equityRate = calculateEquityRate(score);

    await _firestore.collection('hub_owners').doc(ownerId).set({
      'name': name,
      'referredDrivers': referredDrivers,
      'completedRides': completedRides,
      'score': score,
      'equityRate': equityRate,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
