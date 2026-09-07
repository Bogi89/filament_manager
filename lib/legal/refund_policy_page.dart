import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: localizations.refundPolicy,
      lastUpdated: localizations.legalLastUpdatedValue,
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.currency_exchange_outlined,
            title: localizations.refundGeneralTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                localizations.refundGeneralContent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.language_outlined,
            title: localizations.refundWebTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                localizations.refundWebContent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.android_outlined,
            title: localizations.refundAndroidTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                localizations.refundAndroidContent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.cancel_outlined,
            title: localizations.refundCancellationTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                localizations.refundCancellationContent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.gavel_outlined,
            title: localizations.refundWithdrawalTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                localizations.refundWithdrawalContent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.support_agent_outlined,
            title: localizations.refundSupportTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                localizations.refundSupportContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}