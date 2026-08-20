import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/common/help_page_template.dart';

class HelpAddFilamentPage extends StatelessWidget {
  const HelpAddFilamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpPageTemplate(
      title: AppLocalizations.of(context)!.helpAddFilamentTitle,
      introduction:
          AppLocalizations.of(context)!.helpAddFilamentIntroduction,
      children: [
        HelpSectionCard(
          icon: Icons.add_circle_outline,
          title: AppLocalizations.of(context)!.helpAddFilamentNewTitle,
          content:
              AppLocalizations.of(context)!.helpAddFilamentNewContent,
        ),
        HelpSectionCard(
          icon: Icons.category_outlined,
          title: AppLocalizations.of(context)!.helpAddFilamentSelectTitle,
          content:
              AppLocalizations.of(context)!.helpAddFilamentSelectContent,
        ),
        HelpSectionCard(
          icon: Icons.settings_outlined,
          title: AppLocalizations.of(context)!.helpAddFilamentSettingsTitle,
          content:
              AppLocalizations.of(context)!.helpAddFilamentSettingsContent,
        ),
        HelpSectionCard(
          icon: Icons.inventory_2_outlined,
          title: AppLocalizations.of(context)!.helpAddFilamentStockTitle,
          content:
              AppLocalizations.of(context)!.helpAddFilamentStockContent,
        ),
        HelpTipCard(
          text: AppLocalizations.of(context)!.helpAddFilamentTip,
        ),
      ],
    );
  }
}