import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: localizations.termsOfService,
      lastUpdated: localizations.legalLastUpdatedValue,
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.description_outlined,
            title: localizations.termsOfServiceScope,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.termsOfServiceAppUsageTitle),
                  subtitle: Text(
                    localizations.termsOfServiceAppUsageContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.termsOfServiceAgreementTitle),
                  subtitle: Text(
                    localizations.termsOfServiceAgreementContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.person_outline,
            title: localizations.termsOfServiceUserObligations,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.termsOfServiceResponsibilityTitle),
                  subtitle: Text(
                    localizations.termsOfServiceResponsibilityContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.termsOfServiceMisuseTitle),
                  subtitle: Text(
                    localizations.termsOfServiceMisuseContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.workspace_premium_outlined,
            title: localizations.termsOfServiceLicensesRights,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.termsOfServiceCopyrightTitle),
                  subtitle: Text(
                    localizations.termsOfServiceCopyrightContent,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.termsOfServiceNoDistributionTitle),
                  subtitle: Text(
                    localizations.termsOfServiceNoDistributionContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.update_outlined,
            title: localizations.termsOfServiceChanges,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    localizations.termsOfServiceUpdatesTitle,
                  ),
                  subtitle: Text(
                    localizations.termsOfServiceUpdatesContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.gavel_outlined,
            title: localizations.termsOfServiceFinalProvisions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    localizations.termsOfServiceApplicableLawTitle,
                  ),
                  subtitle: Text(
                    localizations.termsOfServiceApplicableLawContent,
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