class Spool {

  double weight;

  Spool({
    required this.weight,
  });

  /// 🧵 JSON → Objekt

  factory Spool.fromJson(
      Map<String, dynamic> json) {

    return Spool(

      weight:
          (json['weight'] as num)
              .toDouble(),

    );

  }

  /// 🧵 Objekt → JSON

  Map<String, dynamic> toJson() {

    return {

      'weight': weight,

    };

  }

}