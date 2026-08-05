import 'package:flutter/material.dart';
import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Datenschutzerklärung',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Verantwortlicher',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Verantwortlich'),
                  subtitle: Text('Robin'),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Kontakt'),
                  subtitle: Text('Wird vor Release ergänzt'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.storage_outlined,
            title: 'Welche Daten werden gespeichert?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Lokal gespeicherte Daten'),
                  subtitle: Text(
                    'Filamente, Druckaufträge, Einstellungen und Statistiken werden lokal auf deinem Gerät gespeichert.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Keine Weitergabe'),
                  subtitle: Text(
                    'Es erfolgt keine Weitergabe personenbezogener Daten an Dritte, sofern dies nicht für die Nutzung der App erforderlich ist.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.person_outline,
            title: 'Gastmodus & Benutzerkonto',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Gastmodus'),
                  subtitle: Text(
                    'Die Nutzung der App ist im Gastmodus ohne Registrierung möglich. Die Daten bleiben ausschließlich auf dem Gerät gespeichert.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Benutzerkonto'),
                  subtitle: Text(
                    'Bei Verwendung eines Benutzerkontos können Daten zukünftig mit unterstützten Geräten synchronisiert werden.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.lock_outline,
            title: 'Deine Rechte',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Datenschutzrechte'),
                  subtitle: Text(
                    'Du hast das Recht auf Auskunft, Berichtigung, Löschung und Einschränkung der Verarbeitung deiner personenbezogenen Daten im Rahmen der geltenden Datenschutzgesetze.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.contact_support_outlined,
            title: 'Fragen zum Datenschutz',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Kontakt'),
                  subtitle: Text(
                    'Bei Fragen zum Datenschutz kannst du uns über die im Impressum angegebenen Kontaktdaten erreichen.',
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
