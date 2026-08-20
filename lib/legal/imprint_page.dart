import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class ImprintPage extends StatelessWidget {
  const ImprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: localizations.imprint,
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.person_outline,
            title: localizations.imprintProviderDetailsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintAppNameLabel),
                  subtitle: Text(localizations.imprintAppNameValue),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintDeveloperLabel),
                  subtitle: Text(localizations.imprintDeveloperValue),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintAddressLabel),
                  subtitle: Text(localizations.imprintAddressValue),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.email_outlined,
            title: localizations.imprintContactTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintEmailLabel),
                  subtitle: Text(localizations.imprintEmailValue),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintWebsiteLabel),
                  subtitle: Text(localizations.imprintWebsiteValue),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.business_outlined,
            title: localizations.imprintCompanyInformationTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintCompanyFormLabel),
                  subtitle: Text(localizations.imprintCompanyFormValue),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintBusinessPurposeLabel),
                  subtitle: Text(localizations.imprintBusinessPurposeValue),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.gavel_outlined,
            title: localizations.imprintLegalNotesTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintLiabilityLabel),
                  subtitle: Text(localizations.imprintLiabilityContent),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localizations.imprintCopyrightLabel),
                  subtitle: Text(localizations.imprintCopyrightContent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}