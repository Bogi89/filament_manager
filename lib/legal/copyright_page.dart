import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class CopyrightPage extends StatelessWidget {
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: l10n.copyright,
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.copyright_outlined,
            title: l10n.copyrightRightsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.copyrightAppTitle),
                  subtitle: Text(
                    l10n.copyrightAppContent,
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.copyrightUsageTitle),
                  subtitle: Text(
                    l10n.copyrightUsageContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.image_outlined,
            title: l10n.copyrightGraphicsContentTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.copyrightOwnContentTitle),
                  subtitle: Text(
                    l10n.copyrightOwnContentContent,
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.copyrightThirdPartyTitle),
                  subtitle: Text(
                    l10n.copyrightThirdPartyContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.gavel_outlined,
            title: l10n.copyrightLicenseNoticeTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.copyrightOpenSourceTitle),
                  subtitle: Text(
                    l10n.copyrightOpenSourceContent,
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