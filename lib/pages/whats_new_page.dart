import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/common/help_page_template.dart';

class WhatsNewPage extends StatelessWidget {
  const WhatsNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpPageTemplate(
      title: AppLocalizations.of(context)!.whatsNew,
      introduction:
          AppLocalizations.of(context)!.whatsNewIntroduction,
      children: [
        HelpSectionCard(
          icon: Icons.new_releases_outlined,
          title: AppLocalizations.of(context)!.whatsNewVersion100,
          content:
              AppLocalizations.of(context)!.whatsNewVersion100Content,
        ),
        HelpTipCard(
          text: AppLocalizations.of(context)!.whatsNewTip,
        ),
      ],
    );
  }
}