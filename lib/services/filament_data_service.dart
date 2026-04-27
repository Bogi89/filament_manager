import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/filament.dart';
import 'color_registry.dart';

class FilamentDataService {
  static const String _key = 'filaments';

  static Future<List<Filament>> loadFilaments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    print("FILAMENT JSON: $jsonString");

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(jsonString);
   final filaments =
    decoded.map((e) => Filament.fromJson(e)).toList();

// 🔴 FIX: Farben in Registry registrieren

for (final filament in filaments) {
  if (filament.colors.isNotEmpty &&
      filament.colorNames.isNotEmpty) {

    for (int i = 0; i < filament.colors.length; i++) {

      final hex = filament.colors[i];

      String? name;

      if (i < filament.colorNames.length) {
        name = filament.colorNames[i];
      }

      if (hex != null && name != null) {

        final normalizedHex =
            hex.toUpperCase();

        ColorRegistry.registerColor(
          normalizedHex,
          name,
        );
      }
    }
  }
}

return filaments;
  }

  static Future<void> saveFilaments(List<Filament> filaments) async {
    final prefs = await SharedPreferences.getInstance();

    final String encoded = json.encode(
      filaments.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_key, encoded);
  }
}