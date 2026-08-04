import 'package:flutter/material.dart';

import 'legal_page_template.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Nutzungsbedingungen',
      lastUpdated: 'August 2026',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Die Nutzungsbedingungen werden für Version 1.0 erstellt.',
          ),
        ],
      ),
    );
  }
}