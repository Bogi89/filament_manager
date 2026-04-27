import 'package:flutter/material.dart';
import 'dart:math';

import 'spool.dart';
import '../services/color_registry.dart';
import 'package:flutter/material.dart';

class Filament {

  String id;

  String brand;
  String material;
  String variant;

  double diameter;

  double totalWeight;
  double remainingWeight;

  double price;

  int nozzleTemp;
  int bedTemp;

  Color color;

  String colorType;

  List<Color> colors;

  /// 🔥 Farbnamen
  List<String> colorNames;

  /// 🧵 NEU — Spulenliste
  List<Spool> spools;

  Filament({
    String? id,
    required this.brand,
    required this.material,
    required this.variant,
    required this.diameter,
    required this.totalWeight,
    required this.remainingWeight,
    required this.price,
    required this.nozzleTemp,
    required this.bedTemp,
    required this.color,

    this.colorType = "single",
    List<Color>? colors,
    List<String>? colorNames,

    /// 🧵 optional
    List<Spool>? spools,

  })  : colors = colors ?? [color],

        colorNames = colorNames ?? [],

        /// 🧵 Wenn keine Spulen vorhanden → eine erstellen
        spools = spools ??
            [
              Spool(
                weight: remainingWeight,
              )
            ],

        id = id ?? Random().nextInt(999999999).toString();

  factory Filament.fromJson(Map<String, dynamic> json) {

    /// Farben laden
    List<Color> parsedColors = [];

    if (json['colors'] != null) {

      for (var c in json['colors']) {
        parsedColors.add(Color(c));
      }

    }

    /// Farbnamen laden
    List<String> parsedNames = [];

    if (json['colorNames'] != null) {

      for (var n in json['colorNames']) {
        parsedNames.add(n.toString());
      }

    }

    /// 🧵 Spulen laden
    List<Spool> parsedSpools = [];

    if (json['spools'] != null) {

      for (var s in json['spools']) {

        parsedSpools.add(
          Spool.fromJson(s),
        );

      }

    }

    return Filament(

      id: json['id'],

      brand: json['brand'],
      material: json['material'],
      variant: (json['variant'] != null &&
          json['variant'].toString().trim().isNotEmpty)
    ? json['variant'].toString()
    : "Standard",

      diameter:
          (json['diameter'] as num)
              .toDouble(),

      totalWeight:
          (json['totalWeight'] as num)
              .toDouble(),

      remainingWeight:
          (json['remainingWeight'] as num)
              .toDouble(),

      price:
          (json['price'] as num)
              .toDouble(),

      nozzleTemp:
          json['nozzleTemp'],

      bedTemp:
          json['bedTemp'],

      color:
    parsedColors.isNotEmpty
        ? parsedColors.first
        : Colors.grey,

      colorType:
          json['colorType'] ?? "single",

      colors:
    parsedColors.isNotEmpty
        ? parsedColors
        : [Colors.grey],

      colorNames:
    parsedNames.isEmpty
        ? List.generate(
            parsedColors.length,
            (_) => "Unknown",
          )
        : parsedNames,

      /// 🧵 Spulen setzen
      spools:
          parsedSpools.isEmpty
              ? [
                  Spool(
                    weight:
                        (json['remainingWeight']
                                as num)
                            .toDouble(),
                  )
                ]
              : parsedSpools,

    );

  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'brand': brand,
      'material': material,
      'variant': variant,

      'diameter': diameter,

      'totalWeight': totalWeight,
      'remainingWeight': remainingWeight,

      'price': price,

      'nozzleTemp': nozzleTemp,
      'bedTemp': bedTemp,

      'color': color.value,

      'colorType': colorType,

      'colors':
          colors
              .map((c) => c.value)
              .toList(),

      'colorNames': colorNames,

      /// 🧵 Spulen speichern
      'spools':
          spools
              .map((s) => s.toJson())
              .toList(),

    };

  }

}