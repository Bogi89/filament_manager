import 'package:flutter/material.dart';

import '../widgets/common/help_page_template.dart';

class WhatsNewPage extends StatelessWidget {
  const WhatsNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpPageTemplate(
      title: 'Was ist neu',
      introduction:
          'Hier findest du die Neuerungen und Verbesserungen jeder Version des Filament Managers.',

      children: [
        HelpSectionCard(
          icon: Icons.new_releases_outlined,
          title: 'Version 1.0.0',
          content:
              '• Erste offizielle Veröffentlichung\n'
              '• Filamentverwaltung\n'
              '• Druckhistorie\n'
              '• Kostenberechnung\n'
              '• Statistiken\n'
              '• Backup & Wiederherstellung\n'
              '• Benutzerkonto\n'
              '• Gastmodus\n'
              '• Hilfebereich\n'
              '• Rechtliche Informationen',
        ),

        HelpTipCard(
          text:
              'Neue Funktionen werden nach jedem Update hier ergänzt. So behältst du jederzeit den Überblick über alle Änderungen.',
        ),
      ],
    );
  }
}
