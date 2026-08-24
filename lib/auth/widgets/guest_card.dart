import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class GuestCard extends StatelessWidget {
  final VoidCallback onPressed;

  const GuestCard({super.key, required this.onPressed});

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
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.guestMode,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              l10n.guestModeDescription,
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.guestModeDataInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.startAsGuest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}