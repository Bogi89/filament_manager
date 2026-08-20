import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/common/help_page_template.dart';

class HelpPrintJobPage extends StatelessWidget {
  const HelpPrintJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpPageTemplate(
      title: AppLocalizations.of(context)!.helpPrintJobTitle,
      introduction:
          AppLocalizations.of(context)!.helpPrintJobIntroduction,
      children: [
        HelpSectionCard(
          icon: Icons.playlist_add_outlined,
          title: AppLocalizations.of(context)!.helpPrintJobNewTitle,
          content:
              AppLocalizations.of(context)!.helpPrintJobNewContent,
        ),
        HelpSectionCard(
          icon: Icons.inventory_2_outlined,
          title: AppLocalizations.of(context)!.helpPrintJobFilamentTitle,
          content:
              AppLocalizations.of(context)!.helpPrintJobFilamentContent,
        ),
        HelpSectionCard(
          icon: Icons.scale_outlined,
          title: AppLocalizations.of(context)!.helpPrintJobUsageTitle,
          content:
              AppLocalizations.of(context)!.helpPrintJobUsageContent,
        ),
        HelpSectionCard(
          icon: Icons.receipt_long_outlined,
          title: AppLocalizations.of(context)!.helpPrintJobInfoTitle,
          content:
              AppLocalizations.of(context)!.helpPrintJobInfoContent,
        ),
        HelpTipCard(
          text: AppLocalizations.of(context)!.helpPrintJobTip,
        ),
      ],
    );
  }
}