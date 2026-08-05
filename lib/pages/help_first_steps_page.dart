import 'package:flutter/material.dart';

import '../widgets/common/help_page_template.dart';

class HelpFirstStepsPage extends StatelessWidget {
  const HelpFirstStepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpPageTemplate(
      title: 'Erste Schritte',
      introduction:
          'Willkommen beim Filament Manager. Diese Anleitung hilft dir beim Einstieg und erklärt die wichtigsten Funktionen der App.',

      children: [
        HelpSectionCard(
          icon: Icons.inventory_2_outlined,
          title: '1. Filament hinzufügen',
          content:
              'Lege zunächst dein erstes Filament an. Alle weiteren Funktionen bauen auf deinen Filamentbestand auf.',
        ),

        HelpSectionCard(
          icon: Icons.print_outlined,
          title: '2. Druckauftrag erstellen',
          content:
              'Erstelle anschließend einen Druckauftrag. Der Filamentverbrauch wird automatisch berechnet und vom Bestand abgezogen.',
        ),

        HelpSectionCard(
          icon: Icons.bar_chart_outlined,
          title: '3. Statistiken nutzen',
          content:
              'Im Statistikbereich erhältst du einen Überblick über deinen Verbrauch, deine Kosten und deine Druckhistorie.',
        ),

        HelpSectionCard(
          icon: Icons.backup_outlined,
          title: '4. Backup erstellen',
          content:
              'Erstelle regelmäßig ein Backup deiner Daten, damit dein Filamentbestand und deine Druckhistorie jederzeit gesichert sind.',
        ),

        HelpTipCard(
          text:
              'Tipp: Beginne mit wenigen Filamenten. So lernst du die App schnell kennen und behältst jederzeit den Überblick.',
        ),
      ],
    );
  }
}
