import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class ImageCreditsPage extends StatelessWidget {
  const ImageCreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Bildnachweise',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.image_outlined,
            title: 'Verwendete Grafiken',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Eigene Grafiken'),
                  subtitle: Text(
                    'Alle selbst erstellten Grafiken, Logos und Illustrationen unterliegen dem Urheberrecht des Entwicklers.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('App-Icons'),
                  subtitle: Text(
                    'Verwendete Icons stammen aus den offiziellen Flutter Material Icons.',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.palette_outlined,
            title: 'Farben & Design',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Benutzeroberfläche'),
                  subtitle: Text(
                    'Das Design des Filament Managers wurde eigenständig entwickelt.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Marken'),
                  subtitle: Text(
                    'Markennamen und Herstellerbezeichnungen bleiben Eigentum ihrer jeweiligen Inhaber.',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.info_outline,
            title: 'Hinweis',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Aktualisierung'),
                  subtitle: Text(
                    'Sollten künftig weitere Bilder oder externe Grafiken verwendet werden, werden deren Bildnachweise an dieser Stelle ergänzt.',
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
