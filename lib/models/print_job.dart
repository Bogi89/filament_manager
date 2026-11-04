import 'package:flutter/material.dart';
import 'extended_costs.dart';

class PrintJob {
  String projectName;
  String? filamentId;
  String filamentBrand;
  String material;
  String variant;
  Color color;
  List<Color> colors;
  List<String> colorNames;
  double weightUsed;
  double printMinutes;
  double totalCost;
  DateTime date;
  ExtendedCosts extendedCosts;
  Map<String, double> costBreakdown;
  double? sellingPrice;

  PrintJob({
    required this.projectName,
    this.filamentId,
    required this.filamentBrand,
    required this.material,
    required this.variant,
    required this.color,
    List<Color>? colors,
    List<String>? colorNames,
    required this.weightUsed,
    required this.printMinutes,
    required this.totalCost,
    required this.date,
    ExtendedCosts? extendedCosts,
    Map<String, double>? costBreakdown,
    this.sellingPrice,
  }) : colors = List<Color>.from(colors ?? [color]),
       colorNames = List<String>.from(colorNames ?? const []),
       extendedCosts = extendedCosts ?? ExtendedCosts(),
       costBreakdown = Map<String, double>.from(costBreakdown ?? const {});

  Map<String, dynamic> toJson() => {
    'projectName': projectName,
    'filamentId': filamentId,
    'filamentBrand': filamentBrand,
    'material': material,
    'variant': variant,
    'color': color.toARGB32(),
    'colors': colors.map((c) => c.toARGB32()).toList(),
    'colorNames': colorNames,
    'weightUsed': weightUsed,
    'printMinutes': printMinutes,
    'totalCost': totalCost,
    'date': date.toIso8601String(),
    'extendedCosts': extendedCosts.toJson(),
    'costBreakdown': costBreakdown,
    'sellingPrice': sellingPrice,
  };

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    final rawExtendedCosts = json['extendedCosts'];
    final rawBreakdown = json['costBreakdown'];
    ExtendedCosts extendedCosts = ExtendedCosts();
    if (rawExtendedCosts is Map) {
      extendedCosts = ExtendedCosts.fromJson(
        Map<String, dynamic>.from(rawExtendedCosts),
      );
    }
    final breakdown = <String, double>{};
    if (rawBreakdown is Map) {
      for (final entry in rawBreakdown.entries) {
        final value = entry.value;
        double? number;
        if (value is num) {
          number = value.toDouble();
        } else if (value is String) {
          number = double.tryParse(value.replaceAll(',', '.'));
        }
        if (number != null && number.isFinite && number >= 0) {
          breakdown[entry.key.toString()] = number;
        }
      }
    }
    double? sellingPrice;
    final rawSellingPrice = json['sellingPrice'];
    if (rawSellingPrice is num) {
      sellingPrice = rawSellingPrice.toDouble();
    } else if (rawSellingPrice is String) {
      sellingPrice = double.tryParse(rawSellingPrice.replaceAll(',', '.'));
    }
    if (sellingPrice != null && (!sellingPrice.isFinite || sellingPrice < 0)) {
      sellingPrice = null;
    }
    final rawColors = json['colors'];
    final parsedColors = rawColors is List
        ? rawColors.whereType<num>().map((c) => Color(c.toInt())).toList()
        : <Color>[];
    final rawNames = json['colorNames'];
    final parsedNames = rawNames is List
        ? rawNames.map((n) => n.toString()).toList()
        : <String>[];
    final rawMinutes = json['printMinutes'] ?? json['printHours'] ?? 0;
    return PrintJob(
      projectName: json['projectName']?.toString() ?? '',
      filamentId: json['filamentId']?.toString(),
      filamentBrand: json['filamentBrand']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      variant: json['variant']?.toString() ?? '',
      color: Color((json['color'] as num).toInt()),
      colors: parsedColors.isEmpty ? null : parsedColors,
      colorNames: parsedNames,
      weightUsed: (json['weightUsed'] as num).toDouble(),
      printMinutes: rawMinutes is num
          ? rawMinutes.toDouble()
          : double.tryParse(rawMinutes.toString()) ?? 0,
      totalCost: (json['totalCost'] as num).toDouble(),
      date: DateTime.parse(json['date'].toString()),
      extendedCosts: extendedCosts,
      costBreakdown: breakdown,
      sellingPrice: sellingPrice,
    );
  }

  PrintJob copyWith({
    String? projectName,
    String? filamentId,
    String? filamentBrand,
    String? material,
    String? variant,
    Color? color,
    List<Color>? colors,
    List<String>? colorNames,
    double? weightUsed,
    double? printMinutes,
    double? totalCost,
    DateTime? date,
    ExtendedCosts? extendedCosts,
    Map<String, double>? costBreakdown,
    double? sellingPrice,
  }) {
    return PrintJob(
      projectName: projectName ?? this.projectName,
      filamentId: filamentId ?? this.filamentId,
      filamentBrand: filamentBrand ?? this.filamentBrand,
      material: material ?? this.material,
      variant: variant ?? this.variant,
      color: color ?? this.color,
      colors: colors ?? this.colors,
      colorNames: colorNames ?? this.colorNames,
      weightUsed: weightUsed ?? this.weightUsed,
      printMinutes: printMinutes ?? this.printMinutes,
      totalCost: totalCost ?? this.totalCost,
      date: date ?? this.date,
      extendedCosts: extendedCosts ?? this.extendedCosts,
      costBreakdown: costBreakdown ?? this.costBreakdown,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}
