import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class WithdrawalPage extends StatelessWidget {
  const WithdrawalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: localizations.withdrawal,
      lastUpdated: localizations.legalLastUpdatedValue,
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.assignment_return_outlined,
            title: localizations.withdrawalRightTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalPeriodTitle),
                  subtitle: Text(
                    localizations.withdrawalPeriodContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalReasonTitle),
                  subtitle: Text(
                    localizations.withdrawalReasonContent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.assignment_return_outlined,
            title: localizations.withdrawalExerciseTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalDeclarationTitle),
                  subtitle: Text(
                    localizations.withdrawalDeclarationContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalDeadlineTitle),
                  subtitle: Text(
                    localizations.withdrawalDeadlineContent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.workspace_premium_outlined,
            title: localizations.withdrawalPremiumTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalDigitalServiceTitle),
                  subtitle: Text(
                    localizations.withdrawalDigitalServiceContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalEarlyExpiryTitle),
                  subtitle: Text(
                    localizations.withdrawalEarlyExpiryContent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.info_outline,
            title: localizations.withdrawalInformationTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.withdrawalPurchaseInfoTitle),
                  subtitle: Text(
                    localizations.withdrawalPurchaseInfoContent,
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