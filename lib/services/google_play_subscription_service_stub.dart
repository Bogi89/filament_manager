import 'dart:async';

class GooglePlaySubscriptionException implements Exception {
  final String message;

  const GooglePlaySubscriptionException(this.message);

  @override
  String toString() => message;
}

class GooglePlaySubscriptionProduct {
  final String title;
  final String price;
  final String basePlanId;

  const GooglePlaySubscriptionProduct({
    required this.title,
    required this.price,
    required this.basePlanId,
  });
}

class GooglePlaySubscriptionService {
  GooglePlaySubscriptionService._();

  static const String premiumProductId = 'filalog_premium';
  static const String monthlyBasePlanId = 'monthly';
  static const String yearlyBasePlanId = 'yearly';

  static Stream<void> get purchaseCompleted => const Stream<void>.empty();

  static Stream<GooglePlaySubscriptionException> get purchaseFailed =>
      const Stream<GooglePlaySubscriptionException>.empty();

  static Future<void> initialize() async {}

  static Future<GooglePlaySubscriptionProduct?> getMonthlyProduct() async {
    return null;
  }

  static Future<GooglePlaySubscriptionProduct?> getYearlyProduct() async {
    return null;
  }

  static Future<void> purchaseMonthly() async {
    throw const GooglePlaySubscriptionException(
      'Google Play subscriptions are only available on Android.',
    );
  }

  static Future<void> purchaseYearly() async {
    throw const GooglePlaySubscriptionException(
      'Google Play subscriptions are only available on Android.',
    );
  }

  static Future<void> restorePurchases() async {
    throw const GooglePlaySubscriptionException(
      'Google Play subscriptions are only available on Android.',
    );
  }

  static Future<void> dispose() async {}
}
