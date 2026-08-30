import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../pages/main_navigation.dart';
import '../../services/access_service.dart';
import 'splash_page.dart';
import 'trial_expired_page.dart';
import 'verify_email_page.dart';
import 'welcome_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const Duration _minimumSplashDuration =
      Duration(milliseconds: 1200);

  bool _loading = true;

  User? _firebaseUser;

  AccessStatus _accessStatus =
      AccessStatus.noAccess;

  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    final stopwatch = Stopwatch()..start();

    /*
     * Wichtig für Flutter Web:
     *
     * Firebase Auth benötigt beim Neuladen der Webseite möglicherweise
     * einen kurzen Moment, bis die gespeicherte Anmeldung wiederhergestellt
     * wurde.
     *
     * Deshalb registrieren wir den Auth-Listener BEVOR der erste
     * Zugriffsstatus ausgewertet wird.
     */
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(
      (_) async {
        await _loadState();
      },
    );

    /*
     * Auf den ersten von Firebase vollständig aufgelösten Auth-Status
     * warten. Dadurch verhindern wir, dass ein angemeldeter Benutzer
     * während eines Web-Reloads kurzfristig als Gast behandelt wird.
     */
    await FirebaseAuth.instance.authStateChanges().first;

    await _loadState();

    final remaining =
        _minimumSplashDuration - stopwatch.elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(
        remaining,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadState() async {
    final firebaseUser =
        FirebaseAuth.instance.currentUser;

    final accessStatus =
        await AccessService.getAccessStatus();

    if (!mounted) {
      return;
    }

    setState(() {
      _firebaseUser = firebaseUser;
      _accessStatus = accessStatus;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashPage();
    }

    final firebaseUser = _firebaseUser;

    /// Ein angemeldeter Benutzer muss zuerst
    /// seine E-Mail-Adresse bestätigen.
    if (firebaseUser != null &&
        !firebaseUser.emailVerified) {
      return const VerifyEmailPage();
    }

    /// Voller Zugriff während der Testphase
    /// oder bei aktivem Premium.
    if (_accessStatus ==
            AccessStatus.guestTrialActive ||
        _accessStatus ==
            AccessStatus.accountTrialActive ||
        _accessStatus ==
            AccessStatus.premiumActive) {
      return const MainNavigation();
    }

    /// Testphase ist abgelaufen.
    if (_accessStatus ==
            AccessStatus.guestTrialExpired ||
        _accessStatus ==
            AccessStatus.accountTrialExpired) {
      return const TrialExpiredPage();
    }

    /// Kein aktiver Zugriff.
    return const WelcomePage();
  }
}