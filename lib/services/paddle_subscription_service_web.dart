import 'dart:js_interop';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

@JS('Paddle.Environment.set')
external void _setPaddleEnvironment(String environment);

@JS('Paddle.Initialize')
external void _initializePaddle(JSObject options);

@JS('Paddle.Checkout.open')
external void _openPaddleCheckout(JSObject options);

class PaddleSubscriptionException implements Exception {
  final String message;

  const PaddleSubscriptionException(this.message);

  @override
  String toString() => message;
}

class PaddleSubscriptionService {
  PaddleSubscriptionService._();

  static const String _clientToken = String.fromEnvironment(
    'PADDLE_CLIENT_TOKEN',
  );

  static const String _yearlyPriceId = 'pri_01m1d11wsxe99cv3522p6eszj3';

  static bool _initialized = false;

  static Future<void> startYearlySubscription() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const PaddleSubscriptionException(
        'Du bist nicht angemeldet. Melde dich zuerst mit deinem '
        'FilaLog-Konto an und versuche es anschließend erneut.',
      );
    }

    if (_clientToken.isEmpty) {
      throw const PaddleSubscriptionException(
        'Der Paddle Client-side Token fehlt im Web-Build.',
      );
    }

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

      final callable = functions.httpsCallable('createPaddleCheckoutReference');

      final result = await callable.call();

      final data = Map<String, dynamic>.from(result.data as Map);

      final checkoutReference = data['checkoutReference'] as String?;

      if (checkoutReference == null || checkoutReference.isEmpty) {
        throw const PaddleSubscriptionException(
          'Die sichere Paddle-Checkout-Referenz konnte '
          'nicht erstellt werden.',
        );
      }

      if (!_initialized) {
        _setPaddleEnvironment('sandbox');

        _initializePaddle(
          <String, Object?>{'token': _clientToken}.jsify() as JSObject,
        );

        _initialized = true;
      }

      final checkoutOptions =
          <String, Object?>{
                'items': [
                  {'priceId': _yearlyPriceId, 'quantity': 1},
                ],
                'customer': {if (user.email != null) 'email': user.email},
                'customData': {'checkoutReference': checkoutReference},
                'settings': {'displayMode': 'overlay', 'variant': 'one-page'},
              }.jsify()
              as JSObject;

      _openPaddleCheckout(checkoutOptions);
    } on FirebaseFunctionsException catch (error) {
      throw PaddleSubscriptionException(
        'Die sichere Paddle-Checkout-Referenz konnte '
        'nicht erstellt werden: ${error.message ?? error.code}',
      );
    } on PaddleSubscriptionException {
      rethrow;
    } catch (error) {
      throw PaddleSubscriptionException(
        'Der Paddle-Checkout konnte nicht geöffnet werden: $error',
      );
    }
  }
}
