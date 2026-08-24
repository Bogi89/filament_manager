import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class RegisterCard extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_add_alt_1_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.registerAccount,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              l10n.registerAccountDescription,
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.registerAccountDataInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(l10n.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}