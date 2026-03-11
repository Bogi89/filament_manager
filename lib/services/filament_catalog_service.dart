import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/filament_catalog.dart';

class FilamentCatalogService {

  static List<FilamentCatalog> catalog = [];

  static final Map<String, Set<String>> brandMaterials = {};
  static final Map<String, Set<String>> materialVariants = {};
  static final Map<String, Set<String>> variantColors = {};

  static Future<void> loadCatalog() async {

    final jsonString =
        await rootBundle.loadString('assets/data/filament_catalog.json');

    final List decoded = jsonDecode(jsonString);

    catalog =
        decoded.map((e) => FilamentCatalog.fromJson(e)).toList();

    for (var f in catalog) {

      brandMaterials.putIfAbsent(f.brand, () => {});
      brandMaterials[f.brand]!.add(f.material);

      final matKey = "${f.brand}|${f.material}";
      materialVariants.putIfAbsent(matKey, () => {});
      materialVariants[matKey]!.add(f.variant);

      final varKey = "${f.brand}|${f.material}|${f.variant}";
      variantColors.putIfAbsent(varKey, () => {});
      variantColors[varKey]!.add(f.color);
    }
  }

  static List<String> getBrands() {

    final list = brandMaterials.keys.toList();
    list.sort();
    return list;
  }

  static List<String> getMaterials(String brand) {

    final list = brandMaterials[brand]?.toList() ?? [];
    list.sort();
    return list;
  }

  static List<String> getVariants(String brand, String material) {

    final key = "$brand|$material";

    final list = materialVariants[key]?.toList() ?? [];
    list.sort();
    return list;
  }

  static List<String> getColors(
      String brand,
      String material,
      String variant) {

    final key = "$brand|$material|$variant";

    final list = variantColors[key]?.toList() ?? [];
    list.sort();
    return list;
  }

  static List<FilamentCatalog> search(String query) {

    final q = query.toLowerCase();

    return catalog.where((f) {

      final text =
          "${f.brand} ${f.material} ${f.variant} ${f.color}"
              .toLowerCase();

      return text.contains(q);

    }).take(20).toList();
  }
}