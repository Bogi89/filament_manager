import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'pages/main_navigation.dart';
import 'l10n/app_localizations.dart';
import 'services/filament_catalog_service.dart';

// 🔥 Neues Theme importieren
import 'theme/app_theme.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await FilamentCatalogService.loadCatalog();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadSettings(),
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

      home: const MainNavigation(),
    );
  }
}