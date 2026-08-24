import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../pages/main_navigation.dart';
import '../services/guest_service.dart';
import 'splash_page.dart';
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
  bool _guestMode = false;
  bool _trialExpired = false;
  User? _firebaseUser;

  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    final stopwatch = Stopwatch()..start();

    await _loadState();

    final remaining =
        _minimumSplashDuration - stopwatch.elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        await _loadState();
      },
    );
  }

  Future<void> _loadState() async {
    final firebaseUser =
        FirebaseAuth.instance.currentUser;

    final guestEnabled =
        await GuestService.isGuestModeEnabled();

    final guestStartDate =
        await GuestService.getGuestStartDate();

    final trialExpired =
        guestStartDate != null &&
        DateTime.now()
                .difference(guestStartDate)
                .inDays >=
            7;

    if (!mounted) return;

    setState(() {
      _firebaseUser = firebaseUser;
      _guestMode = guestEnabled;
      _trialExpired = trialExpired;
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

    if (firebaseUser != null) {
      if (firebaseUser.emailVerified) {
        return const MainNavigation();
      }

      return const VerifyEmailPage();
    }

    if (_guestMode && !_trialExpired) {
      return const MainNavigation();
    }

    return const WelcomePage();
  }
}