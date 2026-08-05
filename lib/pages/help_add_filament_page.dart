import 'package:flutter/material.dart';

import '../widgets/common/help_page_template.dart';

class HelpAddFilamentPage extends StatelessWidget {
  const HelpAddFilamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HelpPageTemplate(
      title: 'Filament hinzufügen',
      introduction:
          'Auf dieser Seite erfährst du, wie du ein neues Filament korrekt anlegst und welche Informationen dafür benötigt werden.',

      children: [
        HelpSectionCard(
          icon: Icons.add_circle_outline,
          title: 'Neues Filament anlegen',
          content:
              'Öffne den Filamentbereich und tippe auf die Schaltfläche zum Hinzufügen eines neuen Filaments.',
        ),

        HelpSectionCard(
          icon: Icons.category_outlined,
          title: 'Filament auswählen',
          content:
              'Wähle Hersteller, Material, Variante und Farbe aus. Viele Werte werden automatisch aus dem Filamentkatalog übernommen.',
        ),

        HelpSectionCard(
          icon: Icons.settings_outlined,
          title: 'Druckeinstellungen',
          content:
              'Kontrolliere Durchmesser sowie Düsen- und Betttemperatur. Diese Werte werden abhängig vom Material automatisch vorgeschlagen.',
        ),

        HelpSectionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Bestand und Kosten',
          content:
              'Lege das Spulengewicht, den aktuellen Bestand und den Kaufpreis fest. Diese Angaben werden später für Kostenberechnung und Lagerverwaltung verwendet.',
        ),

        HelpTipCard(
          text:
              'Tipp: Nutze möglichst den integrierten Filamentkatalog. Dadurch werden viele Eingaben automatisch ausgefüllt und Eingabefehler vermieden.',
        ),
      ],
    );
  }
}
