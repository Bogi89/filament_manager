import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../widgets/common/page_header.dart';
import '../widgets/common/app_hover_card.dart';
import '../widgets/settings/expandable_settings_card.dart';
import '../legal/privacy_policy_page.dart';
import '../legal/imprint_page.dart';
import '../legal/terms_of_service_page.dart';

import '../state/app_state.dart';
import '../models/filament.dart';
import '../models/print_job.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_links.dart';

import 'dart:async';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// 🔹 EXPORT BACKUP

  void _exportBackup(AppState appState) {
    final Map<String, dynamic> backupData = {
      "filaments": appState.filaments.map((f) => f.toJson()).toList(),

      "jobs": appState.jobs.map((j) => j.toJson()).toList(),

      "exportDate": DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

    final bytes = utf8.encode(jsonString);

    final blob = html.Blob([bytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "filament_backup.json")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// 🔹 IMPORT BACKUP

  void _importBackup(BuildContext context, AppState appState) {
    final uploadInput = html.FileUploadInputElement();

    uploadInput.accept = ".json";

    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;

      if (file == null) return;

      final reader = html.FileReader();

      reader.readAsText(file);

      reader.onLoadEnd.listen((event) {
        try {
          final jsonData = jsonDecode(reader.result as String);

          /// Filamente laden

          final List<Filament> loadedFilaments = (jsonData["filaments"] as List)
              .map((e) => Filament.fromJson(e))
              .toList();

          /// Jobs laden

          final List<PrintJob> loadedJobs = (jsonData["jobs"] as List)
              .map((e) => PrintJob.fromJson(e))
              .toList();

          /// Bestehende Daten ersetzen

          appState.filaments
            ..clear()
            ..addAll(loadedFilaments);

          appState.jobs
            ..clear()
            ..addAll(loadedJobs);

          appState.saveData();

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Backup erfolgreich geladen")),
          );
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fehler beim Laden des Backups")),
          );
        }
      });
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

        children: [
          const PageHeader(title: "Einstellungen"),

          const SizedBox(height: 24),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Design",
              icon: Icons.palette_outlined,
              child: Column(
                children: [
                  RadioListTile<ThemeMode>.adaptive(
                    title: const Text("Hell"),
                    value: ThemeMode.light,
                    groupValue: appState.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setThemeMode(value);
                      }
                    },
                  ),

                  RadioListTile<ThemeMode>.adaptive(
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
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Sprache",
              icon: Icons.language,
              child: Column(
                children: [
                  RadioListTile<String>.adaptive(
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/flags/de.png',
                          width: 24,
                          height: 16,
                        ),
                        const SizedBox(width: 10),
                        const Text("Deutsch"),
                      ],
                    ),
                    value: 'de',
                    groupValue: appState.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setLocale(Locale(value));
                      }
                    },
                  ),

                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/flags/en.png',
                          width: 24,
                          height: 16,
                        ),
                        const SizedBox(width: 10),
                        const Text("English"),
                      ],
                    ),
                    value: 'en',
                    groupValue: appState.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setLocale(Locale(value));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Warnung Filament",
              icon: Icons.warning_amber_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Warnung unter ${appState.warningPercent.toStringAsFixed(0)} %",
                  ),

                  const SizedBox(height: 12),

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
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Backup",
              icon: Icons.backup_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Backup exportieren"),
                    onPressed: () {
                      _exportBackup(appState);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Backup erstellt")),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text("Backup importieren"),
                    onPressed: () {
                      _importBackup(context, appState);
                    },
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Exportiert und importiert Filamente und Druckjobs.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Support",
              icon: Icons.support_agent,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: const Text("Feedback senden"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final subject = Uri.encodeComponent(
                        'Feedback Filament Manager',
                      );

                      final body = Uri.encodeComponent(
                        'Hallo Robin,\n\n'
                        'ich habe folgendes Feedback oder einen Verbesserungsvorschlag:\n\n'
                        '----------------------------------------\n\n',
                      );

                      _openUrl(
                        'mailto:${AppLinks.supportMail}?subject=$subject&body=$body',
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text("Fehler melden"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final subject = Uri.encodeComponent(
                        'Fehlerbericht Filament Manager',
                      );

                      final body = Uri.encodeComponent(
                        'Hallo,\n\n'
                        'ich habe folgenden Fehler gefunden.\n\n'
                        '----------------------------------------\n\n'
                        'App-Version:\n\n'
                        'Gerät:\n\n'
                        'Browser (bei Web):\n\n'
                        'Beschreibung:\n\n'
                        'Schritte zum Nachstellen:\n\n'
                        '----------------------------------------\n',
                      );

                      _openUrl(
                        'mailto:${AppLinks.supportMail}?subject=$subject&body=$body',
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text("App bewerten"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text("Kontakt"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final subject = Uri.encodeComponent(
                        'Support Filament Manager',
                      );

                      final body = Uri.encodeComponent(
                        'Hallo,\n\n'
                        'ich benötige Hilfe bei folgendem Thema.\n\n'
                        '----------------------------------------\n\n'
                        'Beschreibung:\n\n'
                        '----------------------------------------\n\n'
                        'Vielen Dank.',
                      );

                      _openUrl(
                        'mailto:${AppLinks.supportMail}?subject=$subject&body=$body',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Hilfe",
              icon: Icons.help_outline,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: const Text("Erste Schritte"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text("Filament hinzufügen"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.print_outlined),
                    title: const Text("Druckauftrag erstellen"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: const Text("Statistiken verstehen"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text("Backup & Wiederherstellung"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Was ist neu",
              icon: Icons.new_releases_outlined,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: const Text("Version 1.0"),
                    subtitle: const Text("Erstes offizielles Release"),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.update_outlined),
                    title: const Text("Versionsverlauf"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Rechtliches",
              icon: Icons.gavel_outlined,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text("Datenschutzerklärung"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text("Impressum"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ImprintPage()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text("Nutzungsbedingungen"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServicePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Konto",
              icon: Icons.person_outline,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text("Anmelden"),
                    subtitle: const Text(
                      "Mit einem bestehenden Konto anmelden.",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1),
                    title: const Text("Konto erstellen"),
                    subtitle: const Text("Ein neues Benutzerkonto erstellen."),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Abmelden"),
                    subtitle: const Text("Vom aktuellen Konto abmelden."),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: "Über",
              icon: Icons.info_outline,
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("Filament Manager"),
                    subtitle: Text("Version 1.0.0"),
                  ),

                  const Divider(),

                  const ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text("Entwickler"),
                    subtitle: Text("Robin"),
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Website"),
                    subtitle: const Text("filament-manager.web.app"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _openUrl(AppLinks.website);
                    },
                  ),

                  const Divider(),

                  const ListTile(
                    leading: Icon(Icons.favorite_outline),
                    title: Text("Vielen Dank"),
                    subtitle: Text(
                      "Vielen Dank, dass du den Filament Manager verwendest.",
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text("Open-Source-Lizenzen"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
