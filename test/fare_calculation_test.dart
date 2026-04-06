import 'package:flutter_test/flutter_test.dart';
import 'package:konum_app/services/ride_service.dart';
import 'mock_firestore.dart';

void main() {
  test('Fare calculation should correctly split funds', () {
    final service = RideService(firestore: MockFirestore());
    final fare = service.calculateFare(
      distanceKm: 10.0,
      segment: VehicleSegment.standard,
      personCount: 1,
    );

    // Opening 100 + Distance (10 * 6 * 1.0) = 160
    expect(fare.grossTotal, 160.0);
    expect(fare.commission, 19.2); // 160 * 0.12
    expect(fare.legalFund, 6.4);    // 160 * 0.04
    expect(fare.balanceFund, 4.8);  // 160 * 0.03
    expect(fare.platformShare, 8.0); // 160 * 0.05
    expect(fare.legalFund + fare.balanceFund + fare.platformShare, closeTo(fare.commission, 0.001));
  });
}
