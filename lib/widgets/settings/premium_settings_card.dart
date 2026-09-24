import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/firestore_service.dart';
import '../../services/google_play_subscription_service.dart';
import '../../services/paddle_subscription_service.dart';

class PremiumSettingsCard extends StatefulWidget {
  const PremiumSettingsCard({super.key});

  @override
  State<PremiumSettingsCard> createState() => _PremiumSettingsCardState();
}

class _PremiumSettingsCardState extends State<PremiumSettingsCard> {
  StreamSubscription<UserAccessStatus?>? _accessSubscription;
  StreamSubscription<void>? _googlePlayCompletedSubscription;
  StreamSubscription<GooglePlaySubscriptionException>?
  _googlePlayFailedSubscription;
  StreamSubscription<void>? _paddleCompletedSubscription;

  UserAccessStatus? _accessStatus;

  GooglePlaySubscriptionProduct? _monthlyProduct;
  GooglePlaySubscriptionProduct? _yearlyProduct;

  bool _statusLoading = true;
  bool _productsLoading = false;
  bool _monthlyLoading = false;
  bool _yearlyLoading = false;
  bool _restoreLoading = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _statusLoading = false;
      return;
    }

    _accessSubscription = FirestoreService.watchUserAccessStatus().listen(
      (status) {
        if (!mounted) {
          return;
        }

        setState(() {
          _accessStatus = status;
          _statusLoading = false;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _statusLoading = false;
        });
      },
    );

    if (kIsWeb) {
      _paddleCompletedSubscription = PaddleSubscriptionService.checkoutCompleted
          .listen((_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _yearlyLoading = false;
            });

            _showPurchaseSuccess();
          });
    } else {
      _googlePlayCompletedSubscription = GooglePlaySubscriptionService
          .purchaseCompleted
          .listen((_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _monthlyLoading = false;
              _yearlyLoading = false;
              _restoreLoading = false;
            });

            _showPurchaseSuccess();
          });

      _googlePlayFailedSubscription = GooglePlaySubscriptionService
          .purchaseFailed
          .listen((error) {
            if (!mounted) {
              return;
            }

            setState(() {
              _monthlyLoading = false;
              _yearlyLoading = false;
              _restoreLoading = false;
            });

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.message)));
          });

      _loadGooglePlayProducts();
    }
  }

  Future<void> _loadGooglePlayProducts() async {
    if (kIsWeb || _productsLoading) {
      return;
    }

    setState(() {
      _productsLoading = true;
    });

    try {
      final monthly = await GooglePlaySubscriptionService.getMonthlyProduct();

      final yearly = await GooglePlaySubscriptionService.getYearlyProduct();

      if (!mounted) {
        return;
      }

      setState(() {
        _monthlyProduct = monthly;
        _yearlyProduct = yearly;
      });
    } on GooglePlaySubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _productsLoading = false;
        });
      }
    }
  }

  Future<void> _purchaseMonthly() async {
    if (_monthlyLoading ||
        _yearlyLoading ||
        _productsLoading ||
        _restoreLoading ||
        _monthlyProduct == null) {
      return;
    }

    setState(() {
      _monthlyLoading = true;
    });

    try {
      await GooglePlaySubscriptionService.purchaseMonthly();
    } on GooglePlaySubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _monthlyLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _monthlyLoading = false;
      });

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.premiumSettingsPurchaseStartError)),
      );
    }
  }

  Future<void> _purchaseYearly() async {
    if (_monthlyLoading ||
        _yearlyLoading ||
        _productsLoading ||
        _restoreLoading) {
      return;
    }

    setState(() {
      _yearlyLoading = true;
    });

    try {
      if (kIsWeb) {
        await PaddleSubscriptionService.startYearlySubscription();
      } else {
        if (_yearlyProduct == null) {
          setState(() {
            _yearlyLoading = false;
          });
          return;
        }

        await GooglePlaySubscriptionService.purchaseYearly();
      }
    } on PaddleSubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _yearlyLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on GooglePlaySubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _yearlyLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _yearlyLoading = false;
      });

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trialExpiredWebCheckoutStartError)),
      );
    }
  }

  Future<void> _restorePurchases() async {
    if (kIsWeb ||
        _monthlyLoading ||
        _yearlyLoading ||
        _productsLoading ||
        _restoreLoading) {
      return;
    }

    setState(() {
      _restoreLoading = true;
    });

    try {
      await GooglePlaySubscriptionService.restorePurchases();
    } on GooglePlaySubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _restoreLoading = false;
        });
      }
    }
  }

  void _showPurchaseSuccess() {
    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.premiumSettingsPurchaseSuccess)),
    );
  }

  @override
  void dispose() {
    _accessSubscription?.cancel();
    _googlePlayCompletedSubscription?.cancel();
    _googlePlayFailedSubscription?.cancel();
    _paddleCompletedSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _InfoBox(
        icon: Icons.login,
        title: l10n.premiumSettingsTitle,
        message: l10n.premiumSettingsLoginRequired,
      );
    }

    if (_statusLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final premiumActive =
        _accessStatus?.premiumActive == true ||
        _accessStatus?.manualPremium == true;

    if (premiumActive) {
      return _InfoBox(
        icon: Icons.workspace_premium_outlined,
        title: l10n.premiumSettingsActive,
        message: l10n.premiumSettingsActiveInfo,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoBox(
          icon: Icons.hourglass_top_outlined,
          title: l10n.premiumSettingsTrialActive,
          message: l10n.premiumSettingsTrialInfo,
        ),

        const SizedBox(height: 20),

        if (kIsWeb) ...[
          _SubscriptionOption(
            title: l10n.trialExpiredYearlyTitle,
            price: l10n.trialExpiredYearlyPrice,
            period: l10n.trialExpiredYearlyPeriod,
            badge: l10n.trialExpiredYearlyBadge,
            highlighted: true,
            loading: _yearlyLoading,
            enabled: !_yearlyLoading,
            onPressed: _purchaseYearly,
          ),

          const SizedBox(height: 16),

          Text(
            l10n.trialExpiredWebManagementInfo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else ...[
          _SubscriptionOption(
            title: l10n.trialExpiredMonthlyTitle,
            price: _monthlyProduct?.price ?? l10n.trialExpiredMonthlyPrice,
            period: l10n.trialExpiredMonthlyPeriod,
            highlighted: false,
            loading: _monthlyLoading,
            enabled:
                !_productsLoading &&
                !_monthlyLoading &&
                !_yearlyLoading &&
                !_restoreLoading &&
                _monthlyProduct != null,
            onPressed: _purchaseMonthly,
          ),

          const SizedBox(height: 16),

          _SubscriptionOption(
            title: l10n.trialExpiredYearlyTitle,
            price: _yearlyProduct?.price ?? l10n.trialExpiredYearlyPrice,
            period: l10n.trialExpiredYearlyPeriod,
            badge: l10n.trialExpiredYearlyBadge,
            highlighted: true,
            loading: _yearlyLoading,
            enabled:
                !_productsLoading &&
                !_monthlyLoading &&
                !_yearlyLoading &&
                !_restoreLoading &&
                _yearlyProduct != null,
            onPressed: _purchaseYearly,
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed:
                _productsLoading ||
                    _monthlyLoading ||
                    _yearlyLoading ||
                    _restoreLoading
                ? null
                : _restorePurchases,
            icon: _restoreLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.restore),
            label: Text(l10n.trialExpiredRestorePurchases),
          ),

          const SizedBox(height: 12),

          Text(
            l10n.trialExpiredAndroidManagementInfo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool highlighted;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  const _SubscriptionOption({
    required this.title,
    required this.price,
    required this.period,
    required this.highlighted,
    required this.loading,
    required this.enabled,
    required this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: highlighted
          ? colorScheme.primary.withValues(alpha: 0.08)
          : theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? colorScheme.primary.withValues(alpha: 0.65)
                  : colorScheme.onSurface.withValues(alpha: 0.15),
              width: highlighted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: highlighted ? colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      period,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (loading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                Icon(
                  Icons.arrow_forward_rounded,
                  color: enabled
                      ? highlighted
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.7)
                      : colorScheme.onSurface.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
