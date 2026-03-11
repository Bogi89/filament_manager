class FilamentCatalog {

  final String brand;
  final String material;
  final String variant;
  final String color;

  FilamentCatalog({
    required this.brand,
    required this.material,
    required this.variant,
    required this.color,
  });

  factory FilamentCatalog.fromJson(Map<String, dynamic> json) {

    return FilamentCatalog(
      brand: json['brand'],
      material: json['material'],
      variant: json['variant'],
      color: json['color'],
    );
  }
}