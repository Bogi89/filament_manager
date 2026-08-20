import 'package:flutter/material.dart';

import '../widgets/guest_card.dart';
import '../widgets/login_card.dart';
import '../widgets/register_card.dart';
import '../services/guest_service.dart';
import '../../pages/main_navigation.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo/logo_256.png',
                    width: 110,
                    height: 110,
                    errorBuilder: (context, error, stackTrace) {
                      return const FlutterLogo(size: 110);
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'FilaLog',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Smart Filament Management',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      _FeatureChip(
                        icon: Icons.inventory_2_outlined,
                        label: 'Filamente',
                      ),
                      _FeatureChip(
                        icon: Icons.print_outlined,
                        label: 'Druckaufträge',
                      ),
                      _FeatureChip(
                        icon: Icons.euro_outlined,
                        label: 'Kosten',
                      ),
                      _FeatureChip(
                        icon: Icons.bar_chart_outlined,
                        label: 'Statistiken',
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  GuestCard(
                    onPressed: () async {
                      await GuestService.enableGuestMode();

                      if (!context.mounted) return;

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  LoginCard(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  RegisterCard(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Datenschutz'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Impressum'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Nutzungsbedingungen'),
                      ),
                    ],
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

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}