import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/common/help_page_template.dart';

class HelpFirstStepsPage extends StatelessWidget {
  const HelpFirstStepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpPageTemplate(
      title: AppLocalizations.of(context)!.helpFirstStepsTitle,
      introduction:
    AppLocalizations.of(context)!.helpFirstStepsIntroduction,
      children: [
        HelpSectionCard(
          icon: Icons.inventory_2_outlined,
          title: AppLocalizations.of(context)!.helpFirstStepsFilamentTitle,
          content:
    AppLocalizations.of(context)!.helpFirstStepsFilamentContent,
        ),

        HelpSectionCard(
          icon: Icons.print_outlined,
          title: AppLocalizations.of(context)!.helpFirstStepsPrintTitle,
          content:
    AppLocalizations.of(context)!.helpFirstStepsPrintContent,
        ),

        HelpSectionCard(
          icon: Icons.bar_chart_outlined,
          title: AppLocalizations.of(context)!.helpFirstStepsStatisticsTitle,
          content:
    AppLocalizations.of(context)!.helpFirstStepsStatisticsContent,
        ),

        HelpSectionCard(
          icon: Icons.backup_outlined,
          title: AppLocalizations.of(context)!.helpFirstStepsBackupTitle,
          content:
    AppLocalizations.of(context)!.helpFirstStepsBackupContent,
        ),

        HelpTipCard(
          text:
    AppLocalizations.of(context)!.helpFirstStepsTip,
        ),
      ],
    );
  }
}