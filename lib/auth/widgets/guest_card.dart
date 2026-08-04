import 'package:flutter/material.dart';

class GuestCard extends StatelessWidget {
  final VoidCallback onPressed;

  const GuestCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Gastmodus',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Testen Sie den Filament Manager 7 Tage kostenlos und ohne Registrierung.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'Alle während dieser Zeit erstellten Daten bleiben erhalten und können später in ein Benutzerkonto übernommen werden.',
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
                label: const Text('Als Gast starten'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
