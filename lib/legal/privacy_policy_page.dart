import 'package:flutter/material.dart';
import 'legal_page_template.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Datenschutzerklärung',
      lastUpdated: 'August 2026',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Die Datenschutzerklärung wird für Version 1.0 erstellt.'),
        ],
      ),
    );
  }
}
