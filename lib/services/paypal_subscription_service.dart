import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

enum PayPalSubscriptionPlan { monthly, yearly }

class PayPalSubscriptionException implements Exception {
  final String message;

  const PayPalSubscriptionException(this.message);

  @override
  String toString() => message;
}

class PayPalSubscriptionService {
  PayPalSubscriptionService._();

  static FirebaseFunctions get _functions {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west1',
    );
  }

  static Future<void> startSubscription(PayPalSubscriptionPlan plan) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const PayPalSubscriptionException(
        'Du bist nicht angemeldet. Melde dich zuerst mit deinem '
        'FilaLog-Konto an und versuche es anschließend erneut.',
      );
    }

    try {
      // Vor dem Zahlungsstart bewusst ein aktuelles Firebase-
      // Authentifizierungstoken laden. Dieses Token wird vom
      // Cloud-Functions-SDK beim Callable-Aufruf verwendet.
      await user.getIdToken(true);
    } on FirebaseAuthException catch (error) {
      throw PayPalSubscriptionException(
        'Die Anmeldung konnte nicht bestätigt werden: '
        '${error.message ?? error.code}',
      );
    }

    try {
      final callable = _functions.httpsCallable('createPayPalSubscription');

      final result = await callable.call<Map<String, dynamic>>({
        'planType': _planTypeToString(plan),
      });

      final data = result.data;
      final approvalUrl = data['approvalUrl'];

      if (approvalUrl is! String || approvalUrl.isEmpty) {
        throw const PayPalSubscriptionException(
          'PayPal hat keine Freigabe-URL zurückgegeben.',
        );
      }

      final uri = Uri.tryParse(approvalUrl);

      if (uri == null) {
        throw const PayPalSubscriptionException(
          'Die PayPal-Freigabe-URL ist ungültig.',
        );
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw const PayPalSubscriptionException(
          'PayPal konnte nicht geöffnet werden.',
        );
      }
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'unauthenticated') {
        throw const PayPalSubscriptionException(
          'Firebase erkennt keine aktive Anmeldung. '
          'Bitte melde dich erneut bei FilaLog an.',
        );
      }

      throw PayPalSubscriptionException(
        'Der PayPal-Vorgang konnte nicht gestartet werden '
        '(${error.code}).',
      );
    }
  }

  static String _planTypeToString(PayPalSubscriptionPlan plan) {
    switch (plan) {
      case PayPalSubscriptionPlan.monthly:
        return 'monthly';

      case PayPalSubscriptionPlan.yearly:
        return 'yearly';
    }
  }
}
