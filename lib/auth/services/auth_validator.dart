class AuthValidator {
  const AuthValidator._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte gib deine E-Mail-Adresse ein.';
    }

    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Bitte gib eine gültige E-Mail-Adresse ein.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte gib dein Passwort ein.';
    }

    if (value.length < 8) {
      return 'Das Passwort muss mindestens 8 Zeichen lang sein.';
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Bitte wiederhole dein Passwort.';
    }

    if (password != confirmPassword) {
      return 'Die Passwörter stimmen nicht überein.';
    }

    return null;
  }
}
