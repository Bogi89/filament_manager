import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AccountCreatedPage extends StatelessWidget {
  const AccountCreatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountCreated),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    l10n.accountSuccessfullyCreated,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.accountCreatedDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    l10n.accountCreatedEmailVerificationInfo,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: Text(l10n.emailConfirmed),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}