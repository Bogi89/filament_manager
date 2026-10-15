import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestAnalyticsService {
  GuestAnalyticsService._();

  static const String _guestAnalyticsIdKey = 'guest_analytics_id';
  static const String _pendingFilamentStatusKey =
      'guest_pending_filament_status';

  static Future<void> _filamentStatusQueue = Future<void>.value();

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

  /// Registriert eine fehlende Gastinstallation nachträglich.
  ///
  /// Bereits registrierte Gäste bleiben unverändert.
  /// Netzwerkfehler dürfen die App-Nutzung nicht beeinträchtigen.
  static Future<void> ensureGuestRegistered() async {
    try {
      final guestId = await _getOrCreateGuestId();

      await _functions.httpsCallable('ensureGuestRegistered').call({
        'guestId': guestId,
        'platform': _platformName,
      });
    } catch (error) {
      debugPrint('Guest registration could not be ensured: $error');
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

  /// Erfasst den App-Start eines angemeldeten Benutzers.
  ///
  /// Die Firebase Function ermittelt die Benutzer-ID selbst
  /// aus der bestehenden Firebase-Anmeldung.
  static Future<void> trackRegisteredUserActivity() async {
    try {
      await _functions.httpsCallable('trackRegisteredUserActivity').call();
    } catch (error) {
      debugPrint('Registered user activity could not be recorded: $error');
    }
  }

  /// Meldet, ob ein Gast aktuell Filamente gespeichert hat.
  ///
  /// Der neueste Status wird vor dem Firebase-Aufruf lokal
  /// gespeichert. Ältere Meldungen werden nicht erneut gesendet,
  /// wenn inzwischen ein neuerer Status vorliegt.
  static Future<void> trackGuestFilamentStatus({
    required bool hasFilaments,
  }) async {
    try {
      final preferences = await SharedPreferences.getInstance();

      // Neuesten Status sofort vormerken.
      await preferences.setBool(_pendingFilamentStatusKey, hasFilaments);

      _filamentStatusQueue = _filamentStatusQueue.then((_) async {
        try {
          final currentPreferences = await SharedPreferences.getInstance();

          // Inzwischen überholte Meldungen überspringen.
          final currentStatus = currentPreferences.getBool(
            _pendingFilamentStatusKey,
          );

          if (currentStatus != hasFilaments) {
            return;
          }

          await ensureGuestRegistered();

          final guestId = await _getOrCreateGuestId();

          await _functions.httpsCallable('trackGuestFilamentStatus').call({
            'guestId': guestId,
            'hasFilaments': hasFilaments,
          });

          // Nur löschen, wenn weiterhin derselbe Status vorgemerkt ist.
          final latestStatus = currentPreferences.getBool(
            _pendingFilamentStatusKey,
          );

          if (latestStatus == hasFilaments) {
            await currentPreferences.remove(_pendingFilamentStatusKey);
          }
        } catch (error) {
          debugPrint('Guest filament status could not be recorded: $error');
        }
      });

      await _filamentStatusQueue;
    } catch (error) {
      debugPrint('Guest filament status could not be queued: $error');
    }
  }

  /// Wiederholt eine noch nicht erfolgreich übertragene
  /// Bestandsmeldung, beispielsweise nach einem Netzwerkfehler.
  static Future<void> retryPendingFilamentStatus() {
    _filamentStatusQueue = _filamentStatusQueue.then((_) async {
      try {
        final preferences = await SharedPreferences.getInstance();

        final hasFilaments = preferences.getBool(_pendingFilamentStatusKey);

        if (hasFilaments == null) {
          return;
        }

        await ensureGuestRegistered();

        final guestId = await _getOrCreateGuestId();

        // Vor dem Senden prüfen, ob der Status noch aktuell ist.
        if (preferences.getBool(_pendingFilamentStatusKey) != hasFilaments) {
          return;
        }

        await _functions.httpsCallable('trackGuestFilamentStatus').call({
          'guestId': guestId,
          'hasFilaments': hasFilaments,
        });

        // Neuere Bestandsmeldungen nicht versehentlich löschen.
        if (preferences.getBool(_pendingFilamentStatusKey) == hasFilaments) {
          await preferences.remove(_pendingFilamentStatusKey);
        }
      } catch (error) {
        debugPrint('Pending guest filament status retry failed: $error');
      }
    });

    return _filamentStatusQueue;
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
