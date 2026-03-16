import 'dart:convert';
import 'package:flutter/services.dart';

class CatalogItem {
  final String brand;
  final String material;
  final String variant;
  final String color;

  CatalogItem({
    required this.brand,
    required this.material,
    required this.variant,
    required this.color,
  });
}

class CatalogService {

  static Future<List<CatalogItem>> loadCatalog() async {

    final csvString =
        await rootBundle.loadString('assets/data/filament_catalog.csv');

    final lines = const LineSplitter().convert(csvString);

    final List<CatalogItem> items = [];

    for (int i = 1; i < lines.length; i++) {

      final row = lines[i].split(',');

      if (row.length < 4) continue;

      final brand = row[0].trim();
      final material = row[1].trim();
      final variant = row[2].trim();
      final color = _normalizeColor(row[3].trim());

      items.add(
        CatalogItem(
          brand: brand,
          material: material,
          variant: variant,
          color: color,
        ),
      );
    }

    return items;
  }

  static String _normalizeColor(String color) {

    final c = color.toLowerCase();

    if (c == 'weiß' || c == 'weiss' || c == 'white') return 'white';
    if (c == 'schwarz' || c == 'black') return 'black';

    return c;
  }
}