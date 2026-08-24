import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/main_navigation.dart';
import '../../state/app_state.dart';
import '../services/guest_service.dart';
import '../widgets/guest_card.dart';
import '../widgets/login_card.dart';
import '../widgets/register_card.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final isEnglish = appState.locale.languageCode == 'en';

    final texts = _WelcomeTexts(
      isEnglish: isEnglish,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: _LanguageSelector(
                isEnglish: isEnglish,
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    72,
                    24,
                    24,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo/logo_256.png',
                        width: 110,
                        height: 110,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const FlutterLogo(
                            size: 110,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'FilaLog',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Filament Management',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _FeatureChip(
                            icon: Icons.inventory_2_outlined,
                            label: texts.filaments,
                          ),
                          _FeatureChip(
                            icon: Icons.print_outlined,
                            label: texts.printJobs,
                          ),
                          _FeatureChip(
                            icon: Icons.euro_outlined,
                            label: texts.costs,
                          ),
                          _FeatureChip(
                            icon: Icons.bar_chart_outlined,
                            label: texts.statistics,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _TrialAndPricingCard(
                        texts: texts,
                      ),
                      const SizedBox(height: 32),
                      GuestCard(
                        onPressed: () async {
                          await GuestService.enableGuestMode();

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const MainNavigation(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      LoginCard(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      RegisterCard(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              texts.privacyPolicy,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              texts.legalNotice,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              texts.termsOfService,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final bool isEnglish;

  const _LanguageSelector({
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return PopupMenuButton<String>(
      tooltip: isEnglish ? 'Language' : 'Sprache',
      onSelected: (languageCode) {
        appState.setLocale(
          Locale(languageCode),
        );
      },
      itemBuilder: (context) {
  return [
    PopupMenuItem<String>(
      value: 'de',
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 18,
            color: !isEnglish
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
          const SizedBox(width: 8),
          const Text('German'),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'en',
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 18,
            color: isEnglish
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
          const SizedBox(width: 8),
          const Text('English'),
        ],
      ),
    ),
  ];
},
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
  isEnglish ? 'English' : 'German',
),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrialAndPricingCard extends StatelessWidget {
  final _WelcomeTexts texts;

  const _TrialAndPricingCard({
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 620,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 40,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            texts.trialTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texts.trialDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: 0.75,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _PriceOption(
                title: texts.monthly,
                price: '2,49 €',
                subtitle: texts.perMonth,
              ),
              _PriceOption(
                title: texts.yearly,
                price: '19,99 €',
                subtitle: texts.perYear,
                highlighted: true,
                highlightedLabel: texts.cheaper,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            texts.trialFooter,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceOption extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool highlighted;
  final String? highlightedLabel;

  const _PriceOption({
    required this.title,
    required this.price,
    required this.subtitle,
    this.highlighted = false,
    this.highlightedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primary.withValues(
                alpha: 0.08,
              )
            : theme.scaffoldBackgroundColor.withValues(
                alpha: 0.4,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted
              ? colorScheme.primary.withValues(
                  alpha: 0.55,
                )
              : colorScheme.onSurface.withValues(
                  alpha: 0.12,
                ),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                highlightedLabel ?? '',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlighted
                  ? colorScheme.primary
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
      ),
      label: Text(
        label,
      ),
    );
  }
}

class _WelcomeTexts {
  final bool isEnglish;

  const _WelcomeTexts({
    required this.isEnglish,
  });

  String get filaments {
    return isEnglish ? 'Filaments' : 'Filamente';
  }

  String get printJobs {
    return isEnglish ? 'Print Jobs' : 'Druckaufträge';
  }

  String get costs {
    return isEnglish ? 'Costs' : 'Kosten';
  }

  String get statistics {
    return isEnglish ? 'Statistics' : 'Statistiken';
  }

  String get trialTitle {
    return isEnglish
        ? 'Try for 7 days free'
        : '7 Tage kostenlos testen';
  }

  String get trialDescription {
    return isEnglish
        ? 'Try FilaLog free for 7 days and decide afterwards '
            'whether you want to continue with Premium.'
        : 'Teste FilaLog 7 Tage kostenlos und entscheide danach, '
            'ob du Premium nutzen möchtest.';
  }

  String get monthly {
    return isEnglish ? 'Monthly' : 'Monatlich';
  }

  String get yearly {
    return isEnglish ? 'Yearly' : 'Jährlich';
  }

  String get perMonth {
    return isEnglish ? 'per month' : 'pro Monat';
  }

  String get perYear {
    return isEnglish ? 'per year' : 'pro Jahr';
  }

  String get cheaper {
    return isEnglish ? 'Better value' : 'Günstiger';
  }

  String get trialFooter {
    return isEnglish
        ? 'After the trial period, you can decide whether '
            'you want to continue using FilaLog Premium.'
        : 'Nach Ablauf der Testphase kannst du entscheiden, '
            'ob du FilaLog Premium weiter nutzen möchtest.';
  }

  String get privacyPolicy {
    return isEnglish ? 'Privacy Policy' : 'Datenschutz';
  }

  String get legalNotice {
    return isEnglish ? 'Legal Notice' : 'Impressum';
  }

  String get termsOfService {
    return isEnglish ? 'Terms of Service' : 'Nutzungsbedingungen';
  }
}