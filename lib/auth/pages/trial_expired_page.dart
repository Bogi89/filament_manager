import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/paypal_subscription_service.dart';
import 'login_page.dart';
import 'register_page.dart';

class TrialExpiredPage extends StatefulWidget {
  const TrialExpiredPage({super.key});

  @override
  State<TrialExpiredPage> createState() => _TrialExpiredPageState();
}

class _TrialExpiredPageState extends State<TrialExpiredPage> {
  PayPalSubscriptionPlan? _loadingPlan;
  bool _paypalOpened = false;

  Future<void> _startSubscription(PayPalSubscriptionPlan plan) async {
    if (_loadingPlan != null) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _loadingPlan = plan;
      _paypalOpened = false;
    });

    try {
      await PayPalSubscriptionService.startSubscription(plan);

      if (!mounted) {
        return;
      }

      setState(() {
        _paypalOpened = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.trialExpiredPaypalOpened)),
      );
    } on PayPalSubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.trialExpiredPaypalStartError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingPlan = null;
        });
      }
    }
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    final monthlyLoading = _loadingPlan == PayPalSubscriptionPlan.monthly;

    final yearlyLoading = _loadingPlan == PayPalSubscriptionPlan.yearly;

    final isLoading = _loadingPlan != null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

Icon(
  Icons.hourglass_disabled_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    localizations.trialExpiredTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.trialExpiredSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user == null
                        ? localizations.trialExpiredLoginHint
                        : localizations.trialExpiredPremiumHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  if (user == null) ...[
                    FilledButton.icon(
                      onPressed: _openLogin,
                      icon: const Icon(Icons.login),
                      label: Text(localizations.trialExpiredLoginButton),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openRegister,
                      icon: const Icon(Icons.person_add_outlined),
                      label: Text(localizations.trialExpiredRegisterButton),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizations.trialExpiredLoginRequiredInfo,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ] else ...[
                    _SubscriptionOption(
                      title: localizations.trialExpiredMonthlyTitle,
                      price: localizations.trialExpiredMonthlyPrice,
                      period: localizations.trialExpiredMonthlyPeriod,
                      highlighted: false,
                      loading: monthlyLoading,
                      enabled: !isLoading,
                      onPressed: () {
                        _startSubscription(PayPalSubscriptionPlan.monthly);
                      },
                    ),
                    const SizedBox(height: 16),
                    _SubscriptionOption(
                      title: localizations.trialExpiredYearlyTitle,
                      price: localizations.trialExpiredYearlyPrice,
                      period: localizations.trialExpiredYearlyPeriod,
                      highlighted: true,
                      badge: localizations.trialExpiredYearlyBadge,
                      loading: yearlyLoading,
                      enabled: !isLoading,
                      onPressed: () {
                        _startSubscription(PayPalSubscriptionPlan.yearly);
                      },
                    ),
                    if (_paypalOpened) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.open_in_new, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizations.trialExpiredPaypalOpenedInfo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      localizations.trialExpiredPaypalManagementInfo,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
                  color: highlighted
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
