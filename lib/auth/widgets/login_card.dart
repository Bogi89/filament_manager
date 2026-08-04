import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginCard({super.key, required this.onPressed});

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
                Icon(Icons.login, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Anmelden',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Melden Sie sich mit Ihrem bestehenden Benutzerkonto an.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'Ihre Daten werden automatisch synchronisiert und stehen Ihnen auf Android und in der Web-Version zur Verfügung.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.login),
                label: const Text('Anmelden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
