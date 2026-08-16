import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../pages/main_navigation.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {

  Future<void> _checkEmailVerification() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return;
  }

  await user.reload();

  final updatedUser = FirebaseAuth.instance.currentUser;

  if (updatedUser?.emailVerified == true) {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigation(),
      ),
      (route) => false,
    );
  } else {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'E-Mail wurde noch nicht bestätigt.',
        ),
      ),
    );
  }
}

Future<void> _sendVerificationEmail() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return;
  }

  await user.sendEmailVerification();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Bestätigungs-E-Mail wurde erneut gesendet.',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('E-Mail bestätigen')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Fast geschafft',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Wir haben dir eine Bestätigungs-E-Mail gesendet.\n\nBitte öffne den Link in der E-Mail, um dein Benutzerkonto zu aktivieren.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 32),

                  FilledButton.icon(
  onPressed: _checkEmailVerification,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut prüfen'),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _sendVerificationEmail,
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('E-Mail erneut senden'),
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
