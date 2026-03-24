import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

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
  }

  // ================= GETTERS =================

  static List<String> getBrands() {
    final brands = _catalog.map((e) => e.brand).toSet().toList();
    brands.sort();
    return brands;
  }

  static List<String> getMaterials(String brand) {
    final materials = _catalog
        .where((e) => e.brand == brand)
        .map((e) => e.material)
        .toSet()
        .toList();

    materials.sort();
    return materials;
  }

  static List<String> getVariants(String brand, String material) {
    final variants = _catalog
        .where((e) => e.brand == brand && e.material == material)
        .map((e) => e.variant)
        .toSet()
        .toList();

    variants.sort();
    return variants;
  }

  static List<String> getColors(String brand, String material, String variant) {
    final colors = _catalog
        .where((e) =>
            e.brand == brand &&
            e.material == material &&
            e.variant == variant)
        .map((e) => e.color)
        .toSet()
        .toList();

    colors.sort();
    return colors;
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
}