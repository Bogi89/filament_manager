class Printer {
  String name;
  String brand;
  double averageWatt;
  String notes;
  bool isCustom;

  Printer({
    required this.name,
    required this.brand,
    required this.averageWatt,
    this.notes = "",
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'averageWatt': averageWatt,
      'notes': notes,
      'isCustom': isCustom,
    };
  }

  factory Printer.fromJson(Map<String, dynamic> json) {
    return Printer(
      name: json['name'],
      brand: json['brand'],
      averageWatt: (json['averageWatt'] as num).toDouble(),
      notes: json['notes'] ?? "",
      isCustom: json['isCustom'] ?? false,
    );
  }

  @override
  String toString() {
    return "$brand $name";
  }
}
