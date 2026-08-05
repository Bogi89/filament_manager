import 'package:flutter/material.dart';

import '../widgets/common/help_page_template.dart';

class HelpStatisticsPage extends StatelessWidget {
  const HelpStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpPageTemplate(
      title: 'Statistiken verstehen',
      introduction:
          'Die Statistik zeigt dir eine Übersicht über deinen Filamentverbrauch, deine Druckaufträge und die entstandenen Kosten.',

      children: [
        HelpSectionCard(
          icon: Icons.bar_chart_outlined,
          title: 'Verbrauch',
          content:
              'Hier siehst du, wie viel Filament insgesamt verbraucht wurde und welche Materialien am häufigsten verwendet werden.',
        ),

        HelpSectionCard(
          icon: Icons.euro_outlined,
          title: 'Kosten',
          content:
              'Die Kostenübersicht berechnet deine Materialkosten anhand des hinterlegten Filamentpreises und des tatsächlichen Verbrauchs.',
        ),

        HelpSectionCard(
          icon: Icons.history_outlined,
          title: 'Druckhistorie',
          content:
              'Alle abgeschlossenen Druckaufträge fließen automatisch in deine Statistiken ein.',
        ),

        HelpSectionCard(
          icon: Icons.analytics_outlined,
          title: 'Auswertungen',
          content:
              'Nutze die Diagramme und Übersichten, um Verbrauch, Kosten und Materialeinsatz langfristig auszuwerten.',
        ),

        HelpTipCard(
          text:
              'Tipp: Je vollständiger deine Druckaufträge gepflegt sind, desto genauer werden die Statistiken.',
        ),
      ],
    );
  }
}
