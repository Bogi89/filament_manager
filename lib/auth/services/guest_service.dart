import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const _guestEnabledKey = 'guest_mode_enabled';
  static const _guestStartKey = 'guest_mode_start';
  static const _trialUsedKey = 'trial_used';

  static const Duration trialDuration = Duration(days: 7);

  /// Gastmodus aktivieren.
  ///
  /// Der Startzeitpunkt wird nur beim ersten Start gespeichert,
  /// damit die Testphase nicht erneut gestartet werden kann.
  static Future<void> enableGuestMode() async {
    final prefs = await SharedPreferences.getInstance();

    final hasStartedTrial =
        prefs.getBool(_trialUsedKey) ?? false;

    if (!hasStartedTrial) {
      await prefs.setBool(_trialUsedKey, true);

      await prefs.setString(
        _guestStartKey,
        DateTime.now().toIso8601String(),
      );
    }

    await prefs.setBool(
      _guestEnabledKey,
      true,
    );
  }

  /// Gastmodus deaktivieren.
  ///
  /// Der Teststatus und das Startdatum bleiben erhalten,
  /// damit die kostenlose Testphase nicht erneut gestartet werden kann.
  static Future<void> disableGuestMode() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_guestEnabledKey);
  }

  /// Ist der Gastmodus aktuell aktiv?
  static Future<bool> isGuestModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_guestEnabledKey) ?? false;
  }

  /// Wurde die kostenlose Testphase bereits gestartet?
  static Future<bool> hasUsedTrial() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_trialUsedKey) ?? false;
  }

  /// Startdatum der Testphase laden.
  static Future<DateTime?> getGuestStartDate() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_guestStartKey);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  /// Prüft, ob die kostenlose Testphase noch aktiv ist.
  static Future<bool> isTrialActive() async {
    final startDate = await getGuestStartDate();

    if (startDate == null) {
      return false;
    }

    final expirationDate =
        startDate.add(trialDuration);

    return DateTime.now().isBefore(
      expirationDate,
    );
  }

  /// Prüft, ob die kostenlose Testphase abgelaufen ist.
  static Future<bool> isTrialExpired() async {
    final hasUsed = await hasUsedTrial();

    if (!hasUsed) {
      return false;
    }

    return !(await isTrialActive());
  }

  /// Berechnet die verbleibenden Tage der Testphase.
  static Future<int> getRemainingTrialDays() async {
    final startDate = await getGuestStartDate();

    if (startDate == null) {
      return 0;
    }

    final expirationDate =
        startDate.add(trialDuration);

    final remaining =
        expirationDate.difference(DateTime.now());

    if (remaining.isNegative || remaining.inDays < 0) {
      return 0;
    }

    return remaining.inDays + 1;
  }
}