class Spool {
  double weight;

  String storageLocation;
  String storagePosition;

  Spool({
    required this.weight,
    this.storageLocation = '',
    this.storagePosition = '',
  });

  /// 🧵 JSON → Objekt
  factory Spool.fromJson(Map<String, dynamic> json) {
    return Spool(
      weight: (json['weight'] as num).toDouble(),
      storageLocation: json['storageLocation']?.toString() ?? '',
      storagePosition: json['storagePosition']?.toString() ?? '',
    );
  }

  /// 🧵 Objekt → JSON
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'storageLocation': storageLocation,
      'storagePosition': storagePosition,
    };
  }
}
