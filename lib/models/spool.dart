import 'dart:math';

class Spool {
  final String id;
  double weight;
  String storageLocation;
  String storagePosition;

  Spool({
    required this.weight,
    String? id,
    this.storageLocation = '',
    this.storagePosition = '',
  }) : id = (id != null && id.isNotEmpty) ? id : _newId();

  static final Random _random = Random();
  static int _idCounter = 0;

  static String _newId() {
    _idCounter++;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomValue = _random.nextInt(1 << 31);
    return '$timestamp-$randomValue-$_idCounter';
  }

  factory Spool.fromJson(Map<String, dynamic> json) {
    return Spool(
      weight: (json['weight'] as num).toDouble(),
      id: json['id']?.toString(),
      storageLocation: json['storageLocation']?.toString() ?? '',
      storagePosition: json['storagePosition']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'storageLocation': storageLocation,
      'storagePosition': storagePosition,
    };
  }
}
