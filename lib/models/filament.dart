import 'dart:math';

import 'package:flutter/material.dart';

import 'filament_color.dart';
import 'spool.dart';

class Filament {
  String id;
  String brand;
  String material;
  String variant;
  double diameter;
  double? density;
  double totalWeight;
  double remainingWeight;
  double price;
  int nozzleTemp;
  int bedTemp;
  Color color;
  String colorType;
  List<Color> colors;
  List<String> colorNames;
  List<FilamentColor> filamentColors;
  List<Spool> spools;

  Filament({
    String? id,
    required this.brand,
    required this.material,
    required this.variant,
    required this.diameter,
    this.density,
    required this.totalWeight,
    required this.remainingWeight,
    required this.price,
    required this.nozzleTemp,
    required this.bedTemp,
    required this.color,
    this.colorType = 'single',
    List<Color>? colors,
    List<String>? colorNames,
    List<FilamentColor>? filamentColors,
    List<Spool>? spools,
  }) : colors = List<Color>.from(colors ?? [color]),
       colorNames = List<String>.from(colorNames ?? const []),
       filamentColors = List<FilamentColor>.from(filamentColors ?? const []),
       spools = List<Spool>.from(spools ?? [Spool(weight: remainingWeight)]),
       id = id ?? Random().nextInt(999999999).toString();

  static Color? _parseHex(String hex) {
    final value = hex.trim().replaceFirst(RegExp(r'^#'), '');
    if (!RegExp(r'^(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(value)) {
      return null;
    }
    final number = int.tryParse(value, radix: 16);
    if (number == null) return null;
    return Color(value.length == 6 ? 0xFF000000 | number : number);
  }

  /// Uses the explicit hex list when it contains more information than the
  /// legacy colors list. Does not mutate stored data.
  List<Color> get effectiveColors {
    final hexColors = filamentColors
        .map((entry) => _parseHex(entry.hex))
        .whereType<Color>()
        .toList();
    if (hexColors.isNotEmpty &&
        (hexColors.length > colors.length ||
            colors.isEmpty ||
            (colors.length == 1 && colors.first == Colors.grey))) {
      return hexColors;
    }
    if (colors.isNotEmpty) return List<Color>.from(colors);
    if (hexColors.isNotEmpty) return hexColors;
    return [color];
  }

  List<String> get effectiveColorNames {
    final names = colorNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty && name.toLowerCase() != 'unknown')
        .toList();
    if (names.isNotEmpty) return names.toSet().toList();
    return filamentColors
        .map((entry) => entry.name.trim())
        .where((name) => name.isNotEmpty && name.toLowerCase() != 'unknown')
        .toSet()
        .toList();
  }

  factory Filament.fromJson(Map<String, dynamic> json) {
    final parsedColors = <Color>[];
    if (json['colors'] is List) {
      for (final entry in json['colors'] as List) {
        if (entry is num) parsedColors.add(Color(entry.toInt()));
      }
    }
    final parsedNames = <String>[];
    if (json['colorNames'] is List) {
      for (final entry in json['colorNames'] as List) {
        parsedNames.add(entry.toString());
      }
    }
    final parsedFilamentColors = <FilamentColor>[];
    if (json['filamentColors'] is List) {
      for (final entry in json['filamentColors'] as List) {
        if (entry is Map) {
          parsedFilamentColors.add(
            FilamentColor.fromJson(Map<String, dynamic>.from(entry)),
          );
        }
      }
    }
    final parsedSpools = <Spool>[];
    if (json['spools'] is List) {
      for (final entry in json['spools'] as List) {
        if (entry is Map) {
          parsedSpools.add(Spool.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
    }
    final fallbackColor = json['color'] is num
        ? Color((json['color'] as num).toInt())
        : Colors.grey;
    final filament = Filament(
      id: json['id']?.toString(),
      brand: json['brand'] as String,
      material: json['material'] as String,
      variant:
          json['variant'] != null &&
              json['variant'].toString().trim().isNotEmpty
          ? json['variant'].toString()
          : 'Standard',
      diameter: (json['diameter'] as num).toDouble(),
      density: json['density'] is num
          ? (json['density'] as num).toDouble()
          : null,
      totalWeight: (json['totalWeight'] as num).toDouble(),
      remainingWeight: (json['remainingWeight'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      nozzleTemp: (json['nozzleTemp'] as num).toInt(),
      bedTemp: (json['bedTemp'] as num).toInt(),
      color: parsedColors.isNotEmpty ? parsedColors.first : fallbackColor,
      colorType: json['colorType']?.toString() ?? 'single',
      colors: parsedColors.isNotEmpty ? parsedColors : [fallbackColor],
      colorNames: parsedNames,
      filamentColors: parsedFilamentColors,
      spools: parsedSpools.isNotEmpty
          ? parsedSpools
          : [Spool(weight: (json['remainingWeight'] as num).toDouble())],
    );
    return filament;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'material': material,
    'variant': variant,
    'diameter': diameter,
    'density': density,
    'totalWeight': totalWeight,
    'remainingWeight': remainingWeight,
    'price': price,
    'nozzleTemp': nozzleTemp,
    'bedTemp': bedTemp,
    'color': color.toARGB32(),
    'colorType': colorType,
    'colors': colors.map((entry) => entry.toARGB32()).toList(),
    'colorNames': colorNames,
    'filamentColors': filamentColors.map((entry) => entry.toJson()).toList(),
    'spools': spools.map((entry) => entry.toJson()).toList(),
  };
}
