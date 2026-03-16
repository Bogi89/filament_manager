import 'dart:convert';
import 'package:flutter/services.dart';

class FilamentCatalogService {

  static List<Map<String, String>> _catalog = [];
  static bool _loaded = false;

  static Future<void> loadCatalog() async {

    if (_loaded) return;

    final raw = await rootBundle.loadString(
        "assets/data/filament_catalog.csv");

    final lines = const LineSplitter().convert(raw);

    for (int i = 1; i < lines.length; i++) {

      final line = lines[i];

      List<String> parts;

      if (line.contains(";")) {
        parts = line.split(";");
      } else {
        parts = line.split(",");
      }

      if (parts.length < 4) continue;

      _catalog.add({
        "brand": parts[0].trim(),
        "material": parts[1].trim(),
        "variant": parts[2].trim(),
        "color": parts[3].trim(),
      });
    }

    _loaded = true;
  }

  static List<String> getBrands() {

    final brands =
        _catalog.map((e) => e["brand"]!).toSet().toList();

    brands.sort();

    return brands;
  }

  static List<String> getMaterials(String brand) {

    final materials = _catalog
        .where((e) => e["brand"] == brand)
        .map((e) => e["material"]!)
        .toSet()
        .toList();

    materials.sort();

    return materials;
  }

  static List<String> getVariants(String brand, String material) {

    final variants = _catalog
        .where((e) =>
            e["brand"] == brand &&
            e["material"] == material)
        .map((e) => e["variant"]!)
        .toSet()
        .toList();

    variants.sort();

    return variants;
  }

  static List<String> getColors(
      String brand,
      String material,
      String variant) {

    final colors = _catalog
        .where((e) =>
            e["brand"] == brand &&
            e["material"] == material &&
            e["variant"] == variant)
        .map((e) => e["color"]!)
        .toSet()
        .toList();

    colors.sort();

    return colors;
  }
}
