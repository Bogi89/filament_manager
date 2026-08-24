import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../services/auth_loading_service.dart';
import '../services/auth_validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loadingService =
        context.read<AuthLoadingService>();

    final l10n =
        AppLocalizations.of(context)!;

    try {
      loadingService.startLoading();

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.resetPasswordSent,
          ),
        ),
      );
    } on FirebaseAuthException catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.resetPasswordFailed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.resetPasswordFailed,
          ),
        ),
      );
    } finally {
      loadingService.stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n =
        AppLocalizations.of(context)!;

    final loadingService =
        context.watch<AuthLoadingService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.forgotPassword,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_reset,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.resetPassword,
                      textAlign: TextAlign.center,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.resetPasswordSubtitle,
                      textAlign: TextAlign.center,
                      style:
                          theme.textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      onFieldSubmitted: (_) {
                        if (!loadingService.loading) {
                          _sendResetLink();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                      ),
                      validator: (value) =>
                          AuthValidator.validateEmail(
                        context,
                        value,
                      ),
                    ),

                    const SizedBox(height: 28),

                    FilledButton.icon(
                      onPressed: loadingService.loading
                          ? null
                          : _sendResetLink,
                      icon: loadingService.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                            ),
                      label: Text(
                        loadingService.loading
                            ? l10n.sendingResetLink
                            : l10n.sendResetLink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}