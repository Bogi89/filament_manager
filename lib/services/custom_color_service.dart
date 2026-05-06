import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomColorService {
  static const String _storageKey = 'custom_colors';

  static Future<void> saveCustomColor({
    required String name,
    required String hex,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = await loadCustomColors();

    final alreadyExists = existing.any(
      (color) =>
          color['name'].toString().toLowerCase() ==
              name.toLowerCase() ||
          color['hex'].toString().toLowerCase() ==
              hex.toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    existing.add({
      'name': name,
      'hex': hex,
    });

    await prefs.setString(
      _storageKey,
      jsonEncode(existing),
    );
  }

  static Future<List<Map<String, dynamic>>> loadCustomColors() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw);

    if (decoded is List) {
  return List<Map<String, dynamic>>.from(decoded);
}

return [];
  }
}