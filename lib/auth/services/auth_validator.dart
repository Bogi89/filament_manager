import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AuthValidator {
  const AuthValidator._();

  static String? validateEmail(
    BuildContext context,
    String? value,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }

    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegExp.hasMatch(value.trim())) {
      return l10n.emailInvalid;
    }

    return null;
  }

  static String? validatePassword(
    BuildContext context,
    String? value,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }

    if (value.length < 8) {
      return l10n.passwordTooShort;
    }

    return null;
  }

  static String? validateConfirmPassword(
    BuildContext context,
    String? password,
    String? confirmPassword,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (confirmPassword == null || confirmPassword.isEmpty) {
      return l10n.confirmPasswordRequired;
    }

    if (password != confirmPassword) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }
}