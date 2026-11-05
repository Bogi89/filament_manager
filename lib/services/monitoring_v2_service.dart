import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Client for the FilaLog Monitoring 2.0 callable endpoint.
///
/// Tracking is intentionally disabled until the Monitoring 2.0 rollout
/// is explicitly approved. No event is sent while [enabled] is false.
class MonitoringV2Service {
  MonitoringV2Service({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    bool enabled = false,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1'),
       _enabled = enabled;

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final bool _enabled;

  static const Set<String> allowedEvents = <String>{
    'app_started',
    'app_resumed',
    'guest_started',
    'screen_viewed',
    'registration_opened',
    'registration_attempted',
    'registration_completed',
    'email_verified',
    'login_opened',
    'login_completed',
    'filament_added',
    'filament_updated',
    'filament_deleted',
    'spool_added',
    'spool_deleted',
    'calculation_completed',
    'print_job_save_attempted',
    'print_job_saved',
    'print_job_save_failed',
    'print_job_updated',
    'print_job_deleted',
    'trial_started',
    'trial_expired',
    'premium_page_opened',
    'premium_purchase_started',
    'premium_purchase_completed',
  };

  static const Set<String> allowedScreens = <String>{
    'dashboard',
    'filaments',
    'calculator',
    'history',
    'statistics',
    'settings',
  };

  /// Returns true only when the server confirms that it stored the event.
  /// A false result never prevents the app's primary operation.
  Future<bool> trackEvent(
    String eventName, {
    String? screenName,
    String? eventId,
  }) async {
    if (!_enabled || _auth.currentUser == null) {
      return false;
    }

    if (!allowedEvents.contains(eventName)) {
      return false;
    }

    if (eventName == 'screen_viewed') {
      if (screenName == null || !allowedScreens.contains(screenName)) {
        return false;
      }
    } else if (screenName != null) {
      return false;
    }

    final String id = eventId ?? _createEventId();
    if (!RegExp(r'^[a-zA-Z0-9_-]{16,128}$').hasMatch(id)) {
      return false;
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'eventId': id,
      'eventName': eventName,
      'platform': _platformName(),
      if (eventName == 'screen_viewed') 'screenName': screenName,
    };

    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'monitoringV2TrackEvent',
      );
      final HttpsCallableResult<dynamic> response = await callable.call(
        payload,
      );
      final dynamic data = response.data;
      return data is Map && data['recorded'] == true;
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Monitoring V2: ${error.code}');
      return false;
    } catch (error) {
      debugPrint('Monitoring V2: event delivery failed ($error)');
      return false;
    }
  }

  Future<bool> trackScreen(String screenName) {
    return trackEvent('screen_viewed', screenName: screenName);
  }

  static String _createEventId() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final String hex = bytes
        .map((int value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return hex;
  }

  static String _platformName() {
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
