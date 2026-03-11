import 'package:flutter/material.dart';

class Printer {

  String name;
  String brand;
  double averageWatt;
  String notes;

  Printer({
    required this.name,
    required this.brand,
    required this.averageWatt,
    this.notes = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'averageWatt': averageWatt,
      'notes': notes,
    };
  }

  factory Printer.fromJson(Map<String, dynamic> json) {
    return Printer(
      name: json['name'],
      brand: json['brand'],
      averageWatt: (json['averageWatt'] as num).toDouble(),
      notes: json['notes'] ?? "",
    );
  }

  @override
  String toString() {
    return "$brand $name";
  }
}