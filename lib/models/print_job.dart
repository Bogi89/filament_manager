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
        'color': color.value,
        'weightUsed': weightUsed,
        'printHours': printHours,
        'totalCost': totalCost,
        'date': date.toIso8601String(),
      };

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      projectName: json['projectName'] ?? "",
      filamentBrand: json['filamentBrand'],
      material: json['material'],
      variant: json['variant'],
      color: Color(json['color']),
      weightUsed: json['weightUsed'],
      printHours: json['printHours'],
      totalCost: json['totalCost'],
      date: DateTime.parse(json['date']),
    );
  }
}