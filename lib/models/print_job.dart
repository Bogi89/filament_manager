import 'package:flutter/material.dart';

class PrintJob {
  String projectName;

  String filamentBrand;
  String material;
  String variant;
  Color color;

  double weightUsed;
  double printHours;
  double totalCost;

  DateTime date;

  PrintJob({
    required this.projectName,
    required this.filamentBrand,
    required this.material,
    required this.variant,
    required this.color,
    required this.weightUsed,
    required this.printHours,
    required this.totalCost,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'projectName': projectName,
        'filamentBrand': filamentBrand,
        'material': material,
        'variant': variant,
        'color': color.toARGB32(),
        'weightUsed': weightUsed,
        'printHours': printHours,
        'totalCost': totalCost,
        'date': date.toIso8601String(),
      };

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      projectName: json['projectName']?.toString() ?? '',
      filamentBrand: json['filamentBrand']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      variant: json['variant']?.toString() ?? '',
      color: Color(
        (json['color'] as num).toInt(),
      ),
      weightUsed: (json['weightUsed'] as num).toDouble(),
      printHours: (json['printHours'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      date: DateTime.parse(
        json['date'].toString(),
      ),
    );
  }
}