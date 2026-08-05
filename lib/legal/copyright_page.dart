import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class CopyrightPage extends StatelessWidget {
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Urheberrecht',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.copyright_outlined,
            title: 'Urheberrechte',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('App'),
                  subtitle: Text(
                    'Der Filament Manager sowie sämtliche Inhalte, Designs und Quelltexte sind urheberrechtlich geschützt.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Nutzung'),
                  subtitle: Text(
                    'Eine Vervielfältigung, Veröffentlichung oder Weitergabe ist ohne ausdrückliche Zustimmung nicht gestattet.',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.image_outlined,
            title: 'Grafiken & Inhalte',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Eigene Inhalte'),
                  subtitle: Text(
                    'Eigene Grafiken, Texte und Logos unterliegen dem Urheberrecht des Entwicklers.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Drittanbieter'),
                  subtitle: Text(
                    'Verwendete Inhalte Dritter werden entsprechend ihrer jeweiligen Lizenz eingesetzt.',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.gavel_outlined,
            title: 'Lizenzhinweis',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Open-Source'),
                  subtitle: Text(
                    'Open-Source-Komponenten werden entsprechend ihrer jeweiligen Lizenz verwendet.',
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
