import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Design",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          RadioListTile<ThemeMode>(
            title: const Text("Hell"),
            value: ThemeMode.light,
            groupValue: appState.themeMode,
            onChanged: (value) {
              if (value != null) {
                appState.setThemeMode(value);
              }
            },
          ),

          RadioListTile<ThemeMode>(
            title: const Text("Dunkel"),
            value: ThemeMode.dark,
            groupValue: appState.themeMode,
            onChanged: (value) {
              if (value != null) {
                appState.setThemeMode(value);
              }
            },
          ),

          RadioListTile<ThemeMode>(
            title: const Text("System"),
            value: ThemeMode.system,
            groupValue: appState.themeMode,
            onChanged: (value) {
              if (value != null) {
                appState.setThemeMode(value);
              }
            },
          ),

          const Divider(height: 40),

          const Text(
            "Sprache",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          RadioListTile<String>(
            title: const Text("Deutsch"),
            value: 'de',
            groupValue: appState.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                appState.setLocale(Locale(value));
              }
            },
          ),

          RadioListTile<String>(
            title: const Text("English"),
            value: 'en',
            groupValue: appState.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                appState.setLocale(Locale(value));
              }
            },
          ),

          const Divider(height: 40),

          const Text(
            "Warnung Filament",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "Warnung unter ${appState.warningPercent.toStringAsFixed(0)} %",
          ),

          Slider(
            value: appState.warningPercent,
            min: 5,
            max: 50,
            divisions: 45,
            label: "${appState.warningPercent.toStringAsFixed(0)}%",
            onChanged: (value) {
              appState.setWarningPercent(value);
            },
          ),
        ],
      ),
    );
  }
}