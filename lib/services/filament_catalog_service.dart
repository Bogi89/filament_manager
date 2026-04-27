import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class FilamentCatalogItem {
  final String brand;
  final String material;
  final String variant;
  final String color;
  final String? hex;

  FilamentCatalogItem({
    required this.brand,
    required this.material,
    required this.variant,
    required this.color,
    required this.hex,
  });
}

class FilamentCatalogService {
  static final List<FilamentCatalogItem> _catalog = [];

  // 🆕 Benutzerdefinierte Materialien pro Hersteller
static final Map<String, List<String>> _customMaterials = {};

  static bool _loaded = false;

  // ================= LOAD =================

  static Future<void> loadCatalog() async {
    if (_loaded) return;

    _catalog.clear();

    final raw = await rootBundle.loadString('assets/data/filament_catalog.csv');
    final lines = const LineSplitter().convert(raw);

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(';');

      if (parts.length < 4) continue;

      final brand = parts[0].trim();
      final material = parts[1].trim();
      final variant = parts[2].trim();
      final color = parts[3].trim();
      final hex = parts.length >= 5 ? parts[4].trim() : null;

      _catalog.add(
        FilamentCatalogItem(
          brand: brand,
          material: material,
          variant: variant,
          color: color,
          hex: hex,
        ),
      );
    }

    _loaded = true;

await loadCustomColors();
  }

  // ==================== GETTERS ====================

static final List<String> _customBrands = [];

static void addCustomBrand(String brand) {

  if (!_customBrands.contains(brand)) {

    _customBrands.add(brand);

  }

}

static List<String> getBrands() {

  final brands =
      _catalog
          .map((e) => e.brand)
          .toSet()
          .toList();

  final allBrands = [

    ...brands,
    ..._customBrands,

  ];

  allBrands.sort();

  return allBrands;

}

  static List<String> getMaterials(String brand) {
  final materials = _catalog
      .where((e) => e.brand == brand)
      .map((e) => e.material)
      .toSet()
      .toList();

  // 🆕 eigene Materialien hinzufügen
  if (_customMaterials.containsKey(brand)) {
    materials.addAll(_customMaterials[brand]!);
  }

  // doppelte entfernen
  final unique = materials.toSet().toList();

  unique.sort();
  return unique;
}

static List<String> getColorsForVariant(
  String brand,
  String material,
  String variant,
) {
  final colors = _catalog
      .where((item) =>
          item.brand == brand &&
          item.material == material &&
          item.variant == variant)
      .map((item) => item.color)
      .toSet()
      .toList();

  colors.sort();

  if (!colors.contains("Unknown")) {
    colors.insert(0, "Unknown");
  }

  return colors;
}

static void addCustomMaterial(
  String brand,
  String material,
) {
  if (!_customMaterials.containsKey(brand)) {
    _customMaterials[brand] = [];
  }

  _customMaterials[brand]!.add(material);
}

// 🆕 Benutzerdefinierte Varianten pro Brand + Material
static final Map<String, Map<String, List<String>>> _customVariants = {};

static void addCustomVariant(
  String brand,
  String material,
  String variant,
) {
  if (!_customVariants.containsKey(brand)) {
    _customVariants[brand] = {};
  }

  if (!_customVariants[brand]!.containsKey(material)) {
    _customVariants[brand]![material] = [];
  }

  _customVariants[brand]![material]!.add(variant);
}

// 🆕 Benutzerdefinierte Farben pro Brand + Material + Variant
static final Map<String,
    Map<String,
        Map<String,
            List<String>>>> _customColors = {};

static void addCustomColor(
  String brand,
  String material,
  String variant,
  String color,
  Color pickedColor,
) {

  if (!_customColors.containsKey(brand)) {
    _customColors[brand] = {};
  }

  if (!_customColors[brand]!.containsKey(material)) {
    _customColors[brand]![material] = {};
  }

  if (!_customColors[brand]![material]!
      .containsKey(variant)) {
    _customColors[brand]![material]![variant] = [];
  }

      /// 🔥 NEU: Farbe mit HEX in Catalog eintragen

final hex =
    pickedColor.value
        .toRadixString(16)
        .substring(2)
        .toUpperCase();

_customColors[brand]![material]![variant]!
    .add("$color|$hex");

final exists = _catalog.any((e) =>
    e.brand == brand &&
    e.material == material &&
    e.variant == variant &&
    e.color == color);

if (!exists) {
  _catalog.add(
    FilamentCatalogItem(
      brand: brand,
      material: material,
      variant: variant,
      color: color,
      hex: hex,
    ),
  );
}

}

  static List<String> getVariants(String brand, String material) {
  final variants = _catalog
      .where((e) => e.brand == brand && e.material == material)
      .map((e) => e.variant)
      .toSet()
      .toList();

  // 🆕 eigene Varianten hinzufügen
  if (_customVariants.containsKey(brand) &&
      _customVariants[brand]!.containsKey(material)) {

    variants.addAll(
      _customVariants[brand]![material]!,
    );
  }

  // doppelte entfernen
  final unique = variants.toSet().toList();

  unique.sort();
  return unique;
}

  static List<String> getColors(
  String brand,
  String material,
  String variant,
) {
  final colors = _catalog
      .where((e) =>
          e.brand == brand &&
          e.material == material &&
          e.variant == variant)
      .map((e) => e.color)
      .toSet()
      .toList();

  // 🆕 eigene Farben hinzufügen
  if (_customColors.containsKey(brand) &&
      _customColors[brand]!.containsKey(material) &&
      _customColors[brand]![material]!
          .containsKey(variant)) {

    colors.addAll(
      _customColors[brand]![material]![variant]!,
    );
  }

  // doppelte entfernen
  final unique = colors.toSet().toList();

  unique.sort();
  return unique;
}

  // ================= HEX → COLOR =================

  static List<Color> getColorsFromHex(
      String brand,
      String material,
      String variant,
      String colorName) {
    final item = _catalog.firstWhere(
      (e) =>
          e.brand.trim() == brand.trim() &&
          e.material.trim() == material.trim() &&
          e.variant.trim() == variant.trim() &&
          e.color.trim().toLowerCase() == colorName.trim().toLowerCase(),
      orElse: () => FilamentCatalogItem(
        brand: '',
        material: '',
        variant: '',
        color: '',
        hex: '',
      ),
    );

    if (item.hex == null || item.hex!.isEmpty) {
      return [Colors.grey];
    }

    final parts = item.hex!.split('+');

    List<Color> result = [];

    for (final hex in parts) {
      try {
        result.add(_hexToColor(hex));
      } catch (_) {
        result.add(Colors.grey);
      }
    }

    return result;
  }

  static Color _hexToColor(String hex) {
    String clean = hex.replaceAll('#', '').trim();

    if (clean.length == 6) {
      clean = 'FF$clean';
    }

    return Color(int.parse(clean, radix: 16));
  }
  
  // ================= HEX → NAME =================

static String findColorNameByHex(String hex) {

  String clean =
      hex.replaceAll('#', '').toLowerCase();

  for (final item in _catalog) {

    if (item.hex == null) continue;

    final parts =
        item.hex!
            .toLowerCase()
            .replaceAll('#', '')
            .split('+');

    for (final p in parts) {

      if (p.trim() == clean.trim()) {

        return item.color;

      }

    }

  }

  return "Unknown";
}

/// 🔥 Custom Colors laden
/// 🔥 Custom Colors laden (Web + App kompatibel)
static Future<void> loadCustomColors() async {

  final prefs =
      await SharedPreferences.getInstance();

  final jsonString =
      prefs.getString('custom_colors');

  if (jsonString == null) return;

  final Map<String, dynamic> data =
      jsonDecode(jsonString);

  data.forEach((brand, materials) {

    _customColors[brand] = {};

    (materials as Map<String, dynamic>)
        .forEach((material, variants) {

      _customColors[brand]![material] = {};

      (variants as Map<String, dynamic>)
          .forEach((variant, colors) {

        _customColors[brand]![material]![variant] = [];

for (final entry in colors) {

  if (entry.contains('|')) {

    final parts = entry.split('|');

    final name = parts[0];
    final hex = parts[1];

    print("LOAD COLOR: $name -> $hex");

    _customColors[brand]![material]![variant]!
        .add(name);

    final exists = _catalog.any((e) =>
        e.brand == brand &&
        e.material == material &&
        e.variant == variant &&
        e.color == name);

    if (!exists) {
      _catalog.add(
        FilamentCatalogItem(
          brand: brand,
          material: material,
          variant: variant,
          color: name,
          hex: hex,
        ),
      );
    }

  } else {

    _customColors[brand]![material]![variant]!
        .add(entry);

  }
}

            for (final color in colors) {

  // Prüfen ob Farbe schon im Catalog ist
  final exists = _catalog.any((e) =>
      e.brand == brand &&
      e.material == material &&
      e.variant == variant &&
      e.color == color);

  if (!exists) {

  }

}     

      });

    });

  });

}

/// 🔥 NEU — Custom Colors speichern
static Future<void> saveCustomColors() async {

  final Map<String, dynamic> data = {};

  _customColors.forEach((brand, materials) {

    data[brand] = {};

    materials.forEach((material, variants) {

      data[brand][material] = {};

      variants.forEach((variant, colors) {

        data[brand][material][variant] = colors;

      });

    });

  });

  final jsonString = jsonEncode(data);

final prefs =
    await SharedPreferences.getInstance();

await prefs.setString(
    'custom_colors',
    jsonString);

}

}