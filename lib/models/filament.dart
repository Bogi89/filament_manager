import 'package:flutter/material.dart';
import 'dart:math';

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

  /// 🔥 NEU — Farbnamen
  List<String> colorNames;

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

    /// 🔥 NEU
    List<String>? colorNames,

  })  : colors = colors ?? [color],

        /// Falls keine Namen vorhanden → leer
        colorNames = colorNames ?? [],

        id = id ?? Random().nextInt(999999999).toString();

  factory Filament.fromJson(Map<String, dynamic> json) {

    List<Color> parsedColors = [];

    if (json['colors'] != null) {

      for (var c in json['colors']) {
        parsedColors.add(Color(c));
      }

    }

    /// 🔥 Farbnamen laden (falls vorhanden)

    List<String> parsedNames = [];

    if (json['colorNames'] != null) {

      for (var n in json['colorNames']) {
        parsedNames.add(n.toString());
      }

    }

    return Filament(

      id: json['id'],

      brand: json['brand'],
      material: json['material'],
      variant: json['variant'],

      diameter: (json['diameter'] as num).toDouble(),

      totalWeight: (json['totalWeight'] as num).toDouble(),
      remainingWeight: (json['remainingWeight'] as num).toDouble(),

      price: (json['price'] as num).toDouble(),

      nozzleTemp: json['nozzleTemp'],
      bedTemp: json['bedTemp'],

      color: Color(json['color']),

      colorType: json['colorType'] ?? "single",

      colors: parsedColors.isEmpty
          ? [Color(json['color'])]
          : parsedColors,

      /// 🔥 Farbnamen setzen
      colorNames: parsedNames,

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

      'colors': colors.map((c) => c.value).toList(),

      /// 🔥 Farbnamen speichern
      'colorNames': colorNames,

    };

  }

}