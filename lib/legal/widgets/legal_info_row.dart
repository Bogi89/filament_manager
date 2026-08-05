import 'package:flutter/material.dart';

class LegalInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const LegalInfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
