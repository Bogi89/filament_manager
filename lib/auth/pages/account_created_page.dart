import 'package:flutter/material.dart';

class AccountCreatedPage extends StatelessWidget {
  const AccountCreatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Konto erstellt')),
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
                    'Konto erfolgreich erstellt',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Dein Benutzerkonto wurde erfolgreich erstellt.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Bitte bestätige jetzt deine E-Mail-Adresse. Anschließend kannst du dich anmelden und den Filament Manager nutzen.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('E-Mail bestätigt'),
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
