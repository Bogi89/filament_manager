import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/filament.dart';

class FilamentDataService {
  static const String _key = 'filaments';

  static Future<List<Filament>> loadFilaments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((e) => Filament.fromJson(e)).toList();
  }

  static Future<void> saveFilaments(List<Filament> filaments) async {
    final prefs = await SharedPreferences.getInstance();

    final String encoded = json.encode(
      filaments.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_key, encoded);
  }
}