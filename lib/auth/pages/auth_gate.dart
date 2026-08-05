import 'package:flutter/material.dart';

import '../../pages/main_navigation.dart';
import '../services/guest_service.dart';
import 'splash_page.dart';
import 'welcome_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _guestMode = false;
  bool _trialExpired = false;
  DateTime? _guestStartDate;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final guestEnabled = await GuestService.isGuestModeEnabled();
    final guestStartDate = await GuestService.getGuestStartDate();
    final trialExpired =
        guestStartDate != null &&
        DateTime.now().difference(guestStartDate).inDays >= 7;

    if (!mounted) return;

    setState(() {
      _guestMode = guestEnabled;
      _guestStartDate = guestStartDate;
      _trialExpired = trialExpired;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashPage();
    }

    if (_guestMode && !_trialExpired) {
      return const MainNavigation();
    }

    if (_guestMode && _trialExpired) {
      return const WelcomePage();
    }

    return const WelcomePage();
  }
}
