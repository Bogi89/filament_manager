import 'package:flutter/material.dart';

import 'legal_page_template.dart';

class ImprintPage extends StatelessWidget {
  const ImprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageTemplate(
      title: 'Impressum',
      lastUpdated: 'August 2026',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Das Impressum wird für Version 1.0 erstellt.')],
      ),
    );
  }
}
