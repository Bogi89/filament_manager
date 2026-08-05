import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class ConsumerInformationPage extends StatelessWidget {
  const ConsumerInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Verbraucherinformationen',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.info_outline,
            title: 'Anbieter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Verantwortlicher'),
                  subtitle: Text(
                    'Die Angaben zum Anbieter befinden sich im Impressum.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Kontakt'),
                  subtitle: Text(
                    'Fragen können jederzeit über die im Impressum angegebenen Kontaktdaten gestellt werden.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.receipt_long_outlined,
            title: 'Vertragsinformationen',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Premium-Mitgliedschaft'),
                  subtitle: Text(
                    'Vor Abschluss einer Premium-Mitgliedschaft werden alle wesentlichen Informationen zu Preis, Laufzeit und Zahlungsweise angezeigt.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Vertragsschluss'),
                  subtitle: Text(
                    'Der Vertrag kommt erst mit erfolgreichem Abschluss des jeweiligen Kaufvorgangs zustande.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Hilfe'),
                  subtitle: Text(
                    'Bei Fragen oder Problemen steht der Support über die offiziellen Kontaktmöglichkeiten zur Verfügung.',
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
