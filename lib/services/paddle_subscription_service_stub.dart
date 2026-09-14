import 'dart:async';

class PaddleSubscriptionException implements Exception {
  final String message;

  const PaddleSubscriptionException(this.message);

  @override
  String toString() => message;
}

class PaddleSubscriptionService {
  PaddleSubscriptionService._();

  static Stream<void> get checkoutCompleted => const Stream<void>.empty();

  static Future<void> startYearlySubscription() async {
    throw const PaddleSubscriptionException(
      'Paddle subscriptions are only available on the web.',
    );
  }
}
