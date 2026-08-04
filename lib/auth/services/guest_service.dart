import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const _guestEnabledKey = 'guest_mode_enabled';
  static const _guestStartKey = 'guest_mode_start';

  /// Gastmodus aktivieren
  static Future<void> enableGuestMode() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_guestEnabledKey, true);
    await prefs.setString(_guestStartKey, DateTime.now().toIso8601String());
  }

  /// Gastmodus deaktivieren
  static Future<void> disableGuestMode() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_guestEnabledKey);
    await prefs.remove(_guestStartKey);
  }

  /// Ist der Gastmodus aktiv?
  static Future<bool> isGuestModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_guestEnabledKey) ?? false;
  }

  /// Startdatum laden
  static Future<DateTime?> getGuestStartDate() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_guestStartKey);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
