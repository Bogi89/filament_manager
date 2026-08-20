import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/common/help_page_template.dart';

class HelpStatisticsPage extends StatelessWidget {
  const HelpStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpPageTemplate(
      title: AppLocalizations.of(context)!.helpStatisticsTitle,
      introduction:
          AppLocalizations.of(context)!.helpStatisticsIntroduction,
      children: [
        HelpSectionCard(
          icon: Icons.bar_chart_outlined,
          title: AppLocalizations.of(context)!.helpStatisticsUsageTitle,
          content:
              AppLocalizations.of(context)!.helpStatisticsUsageContent,
        ),
        HelpSectionCard(
          icon: Icons.euro_outlined,
          title: AppLocalizations.of(context)!.helpStatisticsCostsTitle,
          content:
              AppLocalizations.of(context)!.helpStatisticsCostsContent,
        ),
        HelpSectionCard(
          icon: Icons.history_outlined,
          title: AppLocalizations.of(context)!.helpStatisticsHistoryTitle,
          content:
              AppLocalizations.of(context)!.helpStatisticsHistoryContent,
        ),
        HelpSectionCard(
          icon: Icons.analytics_outlined,
          title: AppLocalizations.of(context)!.helpStatisticsAnalysisTitle,
          content:
              AppLocalizations.of(context)!.helpStatisticsAnalysisContent,
        ),
        HelpTipCard(
          text: AppLocalizations.of(context)!.helpStatisticsTip,
        ),
      ],
    );
  }
}