import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Premium & Abonnement',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.workspace_premium_outlined,
            title: 'Premium-Mitgliedschaft',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Premium'),
                  subtitle: Text(
                    'Der Filament Manager kann sieben Tage kostenlos getestet werden. Anschließend ist für die weitere Nutzung eine Premium-Mitgliedschaft erforderlich.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Testphase'),
                  subtitle: Text(
                    'Während der siebentägigen Testphase stehen sämtliche Funktionen uneingeschränkt zur Verfügung.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.payments_outlined,
            title: 'Abrechnung',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Zahlungsabwicklung'),
                  subtitle: Text(
                    'Auf Android erfolgt die Zahlungsabwicklung über Google Play. Für die Web-Version erfolgt sie über die offizielle Website mit PayPal.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Plattformen'),
                  subtitle: Text(
                    'Auf Android erfolgt der Abschluss über Google Play. Für die Web-Version kann Premium über die offizielle Website mit PayPal erworben werden.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.star_outline,
            title: 'Testphase & Premium',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('7-Tage-Test'),
                  subtitle: Text(
                    'Neue Nutzer können den Filament Manager sieben Tage kostenlos testen.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Nach Ablauf'),
                  subtitle: Text(
                    'Nach Ablauf der Testphase ist eine Premium-Mitgliedschaft erforderlich, um die App weiter nutzen zu können.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.event_available_outlined,
            title: 'Mitgliedschaft',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Laufzeiten'),
                  subtitle: Text(
                    'Premium wird als monatliche oder jährliche Mitgliedschaft angeboten.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Kündigung'),
                  subtitle: Text(
                    'Eine Kündigung ist jederzeit zum Ende der jeweiligen Laufzeit möglich.',
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
