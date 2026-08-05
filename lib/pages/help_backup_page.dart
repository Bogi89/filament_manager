import 'package:flutter/material.dart';

import '../widgets/common/help_page_template.dart';

class HelpBackupPage extends StatelessWidget {
  const HelpBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpPageTemplate(
      title: 'Backup & Wiederherstellung',
      introduction:
          'Mit einem Backup kannst du deine Filamente, Druckaufträge und Einstellungen sichern und später wiederherstellen.',

      children: [
        HelpSectionCard(
          icon: Icons.backup_outlined,
          title: 'Backup erstellen',
          content:
              'Erstelle regelmäßig ein Backup deiner Daten, damit keine Informationen verloren gehen.',
        ),

        HelpSectionCard(
          icon: Icons.restore_outlined,
          title: 'Backup wiederherstellen',
          content:
              'Wähle eine zuvor erstellte Sicherungsdatei aus, um deine Daten wieder in den Filament Manager zu importieren.',
        ),

        HelpSectionCard(
          icon: Icons.folder_outlined,
          title: 'Sicherungsdatei',
          content:
              'Bewahre deine Backup-Dateien an einem sicheren Ort auf, beispielsweise in einer Cloud oder auf einem externen Datenträger.',
        ),

        HelpSectionCard(
          icon: Icons.update_outlined,
          title: 'Regelmäßig sichern',
          content:
              'Erstelle besonders vor größeren Änderungen oder App-Updates ein aktuelles Backup.',
        ),

        HelpTipCard(
          text:
              'Tipp: Mit regelmäßigen Backups kannst du deine Daten jederzeit problemlos wiederherstellen.',
        ),
      ],
    );
  }
}
