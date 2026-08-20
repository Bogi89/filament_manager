import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/common/help_page_template.dart';

class HelpBackupPage extends StatelessWidget {
  const HelpBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpPageTemplate(
      title: AppLocalizations.of(context)!.helpBackupTitle,
      introduction:
          AppLocalizations.of(context)!.helpBackupIntroduction,
      children: [
        HelpSectionCard(
          icon: Icons.backup_outlined,
          title: AppLocalizations.of(context)!.helpBackupCreateTitle,
          content:
              AppLocalizations.of(context)!.helpBackupCreateContent,
        ),
        HelpSectionCard(
          icon: Icons.restore_outlined,
          title: AppLocalizations.of(context)!.helpBackupRestoreTitle,
          content:
              AppLocalizations.of(context)!.helpBackupRestoreContent,
        ),
        HelpSectionCard(
          icon: Icons.folder_outlined,
          title: AppLocalizations.of(context)!.helpBackupFileTitle,
          content:
              AppLocalizations.of(context)!.helpBackupFileContent,
        ),
        HelpSectionCard(
          icon: Icons.update_outlined,
          title: AppLocalizations.of(context)!.helpBackupRegularTitle,
          content:
              AppLocalizations.of(context)!.helpBackupRegularContent,
        ),
        HelpTipCard(
          text: AppLocalizations.of(context)!.helpBackupTip,
        ),
      ],
    );
  }
}