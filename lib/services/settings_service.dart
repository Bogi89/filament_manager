import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {

  static const String _themeKey = 'themeMode';
  static const String _languageKey = 'languageCode';
  static const String _warningKey = 'warningPercent';

  static Future<Map<String, dynamic>> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();

    final themeString = prefs.getString(_themeKey);
    final languageCode = prefs.getString(_languageKey);
    final warningPercent = prefs.getDouble(_warningKey) ?? 20;

    ThemeMode themeMode = ThemeMode.system;

    if (themeString == 'light') {
      themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      themeMode = ThemeMode.dark;
    }

    Locale locale = const Locale('de');

    if (languageCode != null) {
      locale = Locale(languageCode);
    }

    return {
      'themeMode': themeMode,
      'locale': locale,
      'warningPercent': warningPercent,
    };
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {

    final prefs = await SharedPreferences.getInstance();

    String value = 'system';

    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await prefs.setString(_themeKey, value);
  }

  static Future<void> saveLocale(Locale locale) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_languageKey, locale.languageCode);
  }

  static Future<void> saveWarningPercent(double percent) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_warningKey, percent);
  }
}