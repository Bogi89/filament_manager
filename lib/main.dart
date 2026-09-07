import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'l10n/app_localizations.dart';
import 'services/filament_catalog_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_test_service.dart';
import 'auth/pages/auth_gate.dart';
import 'auth/pages/paddle_test_page.dart';
import 'legal/premium_page.dart';
import 'legal/privacy_policy_page.dart';
import 'legal/terms_of_service_page.dart';
import 'legal/withdrawal_page.dart';
import 'legal/refund_policy_page.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// 🔥 Neues Theme importieren
import 'theme/app_theme.dart';
import 'auth/services/auth_loading_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await HiveTestService.saveTestValue('Sakura Pink');

  await FilamentCatalogService.loadCatalog();

  final appState = AppState();
  await appState.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => AuthLoadingService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: appState.locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      themeMode: appState.themeMode,

      // 🔥 Neues Design-System Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      routes: {
        '/': (_) => const AuthGate(),
        '/premium': (_) => const PremiumPage(),
        '/terms': (_) => const TermsOfServicePage(),
        '/privacy': (_) => const PrivacyPolicyPage(),
        '/withdrawal': (_) => const WithdrawalPage(),
        '/refund': (_) => const RefundPolicyPage(),

        // Temporäre Route für den Paddle-Sandbox-Test
        '/paddle-test': (_) => const PaddleTestPage(),
      },
    );
  }
}