class FilamentColor {
  final String name;
  final String hex;
  final bool isCustom;

  const FilamentColor({
    required this.name,
    required this.hex,
    this.isCustom = false,
  });

  factory FilamentColor.fromJson(Map<String, dynamic> json) {
    return FilamentColor(
      name: json['name'] ?? '',
      hex: json['hex'] ?? '#000000',
      isCustom: json['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hex': hex,
      'isCustom': isCustom,
    };
  }
}