import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestAnalyticsService {
  GuestAnalyticsService._();

  static const String _guestAnalyticsIdKey = 'guest_analytics_id';

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  /// Erfasst den Start des Gastmodus anonym über eine Firebase Function.
  ///
  /// Pro Browser/App-Installation wird lokal eine zufällige anonyme Kennung
  /// gespeichert. Dadurch können eindeutige Gastinstallationen und wiederholte
  /// Gaststarts unterschieden werden.
  static Future<void> trackGuestStart() async {
    try {
      final guestId = await _getOrCreateGuestId();

      await _functions.httpsCallable('trackGuestStart').call({
        'guestId': guestId,
        'platform': _platformName,
      });
    } catch (error) {
      debugPrint('Guest analytics could not be recorded: $error');
    }
  }

  /// Erfasst einen tatsächlichen App-Start eines aktiven Gastnutzers.
  ///
  /// Verwendet dieselbe anonyme Gast-ID wie das bestehende Gast-Tracking.
  static Future<void> trackGuestActivity() async {
    try {
      final guestId = await _getOrCreateGuestId();

      await _functions.httpsCallable('trackGuestActivity').call({
        'guestId': guestId,
        'platform': _platformName,
      });
    } catch (error) {
      debugPrint('Guest activity could not be recorded: $error');
    }
  }

  static Future<String> _getOrCreateGuestId() async {
    final preferences = await SharedPreferences.getInstance();

    final existingId = preferences.getString(_guestAnalyticsIdKey);

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newId = _generateGuestId();

    await preferences.setString(_guestAnalyticsIdKey, newId);

    return newId;
  }

  static String _generateGuestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static String get _platformName {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
