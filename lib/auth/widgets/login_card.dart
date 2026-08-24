import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LoginCard extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginCard({super.key, required this.onPressed});

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
                  Icons.login,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.login,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.loginDescription,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.loginDataInfo,
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
                label: Text(l10n.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}