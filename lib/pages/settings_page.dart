import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:html' as html;

import '../state/app_state.dart';
import '../models/filament.dart';
import '../models/print_job.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// 🔹 EXPORT BACKUP

  void _exportBackup(AppState appState) {

    final Map<String, dynamic> backupData = {

      "filaments":
          appState.filaments
              .map((f) => f.toJson())
              .toList(),

      "jobs":
          appState.jobs
              .map((j) => j.toJson())
              .toList(),

      "exportDate":
          DateTime.now().toIso8601String(),
    };

    final jsonString =
        const JsonEncoder.withIndent('  ')
            .convert(backupData);

    final bytes =
        utf8.encode(jsonString);

    final blob =
        html.Blob([bytes]);

    final url =
        html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute(
            "download",
            "filament_backup.json",
          )
          ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// 🔹 IMPORT BACKUP

  void _importBackup(
      BuildContext context,
      AppState appState,
      ) {

    final uploadInput =
        html.FileUploadInputElement();

    uploadInput.accept = ".json";

    uploadInput.click();

    uploadInput.onChange.listen((event) {

      final file =
          uploadInput.files?.first;

      if (file == null) return;

      final reader =
          html.FileReader();

      reader.readAsText(file);

      reader.onLoadEnd.listen((event) {

        try {

          final jsonData =
              jsonDecode(
                  reader.result as String);

          /// Filamente laden

          final List<Filament> loadedFilaments =
              (jsonData["filaments"] as List)
                  .map((e) =>
                      Filament.fromJson(e))
                  .toList();

          /// Jobs laden

          final List<PrintJob> loadedJobs =
              (jsonData["jobs"] as List)
                  .map((e) =>
                      PrintJob.fromJson(e))
                  .toList();

          /// Bestehende Daten ersetzen

          appState.filaments
            ..clear()
            ..addAll(loadedFilaments);

          appState.jobs
            ..clear()
            ..addAll(loadedJobs);

          appState.saveData();

          appState.notifyListeners();

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content:
                  Text("Backup erfolgreich geladen"),
            ),

          );

        }
        catch (e) {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content:
                  Text("Fehler beim Laden des Backups"),
            ),

          );

        }

      });

    });
  }

  @override
  Widget build(BuildContext context) {

    final appState =
        Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// DESIGN

          const Text(
            "Design",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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

          /// SPRACHE

          const Text(
            "Sprache",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          RadioListTile<String>(
            title: const Text("Deutsch"),
            value: 'de',
            groupValue:
                appState.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                appState.setLocale(
                    Locale(value));
              }
            },
          ),

          RadioListTile<String>(
            title: const Text("English"),
            value: 'en',
            groupValue:
                appState.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                appState.setLocale(
                    Locale(value));
              }
            },
          ),

          const Divider(height: 40),

          /// WARNUNG

          const Text(
            "Warnung Filament",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
            label:
                "${appState.warningPercent.toStringAsFixed(0)}%",
            onChanged: (value) {
              appState.setWarningPercent(value);
            },
          ),

          const Divider(height: 40),

          /// 🔥 BACKUP

          const Text(
            "Backup",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// EXPORT BUTTON

          ElevatedButton.icon(

            icon:
                const Icon(Icons.download),

            label: const Text(
              "Backup exportieren",
            ),

            onPressed: () {

              _exportBackup(appState);

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                const SnackBar(
                  content:
                      Text("Backup erstellt"),
                ),

              );

            },
          ),

          const SizedBox(height: 10),

          /// IMPORT BUTTON

          ElevatedButton.icon(

            icon:
                const Icon(Icons.upload),

            label: const Text(
              "Backup importieren",
            ),

            onPressed: () {

              _importBackup(
                context,
                appState,
              );

            },
          ),

          const SizedBox(height: 8),

          const Text(
            "Exportiert und importiert Filamente und Druckjobs.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

        ],
      ),
    );
  }
}