import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/printer.dart';

class PrinterService {
  static const String _customPrintersKey = 'custom_printers';

  /// Standarddrucker
  static List<Printer> getDefaultPrinters() {
    return [
      // Bambu Lab
      Printer(brand: "Bambu Lab", name: "P1P", averageWatt: 120),

      Printer(brand: "Bambu Lab", name: "P1S", averageWatt: 120),

      Printer(brand: "Bambu Lab", name: "X1 Carbon", averageWatt: 150),

      Printer(brand: "Bambu Lab", name: "A1", averageWatt: 110),

      Printer(brand: "Bambu Lab", name: "A1 Mini", averageWatt: 95),

      // Prusa
      Printer(brand: "Prusa", name: "MK3S+", averageWatt: 140),

      Printer(brand: "Prusa", name: "MK4", averageWatt: 140),

      Printer(brand: "Prusa", name: "Mini", averageWatt: 100),

      Printer(brand: "Prusa", name: "XL", averageWatt: 170),

      // Creality
      Printer(brand: "Creality", name: "Ender 3", averageWatt: 150),

      Printer(brand: "Creality", name: "Ender 3 V2", averageWatt: 150),

      Printer(brand: "Creality", name: "Ender 3 S1", averageWatt: 160),

      Printer(brand: "Creality", name: "K1", averageWatt: 220),

      Printer(brand: "Creality", name: "K1 Max", averageWatt: 230),

      Printer(brand: "Creality", name: "Hi", averageWatt: 180),

      // Anycubic
      Printer(brand: "Anycubic", name: "Kobra", averageWatt: 150),

      Printer(brand: "Anycubic", name: "Kobra 2", averageWatt: 160),

      Printer(brand: "Anycubic", name: "Kobra 2 Max", averageWatt: 180),

      // Elegoo
      Printer(brand: "Elegoo", name: "Neptune 3", averageWatt: 150),

      Printer(brand: "Elegoo", name: "Neptune 4", averageWatt: 160),

      Printer(brand: "Elegoo", name: "Neptune 4 Pro", averageWatt: 170),
    ];
  }

  /// Benutzerdefinierte Drucker laden
  static Future<List<Printer>> getCustomPrinters() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> data = prefs.getStringList(_customPrintersKey) ?? [];

    return data.map((e) => Printer.fromJson(jsonDecode(e))).toList();
  }

  /// Alle Drucker laden
  static Future<List<Printer>> getAllPrinters() async {
    final printers = <Printer>[
      ...getDefaultPrinters(),
      ...await getCustomPrinters(),
    ];

    printers.sort((a, b) {
      final nameA = a.brand.isEmpty ? a.name : "${a.brand} ${a.name}";

      final nameB = b.brand.isEmpty ? b.name : "${b.brand} ${b.name}";

      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return printers;
  }

  /// Benutzerdefinierten Drucker speichern
  static Future<void> saveCustomPrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();

    final printers = await getCustomPrinters();

    final exists = printers.any(
      (p) => p.brand == printer.brand && p.name == printer.name,
    );

    if (exists) {
      return;
    }

    printers.add(printer);

    await prefs.setStringList(
      _customPrintersKey,
      printers.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  /// Benutzerdefinierten Drucker löschen
  static Future<void> deleteCustomPrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();

    final printers = await getCustomPrinters();

    printers.removeWhere(
      (p) => p.brand == printer.brand && p.name == printer.name,
    );

    await prefs.setStringList(
      _customPrintersKey,
      printers.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}
