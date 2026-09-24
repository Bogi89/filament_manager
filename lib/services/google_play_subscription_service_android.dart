import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

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

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  static final StreamController<void> _purchaseCompletedController =
      StreamController<void>.broadcast();

  static final StreamController<GooglePlaySubscriptionException>
  _purchaseFailedController =
      StreamController<GooglePlaySubscriptionException>.broadcast();

  static StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  static GooglePlayProductDetails? _monthlyProduct;
  static GooglePlayProductDetails? _yearlyProduct;

  static bool _initialized = false;

  static Stream<void> get purchaseCompleted =>
      _purchaseCompletedController.stream;

  static Stream<GooglePlaySubscriptionException> get purchaseFailed =>
      _purchaseFailedController.stream;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final available = await _inAppPurchase.isAvailable();

    if (!available) {
      throw const GooglePlaySubscriptionException(
        'Google Play Billing ist auf diesem Gerät nicht verfügbar.',
      );
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );

    await _loadProducts();

    _initialized = true;
  }

  static Future<void> _loadProducts() async {
    final response = await _inAppPurchase.queryProductDetails(const <String>{
      premiumProductId,
    });

    if (response.error != null) {
      throw GooglePlaySubscriptionException(response.error!.message);
    }

    _monthlyProduct = null;
    _yearlyProduct = null;

    for (final product in response.productDetails) {
      if (product is! GooglePlayProductDetails) {
        continue;
      }

      final basePlanId = _basePlanId(product);

      if (basePlanId == monthlyBasePlanId) {
        _monthlyProduct = product;
      } else if (basePlanId == yearlyBasePlanId) {
        _yearlyProduct = product;
      }
    }
  }

  static String? _basePlanId(GooglePlayProductDetails product) {
    final subscriptionIndex = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;

    if (subscriptionIndex == null ||
        offers == null ||
        subscriptionIndex < 0 ||
        subscriptionIndex >= offers.length) {
      return null;
    }

    return offers[subscriptionIndex].basePlanId;
  }

  static Future<GooglePlaySubscriptionProduct?> getMonthlyProduct() async {
    await initialize();

    final product = _monthlyProduct;

    if (product == null) {
      return null;
    }

    return GooglePlaySubscriptionProduct(
      title: product.title,
      price: product.price,
      basePlanId: monthlyBasePlanId,
    );
  }

  static Future<GooglePlaySubscriptionProduct?> getYearlyProduct() async {
    await initialize();

    final product = _yearlyProduct;

    if (product == null) {
      return null;
    }

    return GooglePlaySubscriptionProduct(
      title: product.title,
      price: product.price,
      basePlanId: yearlyBasePlanId,
    );
  }

  static Future<void> purchaseMonthly() async {
    await initialize();

    final product = _monthlyProduct;

    if (product == null) {
      throw const GooglePlaySubscriptionException(
        'Das monatliche Google-Play-Abo ist nicht verfügbar.',
      );
    }

    await _purchase(product);
  }

  static Future<void> purchaseYearly() async {
    await initialize();

    final product = _yearlyProduct;

    if (product == null) {
      throw const GooglePlaySubscriptionException(
        'Das jährliche Google-Play-Abo ist nicht verfügbar.',
      );
    }

    await _purchase(product);
  }

  static Future<void> _purchase(GooglePlayProductDetails product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const GooglePlaySubscriptionException(
        'Für den Kauf musst du angemeldet sein.',
      );
    }

    final obfuscatedAccountId = sha256
        .convert(utf8.encode(user.uid))
        .toString();

    final purchaseParam = GooglePlayPurchaseParam(
      productDetails: product,
      offerToken: product.offerToken,
      applicationUserName: obfuscatedAccountId,
    );

    final started = await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!started) {
      throw const GooglePlaySubscriptionException(
        'Der Google-Play-Kauf konnte nicht gestartet werden.',
      );
    }
  }

  static Future<void> restorePurchases() async {
    await initialize();

    if (FirebaseAuth.instance.currentUser == null) {
      throw const GooglePlaySubscriptionException(
        'Zum Wiederherstellen musst du angemeldet sein.',
      );
    }

    await _inAppPurchase.restorePurchases();
  }

  static Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw const GooglePlaySubscriptionException(
        'Für die Prüfung des Kaufs musst du angemeldet sein.',
      );
    }

    final purchaseToken = purchase.verificationData.serverVerificationData;

    if (purchaseToken.isEmpty) {
      throw const GooglePlaySubscriptionException(
        'Google Play hat keinen gültigen Kauftoken geliefert.',
      );
    }

    final callable = _functions.httpsCallable('verifyGooglePlaySubscription');

    final result = await callable.call(<String, dynamic>{
      'purchaseToken': purchaseToken,
    });

    final data = result.data;

    if (data is! Map || data['verified'] != true) {
      throw const GooglePlaySubscriptionException(
        'Das Google-Play-Abo konnte nicht bestätigt werden.',
      );
    }
  }

  static Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          try {
            await _verifyPurchase(purchase);

            if (purchase.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchase);
            }

            _purchaseCompletedController.add(null);
          } on GooglePlaySubscriptionException catch (error) {
            _purchaseFailedController.add(error);

            // Kauf absichtlich nicht abschließen.
            //
            // Ohne erfolgreiche serverseitige Verifizierung darf
            // FilaLog Premium nicht clientseitig freigeschaltet werden.
          } catch (_) {
            _purchaseFailedController.add(
              const GooglePlaySubscriptionException(
                'Das Google-Play-Abo konnte nicht bestätigt werden.',
              ),
            );

            // Kauf absichtlich nicht abschließen.
          }
          break;

        case PurchaseStatus.error:
          _purchaseFailedController.add(
            GooglePlaySubscriptionException(
              purchase.error?.message ??
                  'Bei Google Play ist ein Fehler aufgetreten.',
            ),
          );
          break;

        case PurchaseStatus.canceled:
          _purchaseFailedController.add(
            const GooglePlaySubscriptionException(
              'Der Google-Play-Kauf wurde abgebrochen.',
            ),
          );
          break;
      }
    }
  }

  static Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    _initialized = false;
  }
}
