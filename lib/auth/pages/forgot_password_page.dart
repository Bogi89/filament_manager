import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_loading_service.dart';
import '../../l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final loadingService = context.watch<AuthLoadingService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
      ),
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
                    Icons.lock_reset,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    l10n.resetPassword,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.resetPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FilledButton.icon(
                    onPressed: loadingService.loading
                        ? null
                        : () async {
                            loadingService.startLoading();

                            await Future.delayed(
                              const Duration(seconds: 2),
                            );

                            loadingService.stopLoading();
                          },
                    icon: loadingService.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
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
    );
  }
}