import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../pages/main_navigation.dart';
import '../services/guest_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() =>
      _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkEmailVerification() async {
    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await user.reload();

      final updatedUser =
          FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified != true) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'E-Mail wurde noch nicht bestätigt.',
            ),
          ),
        );

        return;
      }

      await GuestService.disableGuestMode();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die E-Mail-Bestätigung konnte nicht überprüft werden. '
            'Bitte versuche es erneut.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die E-Mail-Bestätigung konnte nicht überprüft werden. '
            'Bitte versuche es erneut.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bestätigungs-E-Mail wurde erneut gesendet.',
          ),
        ),
      );
    } on FirebaseAuthException catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die Bestätigungs-E-Mail konnte nicht gesendet werden.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Mail bestätigen'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
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
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wir haben dir eine Bestätigungs-E-Mail '
                    'gesendet.\n\nBitte öffne den Link in der '
                    'E-Mail, um dein Benutzerkonto zu aktivieren.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _isChecking
                        ? null
                        : _checkEmailVerification,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isChecking
                          ? 'Wird geprüft...'
                          : 'Erneut prüfen',
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isResending
                        ? null
                        : _sendVerificationEmail,
                    icon: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.mail_outline),
                    label: Text(
                      _isResending
                          ? 'Wird gesendet...'
                          : 'E-Mail erneut senden',
                    ),
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