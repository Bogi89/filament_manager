import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: localizations.premiumSubscription,
      lastUpdated: localizations.legalLastUpdatedValue,
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.workspace_premium_outlined,
            title: localizations.premiumMembershipTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumTitle),
                  subtitle: Text(localizations.premiumContent),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumTrialTitle),
                  subtitle: Text(localizations.premiumTrialContent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.payments_outlined,
            title: localizations.premiumBillingTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumPaymentProcessingTitle),
                  subtitle: Text(
                    localizations.premiumPaymentProcessingContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumPlatformsTitle),
                  subtitle: Text(localizations.premiumPlatformsContent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.star_outline,
            title: localizations.premiumTrialAndPremiumTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumSevenDayTrialTitle),
                  subtitle: Text(
                    localizations.premiumSevenDayTrialContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumAfterTrialTitle),
                  subtitle: Text(localizations.premiumAfterTrialContent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.event_available_outlined,
            title: localizations.premiumMembershipTermsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumDurationTitle),
                  subtitle: Text(localizations.premiumDurationContent),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.premiumCancellationTitle),
                  subtitle: Text(localizations.premiumCancellationContent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}