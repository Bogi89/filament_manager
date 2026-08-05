import 'package:flutter/material.dart';

import 'legal_page_template.dart';
import 'widgets/legal_info_card.dart';

class WithdrawalPage extends StatelessWidget {
  const WithdrawalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Widerrufsbelehrung',
      lastUpdated: 'August 2026',
      child: Column(
        children: [
          LegalInfoCard(
            icon: Icons.assignment_return_outlined,
            title: 'Widerrufsrecht',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Digitale Inhalte'),
                  subtitle: Text(
                    'Premium-Mitgliedschaften stellen digitale Inhalte bzw. digitale Dienstleistungen dar.',
                  ),
                ),

                Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Beginn der Nutzung'),
                  subtitle: Text(
                    'Mit Beginn der Nutzung der Premium-Mitgliedschaft kann das gesetzliche Widerrufsrecht nach den geltenden gesetzlichen Bestimmungen erlöschen.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LegalInfoCard(
            icon: Icons.info_outline,
            title: 'Hinweis',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Weitere Informationen'),
                  subtitle: Text(
                    'Vor Abschluss einer Premium-Mitgliedschaft werden alle gesetzlich erforderlichen Informationen zum Widerrufsrecht bereitgestellt.',
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
