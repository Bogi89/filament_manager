import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class ImprintPage extends StatelessWidget {
  const ImprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Impressum',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.person_outline,
            title: 'Angaben zum Anbieter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('App-Name'),
                  subtitle: Text('Filament Manager (Arbeitstitel)'),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Entwickler'),
                  subtitle: Text('Robin'),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Anschrift'),
                  subtitle: Text('Wird vor Release ergänzt'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.email_outlined,
            title: 'Kontakt',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('E-Mail'),
                  subtitle: Text('support@deine-domain.de'),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Website'),
                  subtitle: Text('https://deine-domain.de'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.business_outlined,
            title: 'Unternehmensinformationen',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Unternehmensform'),
                  subtitle: Text('Wird vor Release ergänzt'),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Unternehmensgegenstand'),
                  subtitle: Text(
                    'Bereitstellung einer Anwendung zur Verwaltung von 3D-Druck-Filamenten.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.gavel_outlined,
            title: 'Rechtliche Hinweise',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Haftung'),
                  subtitle: Text(
                    'Weitere Informationen findest du auf der Seite „Haftung“.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Urheberrecht'),
                  subtitle: Text(
                    'Weitere Informationen findest du auf der Seite „Urheberrecht“.',
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
