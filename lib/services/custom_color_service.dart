import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomColorService {
  static const String _storageKey = 'custom_colors_global';

  static Future<void> saveCustomColor({
    required String name,
    required String hex,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = await loadCustomColors();

    final alreadyExists = existing.any(
      (color) =>
          color['name'].toString().toLowerCase() == name.toLowerCase() ||
          color['hex'].toString().toLowerCase() == hex.toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    existing.add({'name': name, 'hex': hex});

    await prefs.setString(_storageKey, jsonEncode(existing));
  }

  static Future<List<Map<String, dynamic>>> loadCustomColors() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    List<Map<String, dynamic>> colors = [];

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        colors = decoded
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList();
      }
    }

    // Altes Speicherformat prüfen.
    final oldRaw = prefs.getString('custom_colors');

    if (oldRaw != null && oldRaw.isNotEmpty) {
      final oldDecoded = jsonDecode(oldRaw);

      if (oldDecoded is List) {
        for (final entry in oldDecoded) {
          if (entry is! Map) continue;

          final name = entry['name']?.toString();
          final hex = entry['hex']?.toString();

          if (name == null || name.isEmpty || hex == null || hex.isEmpty) {
            continue;
          }

          final exists = colors.any(
            (color) =>
                color['name'].toString().toLowerCase() == name.toLowerCase(),
          );

          if (!exists) {
            colors.add({'name': name, 'hex': hex});
          }
        }

        // Neue Daten speichern, alte Daten nicht löschen.
        await prefs.setString(_storageKey, jsonEncode(colors));
      }
    }

    return colors;
  }
}
