import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class LiabilityPage extends StatelessWidget {
  const LiabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Haftung',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.gpp_good_outlined,
            title: 'Haftung für Inhalte',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Sorgfalt'),
                  subtitle: Text(
                    'Alle Inhalte dieser App wurden mit größter Sorgfalt erstellt und werden regelmäßig überprüft.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Keine Gewähr'),
                  subtitle: Text(
                    'Für die Richtigkeit, Vollständigkeit und Aktualität der bereitgestellten Informationen kann jedoch keine Gewähr übernommen werden.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.link_outlined,
            title: 'Externe Inhalte',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Links'),
                  subtitle: Text(
                    'Für Inhalte externer Websites oder Dienste, auf die verwiesen wird, sind ausschließlich deren Betreiber verantwortlich.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.warning_amber_outlined,
            title: 'Haftungsbeschränkung',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Nutzung der App'),
                  subtitle: Text(
                    'Die Nutzung des Filament Managers erfolgt im Rahmen der gesetzlichen Bestimmungen auf eigene Verantwortung.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
