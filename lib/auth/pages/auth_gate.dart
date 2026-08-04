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

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final guestEnabled = await GuestService.isGuestModeEnabled();

    if (!mounted) return;

    setState(() {
      _guestMode = guestEnabled;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashPage();
    }

    if (_guestMode) {
      return const MainNavigation();
    }

    return const WelcomePage();
  }
}
