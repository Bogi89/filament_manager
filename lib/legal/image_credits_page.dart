import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class ImageCreditsPage extends StatelessWidget {
  const ImageCreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LegalPageTemplate(
      title: l10n.imageCredits,
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.image_outlined,
            title: l10n.imageCreditsGraphicsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.imageCreditsOwnGraphicsTitle),
                  subtitle: Text(
                    l10n.imageCreditsOwnGraphicsContent,
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.imageCreditsAppIconsTitle),
                  subtitle: Text(
                    l10n.imageCreditsAppIconsContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.palette_outlined,
            title: l10n.imageCreditsColorsDesignTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.imageCreditsInterfaceTitle),
                  subtitle: Text(
                    l10n.imageCreditsInterfaceContent,
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.imageCreditsBrandsTitle),
                  subtitle: Text(
                    l10n.imageCreditsBrandsContent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.info_outline,
            title: l10n.imageCreditsNoticeTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.imageCreditsUpdateTitle),
                  subtitle: Text(
                    l10n.imageCreditsUpdateContent,
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