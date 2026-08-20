import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: l10n.privacyPolicy,
      lastUpdated: l10n.privacyPolicyUpdated,
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.admin_panel_settings_outlined,
            title: l10n.privacyPolicyResponsible,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyResponsibleLabel),
                  subtitle: Text(l10n.privacyPolicyResponsibleName),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyContact),
                  subtitle: Text(l10n.privacyPolicyContactMissing),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.storage_outlined,
            title: l10n.privacyPolicyStoredDataTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyLocalDataTitle),
                  subtitle: Text(l10n.privacyPolicyLocalDataContent),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyNoSharingTitle),
                  subtitle: Text(l10n.privacyPolicyNoSharingContent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.person_outline,
            title: l10n.privacyPolicyAccountTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyGuestModeTitle),
                  subtitle: Text(l10n.privacyPolicyGuestModeContent),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyUserAccountTitle),
                  subtitle: Text(l10n.privacyPolicyUserAccountContent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.lock_outline,
            title: l10n.privacyPolicyRightsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyRightsLabel),
                  subtitle: Text(l10n.privacyPolicyRightsContent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.contact_support_outlined,
            title: l10n.privacyPolicyQuestionsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.privacyPolicyQuestionsContactTitle),
                  subtitle: Text(
                    l10n.privacyPolicyQuestionsContactContent,
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