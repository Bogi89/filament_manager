import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/app_hover_card.dart';
import '../widgets/settings/expandable_settings_card.dart';
import '../legal/privacy_policy_page.dart';
import '../legal/imprint_page.dart';
import '../legal/terms_of_service_page.dart';
import '../legal/premium_page.dart';
import '../legal/withdrawal_page.dart';
import '../legal/consumer_information_page.dart';
import '../legal/liability_page.dart';
import '../legal/copyright_page.dart';
import '../legal/image_credits_page.dart';
import 'help_first_steps_page.dart';

import '../state/app_state.dart';
import '../models/filament.dart';
import '../models/print_job.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'help_add_filament_page.dart';
import 'help_print_job_page.dart';
import 'help_statistics_page.dart';
import 'help_backup_page.dart';
import 'whats_new_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/services/guest_service.dart';
import '../auth/pages/welcome_page.dart';
import '../auth/pages/login_page.dart';
import '../auth/pages/register_page.dart';
import '../l10n/app_localizations.dart';

import '../constants/app_links.dart';

import 'dart:async';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// 🔹 EXPORT BACKUP

Future<void> _exportBackup(AppState appState) async {
  final Map<String, dynamic> backupData = {
    "filaments": appState.filaments.map((f) => f.toJson()).toList(),
    "jobs": appState.jobs.map((j) => j.toJson()).toList(),
    "exportDate": DateTime.now().toIso8601String(),
  };

  final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
  final bytes = Uint8List.fromList(utf8.encode(jsonString));

  await FilePicker.saveFile(
    dialogTitle: 'Backup speichern',
    fileName: 'filament_backup.json',
    type: FileType.custom,
    allowedExtensions: ['json'],
    bytes: bytes,
  );
}

  /// 🔹 IMPORT BACKUP

Future<void> _importBackup(
  BuildContext context,
  AppState appState,
) async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      throw Exception('Datei konnte nicht gelesen werden.');
    }

    final jsonString = utf8.decode(bytes);
    final jsonData = jsonDecode(jsonString);

    final List<Filament> loadedFilaments =
        (jsonData["filaments"] as List)
            .map((e) => Filament.fromJson(e))
            .toList();

    final List<PrintJob> loadedJobs =
        (jsonData["jobs"] as List)
            .map((e) => PrintJob.fromJson(e))
            .toList();

    appState.filaments
      ..clear()
      ..addAll(loadedFilaments);

    appState.jobs
      ..clear()
      ..addAll(loadedJobs);

    appState.saveData();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Backup erfolgreich geladen"),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fehler beim Laden des Backups"),
      ),
    );
  }
}

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

        children: [
          PageHeader(title: l10n.settings),

          const SizedBox(height: 24),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: l10n.design,
              icon: Icons.palette_outlined,
              child: Column(
                children: [

                  RadioListTile<ThemeMode>.adaptive(
                    title: Text(l10n.dark),
                    value: ThemeMode.dark,
                    groupValue: appState.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setThemeMode(value);
                      }
                    },
                  ),

                  RadioListTile<ThemeMode>(
                    title: Text(l10n.system),
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
              title: AppLocalizations.of(context)!.language,
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
                        Text(AppLocalizations.of(context)!.german)
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
                        Text(AppLocalizations.of(context)!.english)
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
              title: AppLocalizations.of(context)!.warningFilament,
              icon: Icons.warning_amber_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.warningBelow(
  appState.warningPercent.toStringAsFixed(0),
),
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
              title: AppLocalizations.of(context)!.backup,
              icon: Icons.backup_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(AppLocalizations.of(context)!.backupExport),
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
                    label: Text(AppLocalizations.of(context)!.backupImport),
                    onPressed: () {
                      _importBackup(context, appState);
                    },
                  ),

                  const SizedBox(height: 12),

                  Text(
  AppLocalizations.of(context)!.backupDescription,
  style: const TextStyle(
    color: Colors.grey,
    fontSize: 12,
  ),
),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: AppLocalizations.of(context)!.support,
              icon: Icons.support_agent,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: Text(AppLocalizations.of(context)!.sendFeedback),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final subject = Uri.encodeComponent(
                        'Feedback FilaLog',
                      );

                      final body = Uri.encodeComponent(
  '${AppLocalizations.of(context)!.feedbackMailGreeting}'
  '${AppLocalizations.of(context)!.feedbackMailDescription}'
  '----------------------------------------\n\n',
);

                      _openUrl(
                        'mailto:${AppLinks.supportMail}?subject=$subject&body=$body',
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text(AppLocalizations.of(context)!.reportError),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
  final subject = Uri.encodeComponent(
  AppLocalizations.of(context)!.errorReportSubject,
);

                      final body = Uri.encodeComponent(
  '${AppLocalizations.of(context)!.errorReportMailGreeting}'
  '${AppLocalizations.of(context)!.errorReportMailDescription}'
  '${AppLocalizations.of(context)!.appVersionLabel}\n\n'
  '${AppLocalizations.of(context)!.deviceLabel}\n\n'
  '${AppLocalizations.of(context)!.browserLabel}\n\n'
  '${AppLocalizations.of(context)!.descriptionLabel}\n\n'
  '${AppLocalizations.of(context)!.stepsToReproduceLabel}\n\n'
  '----------------------------------------\n',
);

                      _openUrl(
                        'mailto:${AppLinks.supportMail}?subject=$subject&body=$body',
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: Text(AppLocalizations.of(context)!.rateApp),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(AppLocalizations.of(context)!.contact),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final subject = Uri.encodeComponent(
  AppLocalizations.of(context)!.contactSubject,
);

                      final body = Uri.encodeComponent(
  '${AppLocalizations.of(context)!.supportMailGreeting}'
  '${AppLocalizations.of(context)!.supportMailDescription}'
  '----------------------------------------\n\n'
  '${AppLocalizations.of(context)!.descriptionLabel}\n\n'
  '----------------------------------------\n\n'
  '${AppLocalizations.of(context)!.thankYouMail}',
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
              title: AppLocalizations.of(context)!.help,
              icon: Icons.help_outline,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(AppLocalizations.of(context)!.firstSteps),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpFirstStepsPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(AppLocalizations.of(context)!.addFilament),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpAddFilamentPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.print_outlined),
                    title: Text(AppLocalizations.of(context)!.createPrintJob),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpPrintJobPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: Text(AppLocalizations.of(context)!.understandStatistics),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpStatisticsPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: Text(AppLocalizations.of(context)!.backupAndRestore),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpBackupPage(),
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
              title: AppLocalizations.of(context)!.whatsNew,
              icon: Icons.new_releases_outlined,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: Text(AppLocalizations.of(context)!.version10),
                    subtitle: Text(AppLocalizations.of(context)!.firstOfficialRelease),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.update_outlined),
                    title: Text(AppLocalizations.of(context)!.versionHistory),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WhatsNewPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          AppHoverCard(
            child: ExpandableSettingsCard(
              title: AppLocalizations.of(context)!.legal,
              icon: Icons.gavel_outlined,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(AppLocalizations.of(context)!.privacyPolicy),
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
                    title: Text(AppLocalizations.of(context)!.imprint),
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
                    title: Text(AppLocalizations.of(context)!.termsOfService),
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

                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(AppLocalizations.of(context)!.premiumSubscription),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PremiumPage()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.assignment_return_outlined),
                    title: Text(AppLocalizations.of(context)!.withdrawal),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WithdrawalPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.consumerInformation),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConsumerInformationPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.gpp_good_outlined),
                    title: Text(AppLocalizations.of(context)!.liability),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LiabilityPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.copyright_outlined),
                    title: Text(AppLocalizations.of(context)!.copyright),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CopyrightPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: Text(AppLocalizations.of(context)!.imageCredits),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImageCreditsPage(),
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
              title: l10n.account,
              icon: Icons.person_outline,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: Text(l10n.signIn),
subtitle: Text(l10n.signInSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
  );
},
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1),
                    title: Text(l10n.createAccount),
subtitle: Text(l10n.createAccountSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const RegisterPage(),
    ),
  );
},
                  ),

                  const Divider(),

                  ListTile(
  leading: const Icon(Icons.logout),
  title: Text(l10n.signOut),
subtitle: Text(l10n.signOutSubtitle),
  trailing: const Icon(Icons.chevron_right),
  onTap: () async {
  try {
    await GuestService.disableGuestMode();

    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
  l10n.signOutFailed(e.toString()),
),
      ),
    );
  }
},
),
                ],
              ),
            ),
          ),

          AppHoverCard(
  child: ExpandableSettingsCard(
    title: l10n.about,
    icon: Icons.info_outline,
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.apps),
          title: const Text("FilaLog"),
          subtitle: Text(l10n.version("1.0.0")),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(l10n.developer),
          subtitle: const Text("Robin P."),
        ),

        ListTile(
          leading: const Icon(Icons.memory_outlined),
          title: Text(l10n.technology),
          subtitle: const Text("Flutter • Firebase"),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.website),
          subtitle: const Text("filalog.de"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _openUrl(AppLinks.website);
          },
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.favorite_outline),
          title: Text(l10n.thankYou),
          subtitle: Text(
            l10n.thankYouMessage
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.openSourceLicenses),
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



