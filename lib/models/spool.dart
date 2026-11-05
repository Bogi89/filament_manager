import 'dart:math';

class Spool {
  final String id;
  double weight;
  double? price;
  String storageLocation;
  String storagePosition;

  Spool({
    required this.weight,
    this.price,
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

  /// Gibt den individuellen Spulenpreis zurück.
  ///
  /// Bei älteren Spulen ohne eigenen Preis wird der
  /// bisherige Filamentpreis als Standard verwendet.
  double effectivePrice(double filamentPrice) {
    return price ?? filamentPrice;
  }

  factory Spool.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];

    return Spool(
      id: json['id']?.toString(),
      weight: (json['weight'] as num).toDouble(),
      price: rawPrice is num ? rawPrice.toDouble() : null,
      storageLocation: json['storageLocation']?.toString() ?? '',
      storagePosition: json['storagePosition']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      if (price != null) 'price': price,
      'storageLocation': storageLocation,
      'storagePosition': storagePosition,
    };
  }
}
