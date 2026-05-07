import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/filament.dart';
import '../models/filament_color.dart';

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

    // 🔥 Migration altes System → neues System
    for (final filament in filaments) {
      if (filament.filamentColors.isEmpty &&
          filament.colors.isNotEmpty &&
          filament.colorNames.isNotEmpty) {

        final List<FilamentColor> migratedColors = [];

        for (int i = 0; i < filament.colors.length; i++) {

          final color = filament.colors[i];

          String name = 'Unknown';

          if (i < filament.colorNames.length) {
            name = filament.colorNames[i];
          }

          final hex =
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

          migratedColors.add(
            FilamentColor(
              name: name,
              hex: hex,
              isCustom: false,
            ),
          );
        }

        filament.filamentColors = migratedColors;
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