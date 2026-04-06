class HubOwnerModel {
  final String id;
  final String name;
  final int referredDrivers;
  final int completedRides;
  final int score;
  final double equityRate;

  const HubOwnerModel({
    required this.id,
    required this.name,
    required this.referredDrivers,
    required this.completedRides,
    required this.score,
    required this.equityRate,
  });

  factory HubOwnerModel.fromMap(String id, Map<String, dynamic> data) {
    return HubOwnerModel(
      id: id,
      name: data['name'] ?? '',
      referredDrivers: data['referredDrivers'] ?? 0,
      completedRides: data['completedRides'] ?? 0,
      score: data['score'] ?? 0,
      equityRate: (data['equityRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'referredDrivers': referredDrivers,
      'completedRides': completedRides,
      'score': score,
      'equityRate': equityRate,
    };
  }
}
