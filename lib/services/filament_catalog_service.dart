import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilamentCatalogItem {
  final String brand;
  final String material;
  final String variant;
  final String color;
  final String? hex;

  /// Optionale Materialdichte in g/cm³.
  final double? density;

  FilamentCatalogItem({
    required this.brand,
    required this.material,
    required this.variant,
    required this.color,
    required this.hex,
    this.density,
  });
}

class FilamentCatalogService {
  static final List<FilamentCatalogItem> _catalog = [];

  // Benutzerdefinierte Materialien pro Hersteller.
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

      // Optionale Materialdichte in g/cm³ (Spalte 6).
      final densityText = parts.length >= 6 ? parts[5].trim() : '';

      final double? density = densityText.isEmpty
          ? null
          : double.tryParse(densityText.replaceAll(',', '.'));

      _catalog.add(
        FilamentCatalogItem(
          brand: brand,
          material: material,
          variant: variant,
          color: color,
          hex: hex,
          density: density,
        ),
      );
    }

    await loadCustomColors();

    _loaded = true;
  }

  // ================= GETTERS =================

  static final List<String> _customBrands = [];

  static void addCustomBrand(String brand) {
    if (!_customBrands.contains(brand)) {
      _customBrands.add(brand);
    }
  }

  static List<String> getBrands() {
    final brands = _catalog.map((e) => e.brand).toSet().toList();

    final allBrands = [...brands, ..._customBrands];

    allBrands.sort();

    return allBrands;
  }

  // ================= DICHTE =================

  /// Vereinheitlicht Schreibweisen für die Dichtesuche.
  ///
  /// Die ursprünglichen Katalogbezeichnungen werden
  /// dadurch nicht verändert.
  static String _normalizeDensityText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Vereinheitlicht die Variantenbezeichnungen.
  ///
  /// Standard und Basic gelten bei der Dichtesuche
  /// als gleichwertige Bezeichnungen.
  static String _normalizeDensityVariant(String value) {
    final normalized = _normalizeDensityText(value);

    if (normalized == 'standard' || normalized == 'basic') {
      return 'basic';
    }

    return normalized;
  }

  /// Liefert alle Katalogeinträge, die zu Hersteller,
  /// Material und Variante passen.
  ///
  /// Groß- und Kleinschreibung sowie zusätzliche
  /// Leerzeichen werden ignoriert.
  static List<FilamentCatalogItem> _getDensityMatches(
    String brand,
    String material,
    String variant,
  ) {
    final normalizedBrand = _normalizeDensityText(brand);
    final normalizedMaterial = _normalizeDensityText(material);
    final normalizedVariant = _normalizeDensityVariant(variant);

    return _catalog.where((item) {
      return _normalizeDensityText(item.brand) == normalizedBrand &&
          _normalizeDensityText(item.material) == normalizedMaterial &&
          _normalizeDensityVariant(item.variant) == normalizedVariant;
    }).toList();
  }

  /// Liefert einen Dichtewert nur dann, wenn sämtliche
  /// übergebenen gültigen Werte übereinstimmen.
  ///
  /// Fehlende und ungültige Dichten werden ignoriert.
  static double? _getUniqueDensity(Iterable<FilamentCatalogItem> items) {
    final densities = items
        .map((item) => item.density)
        .whereType<double>()
        .where((value) => value.isFinite && value > 0)
        .toSet();

    if (densities.length != 1) {
      return null;
    }

    return densities.first;
  }

  /// Liefert die Materialdichte in g/cm³.
  ///
  /// Ohne Farbangabe wird nur dann ein Wert geliefert,
  /// wenn Hersteller, Material und Variante insgesamt
  /// einen eindeutigen Dichtewert besitzen.
  ///
  /// Optional können Farbnamen übergeben werden.
  /// Diese werden bei widersprüchlichen Dichten zur
  /// genaueren Zuordnung verwendet.
  ///
  /// Die Farbsuche liefert nur dann einen Wert,
  /// wenn die passenden Farbeinträge eindeutig sind.
  static double? getDensity(
    String brand,
    String material,
    String variant, {
    List<String>? colorNames,
  }) {
    final matchingItems = _getDensityMatches(brand, material, variant);

    if (matchingItems.isEmpty) {
      return null;
    }

    // Zunächst prüfen, ob alle vorhandenen Dichten
    // für diese Variante übereinstimmen.
    final uniqueDensity = _getUniqueDensity(matchingItems);

    if (uniqueDensity != null) {
      return uniqueDensity;
    }

    // Bei unterschiedlichen Dichten kann die Farbe
    // eine genauere Zuordnung ermöglichen.
    if (colorNames == null || colorNames.isEmpty) {
      return null;
    }

    final normalizedColors = colorNames
        .map(_normalizeDensityText)
        .where(
          (name) => name.isNotEmpty && name != 'unknown' && name != 'unbekannt',
        )
        .toSet();

    if (normalizedColors.isEmpty) {
      return null;
    }

    final colorMatches = matchingItems.where((item) {
      return normalizedColors.contains(_normalizeDensityText(item.color));
    }).toList();

    if (colorMatches.isEmpty) {
      return null;
    }

    // Alle angefragten Farben müssen gefunden werden.
    // Sonst könnte bei einem mehrfarbigen Filament
    // nur ein Teil des Produkts zugeordnet werden.
    final matchedColorNames = colorMatches
        .map((item) => _normalizeDensityText(item.color))
        .toSet();

    if (!matchedColorNames.containsAll(normalizedColors)) {
      return null;
    }

    // Fehlt bei einer passenden Farbe die Dichte,
    // wird keine ungesicherte Zuordnung vorgenommen.
    if (colorMatches.any(
      (item) =>
          item.density == null || !item.density!.isFinite || item.density! <= 0,
    )) {
      return null;
    }

    return _getUniqueDensity(colorMatches);
  }

  static List<String> getMaterials(String brand) {
    final materials = _catalog
        .where((e) => e.brand == brand)
        .map((e) => e.material)
        .toSet()
        .toList();

    // Eigene Materialien hinzufügen.
    if (_customMaterials.containsKey(brand)) {
      materials.addAll(_customMaterials[brand]!);
    }

    // Doppelte entfernen.
    final unique = materials.toSet().toList();

    return unique;
  }

  static List<String> getColorsForVariant(
    String brand,
    String material,
    String variant,
  ) {
    final colors = _catalog
        .where(
          (item) =>
              item.brand == brand &&
              item.material == material &&
              item.variant == variant,
        )
        .map((item) => item.color)
        .toSet()
        .toList();

    colors.sort();

    return colors;
  }

  static void addCustomMaterial(String brand, String material) {
    if (!_customMaterials.containsKey(brand)) {
      _customMaterials[brand] = [];
    }

    _customMaterials[brand]!.add(material);
  }

  // Benutzerdefinierte Varianten pro Brand + Material.
  static final Map<String, Map<String, List<String>>> _customVariants = {};

  static void addCustomVariant(String brand, String material, String variant) {
    if (!_customVariants.containsKey(brand)) {
      _customVariants[brand] = {};
    }

    if (!_customVariants[brand]!.containsKey(material)) {
      _customVariants[brand]![material] = [];
    }

    _customVariants[brand]![material]!.add(variant);
  }

  // Benutzerdefinierte Farben pro Brand + Material + Variant.
  static final Map<String, Map<String, Map<String, List<String>>>>
  _customColors = {};

  static void addCustomColor(
    String brand,
    String material,
    String variant,
    String color,
    String hex,
  ) {
    if (!_customColors.containsKey(brand)) {
      _customColors[brand] = {};
    }

    if (!_customColors[brand]!.containsKey(material)) {
      _customColors[brand]![material] = {};
    }

    if (!_customColors[brand]![material]!.containsKey(variant)) {
      _customColors[brand]![material]![variant] = [];
    }

    // Nur den Farbnamen speichern (ohne HEX).
    if (!_customColors[brand]![material]![variant]!.contains(color)) {
      _customColors[brand]![material]![variant]!.add(color);
    }

    // HEX im Catalog speichern.
    final exists = _catalog.any(
      (e) =>
          e.brand == brand &&
          e.material == material &&
          e.variant == variant &&
          e.color == color,
    );

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

    saveCustomColors();
  }

  static List<String> getVariants(String brand, String material) {
    final variants = _catalog
        .where((e) => e.brand == brand && e.material == material)
        .map((e) => e.variant)
        .toSet()
        .toList();

    // Eigene Varianten hinzufügen.
    if (_customVariants.containsKey(brand) &&
        _customVariants[brand]!.containsKey(material)) {
      variants.addAll(_customVariants[brand]![material]!);
    }

    // Doppelte entfernen.
    final unique = variants.toSet().toList();

    return unique;
  }

  static List<String> getColors(String brand, String material, String variant) {
    final colors = _catalog
        .where(
          (e) =>
              e.brand == brand &&
              e.material == material &&
              e.variant == variant,
        )
        .map((e) => e.color)
        .toSet()
        .toList();

    // Eigene Farben hinzufügen.
    if (_customColors.containsKey(brand) &&
        _customColors[brand]!.containsKey(material) &&
        _customColors[brand]![material]!.containsKey(variant)) {
      colors.addAll(_customColors[brand]![material]![variant]!);
    }

    // Doppelte entfernen.
    final unique = colors.toSet().toList();

    return unique;
  }

  // ================= HEX → COLOR =================

  static List<Color>? tryGetColorsFromHex(
    String brand,
    String material,
    String variant,
    String colorName,
  ) {
    for (final item in _catalog) {
      if (item.brand.trim() != brand.trim() ||
          item.material.trim() != material.trim() ||
          item.variant.trim() != variant.trim() ||
          item.color.trim().toLowerCase() != colorName.trim().toLowerCase()) {
        continue;
      }

      final hex = item.hex;

      if (hex == null || hex.trim().isEmpty) {
        return null;
      }

      final parts = hex
          .split(RegExp(r'[+,;]'))
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.isEmpty) return null;

      final result = <Color>[];

      try {
        for (final part in parts) {
          result.add(_hexToColor(part));
        }
      } catch (_) {
        return null;
      }

      return result.isEmpty ? null : result;
    }

    return null;
  }

  static List<Color> getColorsFromHex(
    String brand,
    String material,
    String variant,
    String colorName,
  ) {
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

    final parts = item.hex!
        .split(RegExp(r'[+,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

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

    final value = int.parse(clean, radix: 16);

    return Color(value);
  }

  // ================= HEX → NAME =================

  static String findColorNameByHex(String hex) {
    String clean = hex.replaceAll('#', '').toLowerCase();

    for (final item in _catalog) {
      if (item.hex == null) continue;

      final parts = item.hex!.toLowerCase().replaceAll('#', '').split('+');

      for (final p in parts) {
        if (p.trim() == clean.trim()) {
          return item.color;
        }
      }
    }

    return "Unknown";
  }

  // ================= CUSTOM COLORS =================

  /// Custom Colors laden (Web + App kompatibel).
  static Future<void> loadCustomColors() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString('custom_colors');

    if (jsonString == null) return;

    final decoded = jsonDecode(jsonString);

    // Altes Listenformat des CustomColorService:
    // Nicht als verschachtelten Katalog interpretieren.
    if (decoded is List) {
      return;
    }

    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final Map<String, dynamic> data = decoded;

    data.forEach((brand, materials) {
      _customColors[brand] = {};

      (materials as Map<String, dynamic>).forEach((material, variants) {
        _customColors[brand]![material] = {};

        (variants as Map<String, dynamic>).forEach((variant, colors) {
          _customColors[brand]![material]![variant] = [];

          for (final entry in colors) {
            if (entry.contains('|')) {
              final parts = entry.split('|');

              final name = parts[0];
              final hex = parts[1];

              _customColors[brand]![material]![variant]!.add(name);

              final exists = _catalog.any(
                (e) =>
                    e.brand == brand &&
                    e.material == material &&
                    e.variant == variant &&
                    e.color == name,
              );

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
              _customColors[brand]![material]![variant]!.add(entry);
            }
          }
        });
      });
    });
  }

  /// Custom Colors korrekt mit HEX speichern.
  static Future<void> saveCustomColors() async {
    final Map<String, dynamic> data = {};

    _customColors.forEach((brand, materials) {
      data[brand] = {};

      materials.forEach((material, variants) {
        data[brand][material] = {};

        variants.forEach((variant, colors) {
          final List<String> savedColors = [];

          for (final colorName in colors) {
            // HEX aus Catalog holen.
            final item = _catalog.firstWhere(
              (e) =>
                  e.brand == brand &&
                  e.material == material &&
                  e.variant == variant &&
                  e.color == colorName,
              orElse: () => FilamentCatalogItem(
                brand: brand,
                material: material,
                variant: variant,
                color: colorName,
                hex: null,
              ),
            );

            if (item.hex != null) {
              savedColors.add("$colorName|${item.hex}");
            } else {
              savedColors.add(colorName);
            }
          }

          data[brand][material][variant] = savedColors;
        });
      });
    });

    final jsonString = jsonEncode(data);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('custom_colors', jsonString);
  }
}
