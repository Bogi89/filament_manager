import 'package:flutter/material.dart';

import '../services/auth_validator.dart';
import 'verify_email_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final l10n = AppLocalizations.of(context)!;

try {
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );

  await FirebaseAuth.instance.currentUser?.sendEmailVerification();

  if (!mounted) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const VerifyEmailPage(),
    ),
  );
} on FirebaseAuthException catch (e) {
  String message = l10n.registrationFailed;

  if (e.code == 'email-already-in-use') {
    message = l10n.emailAlreadyInUse;
  }

  if (e.code == 'weak-password') {
    message = l10n.weakPassword;
  }

  if (e.code == 'invalid-email') {
    message = l10n.invalidEmail;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
}

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
  title: Text(l10n.registerAppBarTitle),
),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),

                    const SizedBox(height: 24),

                    Text(
  l10n.registerTitle,
  textAlign: TextAlign.center,
  style: theme.textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
  ),
),

                    const SizedBox(height: 8),

                    Text(
  l10n.registerSubtitle,
  textAlign: TextAlign.center,
  style: theme.textTheme.bodyLarge,
),

                    const SizedBox(height: 32),

                   TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  onFieldSubmitted: (_) =>
      FocusScope.of(context).nextFocus(),
  autofillHints: const [AutofillHints.email],
  decoration: InputDecoration(
    labelText: l10n.email,
    prefixIcon: const Icon(Icons.email_outlined),
  ),
  validator: AuthValidator.validateEmail,
),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: AuthValidator.validatePassword,
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureRepeatPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: InputDecoration(
                        labelText: l10n.repeatPassword,
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureRepeatPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureRepeatPassword = !_obscureRepeatPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          AuthValidator.validateConfirmPassword(
                            _passwordController.text,
                            value,
                          ),
                    ),

                    const SizedBox(height: 28),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: _register,
                          icon: const Icon(Icons.person_add_alt_1),
                          label: Text(l10n.registerButton),
                        ),

                        const SizedBox(height: 24),

                        Row(
  children: [
    const Expanded(child: Divider()),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(l10n.or),
    ),
    const Expanded(child: Divider()),
  ],
),

                        const SizedBox(height: 24),

                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: Text(l10n.continueWithGoogle),
                        ),
                      ],
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
