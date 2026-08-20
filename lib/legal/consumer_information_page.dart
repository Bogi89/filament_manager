import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class ConsumerInformationPage extends StatelessWidget {
  const ConsumerInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: localizations.consumerInformation,
      lastUpdated: localizations.legalLastUpdatedValue,
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.info_outline,
            title: localizations.consumerProviderTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.consumerResponsibleTitle),
                  subtitle: Text(
                    localizations.consumerResponsibleContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.consumerContactTitle),
                  subtitle: Text(
                    localizations.consumerContactContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.receipt_long_outlined,
            title: localizations.consumerContractTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.consumerPremiumTitle),
                  subtitle: Text(
                    localizations.consumerPremiumContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    localizations.consumerContractConclusionTitle,
                  ),
                  subtitle: Text(
                    localizations.consumerContractConclusionContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.support_agent_outlined,
            title: localizations.consumerSupportTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.consumerHelpTitle),
                  subtitle: Text(
                    localizations.consumerHelpContent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}