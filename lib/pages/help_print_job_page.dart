import 'package:flutter/material.dart';

import '../widgets/common/help_page_template.dart';

class HelpPrintJobPage extends StatelessWidget {
  const HelpPrintJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpPageTemplate(
      title: 'Druckauftrag erstellen',
      introduction:
          'Mit einem Druckauftrag dokumentierst du deine Drucke und der Filamentverbrauch wird automatisch berechnet.',

      children: [
        HelpSectionCard(
          icon: Icons.playlist_add_outlined,
          title: 'Neuen Druckauftrag erstellen',
          content:
              'Öffne den Bereich "Historie" und lege einen neuen Druckauftrag an.',
        ),

        HelpSectionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Filament auswählen',
          content:
              'Wähle das verwendete Filament aus deinem Bestand aus. Nur vorhandene Filamente können verwendet werden.',
        ),

        HelpSectionCard(
          icon: Icons.scale_outlined,
          title: 'Verbrauch eingeben',
          content:
              'Gib an, wie viele Gramm Filament verbraucht wurden. Der Bestand wird anschließend automatisch aktualisiert.',
        ),

        HelpSectionCard(
          icon: Icons.receipt_long_outlined,
          title: 'Druckinformationen',
          content:
              'Optional kannst du Druckdauer, Drucker, Notizen oder weitere Informationen speichern, um später den Überblick zu behalten.',
        ),

        HelpTipCard(
          text:
              'Tipp: Trage deine Druckaufträge möglichst direkt nach dem Druck ein. So bleiben Bestand und Statistiken immer aktuell.',
        ),
      ],
    );
  }
}
