import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class LiabilityPage extends StatelessWidget {
  const LiabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: l10n.liabilityTitle,
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.gpp_good_outlined,
            title: l10n.liabilityContentTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.liabilityCareTitle),
                  subtitle: Text(l10n.liabilityCareContent),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.liabilityNoWarrantyTitle),
                  subtitle: Text(l10n.liabilityNoWarrantyContent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.link_outlined,
            title: l10n.liabilityExternalContentTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.liabilityExternalLinksTitle),
                  subtitle: Text(l10n.liabilityExternalLinksContent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LegalInfoCard(
            icon: Icons.info_outline,
            title: l10n.liabilityUsageTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.liabilityGeneralInformationTitle),
                  subtitle: Text(l10n.liabilityGeneralInformationContent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}