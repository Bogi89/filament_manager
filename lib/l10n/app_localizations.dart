import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @filament.
  ///
  /// In en, this message translates to:
  /// **'Filament'**
  String get filament;

  /// No description provided for @filaments.
  ///
  /// In en, this message translates to:
  /// **'Filaments'**
  String get filaments;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get cost;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @criticalFilaments.
  ///
  /// In en, this message translates to:
  /// **'{count} critical filament(s)'**
  String criticalFilaments(int count);

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @warningFilament.
  ///
  /// In en, this message translates to:
  /// **'Filament Warning'**
  String get warningFilament;

  /// No description provided for @warningBelow.
  ///
  /// In en, this message translates to:
  /// **'Warning below {percent}%'**
  String warningBelow(String percent);

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get backupImport;

  /// No description provided for @backupSaveDialog.
  ///
  /// In en, this message translates to:
  /// **'Save Backup'**
  String get backupSaveDialog;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupCreated;

  /// No description provided for @backupLoaded.
  ///
  /// In en, this message translates to:
  /// **'Backup loaded successfully'**
  String get backupLoaded;

  /// No description provided for @backupLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading backup'**
  String get backupLoadError;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Exports and imports filaments and print jobs.'**
  String get backupDescription;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @errorReportSubject.
  ///
  /// In en, this message translates to:
  /// **'Error Report FilaLog'**
  String get errorReportSubject;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get reportError;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactSubject.
  ///
  /// In en, this message translates to:
  /// **'Support FilaLog'**
  String get contactSubject;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @firstSteps.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get firstSteps;

  /// No description provided for @addFilament.
  ///
  /// In en, this message translates to:
  /// **'Add Filament'**
  String get addFilament;

  /// No description provided for @createPrintJob.
  ///
  /// In en, this message translates to:
  /// **'Create Print Job'**
  String get createPrintJob;

  /// No description provided for @understandStatistics.
  ///
  /// In en, this message translates to:
  /// **'Understanding Statistics'**
  String get understandStatistics;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @helpFirstStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get helpFirstStepsTitle;

  /// No description provided for @helpFirstStepsIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FilaLog. This guide will help you get started and explains the most important features of the app.'**
  String get helpFirstStepsIntroduction;

  /// No description provided for @helpFirstStepsFilamentTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Add Filament'**
  String get helpFirstStepsFilamentTitle;

  /// No description provided for @helpFirstStepsFilamentContent.
  ///
  /// In en, this message translates to:
  /// **'First, add your first filament. All other features are based on your filament inventory.'**
  String get helpFirstStepsFilamentContent;

  /// No description provided for @helpFirstStepsPrintTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Create a Print Job'**
  String get helpFirstStepsPrintTitle;

  /// No description provided for @helpFirstStepsPrintContent.
  ///
  /// In en, this message translates to:
  /// **'Next, create a print job. Filament consumption is calculated automatically and deducted from your inventory.'**
  String get helpFirstStepsPrintContent;

  /// No description provided for @helpFirstStepsStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Use Statistics'**
  String get helpFirstStepsStatisticsTitle;

  /// No description provided for @helpFirstStepsStatisticsContent.
  ///
  /// In en, this message translates to:
  /// **'The statistics section gives you an overview of your consumption, costs, and print history.'**
  String get helpFirstStepsStatisticsContent;

  /// No description provided for @helpFirstStepsBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Create a Backup'**
  String get helpFirstStepsBackupTitle;

  /// No description provided for @helpFirstStepsBackupContent.
  ///
  /// In en, this message translates to:
  /// **'Create regular backups of your data so that your filament inventory and print history are always protected.'**
  String get helpFirstStepsBackupContent;

  /// No description provided for @helpFirstStepsTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Start with a few filaments. This helps you get familiar with the app quickly and keeps everything easy to manage.'**
  String get helpFirstStepsTip;

  /// No description provided for @helpAddFilamentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Filament'**
  String get helpAddFilamentTitle;

  /// No description provided for @helpAddFilamentIntroduction.
  ///
  /// In en, this message translates to:
  /// **'This page explains how to correctly add a new filament and which information is required.'**
  String get helpAddFilamentIntroduction;

  /// No description provided for @helpAddFilamentNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a New Filament'**
  String get helpAddFilamentNewTitle;

  /// No description provided for @helpAddFilamentNewContent.
  ///
  /// In en, this message translates to:
  /// **'Open the filament section and tap the button to add a new filament.'**
  String get helpAddFilamentNewContent;

  /// No description provided for @helpAddFilamentSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Filament'**
  String get helpAddFilamentSelectTitle;

  /// No description provided for @helpAddFilamentSelectContent.
  ///
  /// In en, this message translates to:
  /// **'Select the manufacturer, material, variant, and color. Many values are automatically filled in from the filament catalog.'**
  String get helpAddFilamentSelectContent;

  /// No description provided for @helpAddFilamentSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Print Settings'**
  String get helpAddFilamentSettingsTitle;

  /// No description provided for @helpAddFilamentSettingsContent.
  ///
  /// In en, this message translates to:
  /// **'Check the diameter as well as nozzle and bed temperature. These values are automatically suggested based on the material.'**
  String get helpAddFilamentSettingsContent;

  /// No description provided for @helpAddFilamentStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock and Costs'**
  String get helpAddFilamentStockTitle;

  /// No description provided for @helpAddFilamentStockContent.
  ///
  /// In en, this message translates to:
  /// **'Set the spool weight, current stock, and purchase price. These details are later used for cost calculation and inventory management.'**
  String get helpAddFilamentStockContent;

  /// No description provided for @helpAddFilamentTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use the integrated filament catalog whenever possible. This automatically fills in many fields and helps prevent input errors.'**
  String get helpAddFilamentTip;

  /// No description provided for @helpPrintJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Print Job'**
  String get helpPrintJobTitle;

  /// No description provided for @helpPrintJobIntroduction.
  ///
  /// In en, this message translates to:
  /// **'A print job allows you to document your prints while filament consumption is calculated automatically.'**
  String get helpPrintJobIntroduction;

  /// No description provided for @helpPrintJobNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a New Print Job'**
  String get helpPrintJobNewTitle;

  /// No description provided for @helpPrintJobNewContent.
  ///
  /// In en, this message translates to:
  /// **'Open the \"History\" section and create a new print job.'**
  String get helpPrintJobNewContent;

  /// No description provided for @helpPrintJobFilamentTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Filament'**
  String get helpPrintJobFilamentTitle;

  /// No description provided for @helpPrintJobFilamentContent.
  ///
  /// In en, this message translates to:
  /// **'Select the filament used from your inventory. Only available filaments can be used.'**
  String get helpPrintJobFilamentContent;

  /// No description provided for @helpPrintJobUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Consumption'**
  String get helpPrintJobUsageTitle;

  /// No description provided for @helpPrintJobUsageContent.
  ///
  /// In en, this message translates to:
  /// **'Enter how many grams of filament were used. The inventory will then be updated automatically.'**
  String get helpPrintJobUsageContent;

  /// No description provided for @helpPrintJobInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Print Information'**
  String get helpPrintJobInfoTitle;

  /// No description provided for @helpPrintJobInfoContent.
  ///
  /// In en, this message translates to:
  /// **'Optionally, you can save the print duration, printer, notes, or other information to keep track of your prints later.'**
  String get helpPrintJobInfoContent;

  /// No description provided for @helpPrintJobTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Enter your print jobs as soon as possible after printing. This keeps your inventory and statistics up to date.'**
  String get helpPrintJobTip;

  /// No description provided for @helpStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding Statistics'**
  String get helpStatisticsTitle;

  /// No description provided for @helpStatisticsIntroduction.
  ///
  /// In en, this message translates to:
  /// **'The statistics show you an overview of your filament consumption, your print jobs, and the resulting costs.'**
  String get helpStatisticsIntroduction;

  /// No description provided for @helpStatisticsUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get helpStatisticsUsageTitle;

  /// No description provided for @helpStatisticsUsageContent.
  ///
  /// In en, this message translates to:
  /// **'Here you can see how much filament has been used in total and which materials are used most frequently.'**
  String get helpStatisticsUsageContent;

  /// No description provided for @helpStatisticsCostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get helpStatisticsCostsTitle;

  /// No description provided for @helpStatisticsCostsContent.
  ///
  /// In en, this message translates to:
  /// **'The cost overview calculates your material costs based on the stored filament price and actual consumption.'**
  String get helpStatisticsCostsContent;

  /// No description provided for @helpStatisticsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Print History'**
  String get helpStatisticsHistoryTitle;

  /// No description provided for @helpStatisticsHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'All completed print jobs are automatically included in your statistics.'**
  String get helpStatisticsHistoryContent;

  /// No description provided for @helpStatisticsAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get helpStatisticsAnalysisTitle;

  /// No description provided for @helpStatisticsAnalysisContent.
  ///
  /// In en, this message translates to:
  /// **'Use the charts and overviews to analyze consumption, costs, and material usage over time.'**
  String get helpStatisticsAnalysisContent;

  /// No description provided for @helpStatisticsTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: The more complete your print jobs are, the more accurate your statistics will be.'**
  String get helpStatisticsTip;

  /// No description provided for @helpBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get helpBackupTitle;

  /// No description provided for @helpBackupIntroduction.
  ///
  /// In en, this message translates to:
  /// **'With a backup, you can save your filaments, print jobs, and settings and restore them later.'**
  String get helpBackupIntroduction;

  /// No description provided for @helpBackupCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Backup'**
  String get helpBackupCreateTitle;

  /// No description provided for @helpBackupCreateContent.
  ///
  /// In en, this message translates to:
  /// **'Create regular backups of your data to prevent any information from being lost.'**
  String get helpBackupCreateContent;

  /// No description provided for @helpBackupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore a Backup'**
  String get helpBackupRestoreTitle;

  /// No description provided for @helpBackupRestoreContent.
  ///
  /// In en, this message translates to:
  /// **'Select a previously created backup file to import your data back into FilaLog.'**
  String get helpBackupRestoreContent;

  /// No description provided for @helpBackupFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup File'**
  String get helpBackupFileTitle;

  /// No description provided for @helpBackupFileContent.
  ///
  /// In en, this message translates to:
  /// **'Keep your backup files in a safe place, such as a cloud service or an external storage device.'**
  String get helpBackupFileContent;

  /// No description provided for @helpBackupRegularTitle.
  ///
  /// In en, this message translates to:
  /// **'Back Up Regularly'**
  String get helpBackupRegularTitle;

  /// No description provided for @helpBackupRegularContent.
  ///
  /// In en, this message translates to:
  /// **'Create an up-to-date backup especially before making major changes or updating the app.'**
  String get helpBackupRegularContent;

  /// No description provided for @helpBackupTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: With regular backups, you can restore your data at any time without any problems.'**
  String get helpBackupTip;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get whatsNew;

  /// No description provided for @version10.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get version10;

  /// No description provided for @firstOfficialRelease.
  ///
  /// In en, this message translates to:
  /// **'First Official Release'**
  String get firstOfficialRelease;

  /// No description provided for @versionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version History'**
  String get versionHistory;

  /// No description provided for @whatsNewIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Here you can find the new features and improvements introduced in each version of FilaLog.'**
  String get whatsNewIntroduction;

  /// No description provided for @whatsNewVersion100.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get whatsNewVersion100;

  /// No description provided for @whatsNewVersion100Content.
  ///
  /// In en, this message translates to:
  /// **'• First official release\n• Filament management\n• Print history\n• Cost calculation\n• Statistics\n• Backup & Restore\n• User account\n• Guest mode\n• Help section\n• Legal information'**
  String get whatsNewVersion100Content;

  /// No description provided for @whatsNewTip.
  ///
  /// In en, this message translates to:
  /// **'New features will be added here after each update, so you can always keep track of all changes.'**
  String get whatsNewTip;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get legalLastUpdated;

  /// No description provided for @legalLastUpdatedValue.
  ///
  /// In en, this message translates to:
  /// **'August 2026'**
  String get legalLastUpdatedValue;

  /// No description provided for @legalAllRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved.'**
  String get legalAllRightsReserved;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyUpdated.
  ///
  /// In en, this message translates to:
  /// **'August 2026'**
  String get privacyPolicyUpdated;

  /// No description provided for @privacyPolicyResponsible.
  ///
  /// In en, this message translates to:
  /// **'Data Controller'**
  String get privacyPolicyResponsible;

  /// No description provided for @privacyPolicyResponsibleLabel.
  ///
  /// In en, this message translates to:
  /// **'Responsible'**
  String get privacyPolicyResponsibleLabel;

  /// No description provided for @privacyPolicyResponsibleName.
  ///
  /// In en, this message translates to:
  /// **'Robin'**
  String get privacyPolicyResponsibleName;

  /// No description provided for @privacyPolicyContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyPolicyContact;

  /// No description provided for @privacyPolicyContactMissing.
  ///
  /// In en, this message translates to:
  /// **'Will be added before release'**
  String get privacyPolicyContactMissing;

  /// No description provided for @privacyPolicyStoredDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What data is stored?'**
  String get privacyPolicyStoredDataTitle;

  /// No description provided for @privacyPolicyLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Locally stored data'**
  String get privacyPolicyLocalDataTitle;

  /// No description provided for @privacyPolicyLocalDataContent.
  ///
  /// In en, this message translates to:
  /// **'Filaments, print jobs, settings, and statistics are stored locally on your device.'**
  String get privacyPolicyLocalDataContent;

  /// No description provided for @privacyPolicyNoSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'No data sharing'**
  String get privacyPolicyNoSharingTitle;

  /// No description provided for @privacyPolicyNoSharingContent.
  ///
  /// In en, this message translates to:
  /// **'No personal data is shared with third parties unless this is required for the use of the app.'**
  String get privacyPolicyNoSharingContent;

  /// No description provided for @privacyPolicyAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode & User Account'**
  String get privacyPolicyAccountTitle;

  /// No description provided for @privacyPolicyGuestModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get privacyPolicyGuestModeTitle;

  /// No description provided for @privacyPolicyGuestModeContent.
  ///
  /// In en, this message translates to:
  /// **'The app can be used in guest mode without registration. The data remains stored exclusively on the device.'**
  String get privacyPolicyGuestModeContent;

  /// No description provided for @privacyPolicyUserAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'User Account'**
  String get privacyPolicyUserAccountTitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get termsOfServiceScope;

  /// No description provided for @termsOfServiceAppUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Use of the App'**
  String get termsOfServiceAppUsageTitle;

  /// No description provided for @termsOfServiceAppUsageContent.
  ///
  /// In en, this message translates to:
  /// **'These Terms of Service apply to the use of FilaLog on all supported platforms.'**
  String get termsOfServiceAppUsageContent;

  /// No description provided for @termsOfServiceAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'Agreement'**
  String get termsOfServiceAgreementTitle;

  /// No description provided for @termsOfServiceAgreementContent.
  ///
  /// In en, this message translates to:
  /// **'By using the app, you agree to these Terms of Service.'**
  String get termsOfServiceAgreementContent;

  /// No description provided for @termsOfServiceUserObligations.
  ///
  /// In en, this message translates to:
  /// **'User Obligations'**
  String get termsOfServiceUserObligations;

  /// No description provided for @termsOfServiceResponsibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Responsibility'**
  String get termsOfServiceResponsibilityTitle;

  /// No description provided for @termsOfServiceResponsibilityContent.
  ///
  /// In en, this message translates to:
  /// **'The user is responsible for the data they enter into the app.'**
  String get termsOfServiceResponsibilityContent;

  /// No description provided for @termsOfServiceMisuseTitle.
  ///
  /// In en, this message translates to:
  /// **'Misuse'**
  String get termsOfServiceMisuseTitle;

  /// No description provided for @termsOfServiceMisuseContent.
  ///
  /// In en, this message translates to:
  /// **'The app must not be misused or used to carry out unlawful activities.'**
  String get termsOfServiceMisuseContent;

  /// No description provided for @termsOfServiceLicensesRights.
  ///
  /// In en, this message translates to:
  /// **'Licenses & Usage Rights'**
  String get termsOfServiceLicensesRights;

  /// No description provided for @termsOfServiceCopyrightTitle.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get termsOfServiceCopyrightTitle;

  /// No description provided for @termsOfServiceCopyrightContent.
  ///
  /// In en, this message translates to:
  /// **'All rights to the app, its design, and its content remain with the developer.'**
  String get termsOfServiceCopyrightContent;

  /// No description provided for @termsOfServiceNoDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'No Distribution'**
  String get termsOfServiceNoDistributionTitle;

  /// No description provided for @termsOfServiceNoDistributionContent.
  ///
  /// In en, this message translates to:
  /// **'The app may not be copied, modified, or redistributed without express permission, unless permitted by law.'**
  String get termsOfServiceNoDistributionContent;

  /// No description provided for @termsOfServiceChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get termsOfServiceChanges;

  /// No description provided for @termsOfServiceUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates to the Terms'**
  String get termsOfServiceUpdatesTitle;

  /// No description provided for @termsOfServiceUpdatesContent.
  ///
  /// In en, this message translates to:
  /// **'The Terms of Service may be updated when new features are introduced or when required by changes in applicable law.'**
  String get termsOfServiceUpdatesContent;

  /// No description provided for @termsOfServiceFinalProvisions.
  ///
  /// In en, this message translates to:
  /// **'Final Provisions'**
  String get termsOfServiceFinalProvisions;

  /// No description provided for @termsOfServiceApplicableLawTitle.
  ///
  /// In en, this message translates to:
  /// **'Applicable Law'**
  String get termsOfServiceApplicableLawTitle;

  /// No description provided for @termsOfServiceApplicableLawContent.
  ///
  /// In en, this message translates to:
  /// **'The applicable law at the provider\'s place of business shall apply, to the extent permitted by law.'**
  String get termsOfServiceApplicableLawContent;

  /// No description provided for @privacyPolicyUserAccountContent.
  ///
  /// In en, this message translates to:
  /// **'When using a user account, data may be synchronized with supported devices in the future.'**
  String get privacyPolicyUserAccountContent;

  /// No description provided for @privacyPolicyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyPolicyRightsTitle;

  /// No description provided for @privacyPolicyRightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Data Protection Rights'**
  String get privacyPolicyRightsLabel;

  /// No description provided for @privacyPolicyRightsContent.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, delete, and restrict the processing of your personal data within the scope of applicable data protection laws.'**
  String get privacyPolicyRightsContent;

  /// No description provided for @privacyPolicyQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions About Data Protection'**
  String get privacyPolicyQuestionsTitle;

  /// No description provided for @privacyPolicyQuestionsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyPolicyQuestionsContactTitle;

  /// No description provided for @privacyPolicyQuestionsContactContent.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about data protection, you can contact us using the contact details provided in the legal notice.'**
  String get privacyPolicyQuestionsContactContent;

  /// No description provided for @imprint.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get imprint;

  /// No description provided for @imprintProviderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider Information'**
  String get imprintProviderDetailsTitle;

  /// No description provided for @imprintAppNameLabel.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get imprintAppNameLabel;

  /// No description provided for @imprintAppNameValue.
  ///
  /// In en, this message translates to:
  /// **'FilaLog'**
  String get imprintAppNameValue;

  /// No description provided for @imprintDeveloperLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get imprintDeveloperLabel;

  /// No description provided for @imprintDeveloperValue.
  ///
  /// In en, this message translates to:
  /// **'Robin'**
  String get imprintDeveloperValue;

  /// No description provided for @imprintAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get imprintAddressLabel;

  /// No description provided for @imprintAddressValue.
  ///
  /// In en, this message translates to:
  /// **'Will be added before release'**
  String get imprintAddressValue;

  /// No description provided for @imprintContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get imprintContactTitle;

  /// No description provided for @imprintEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get imprintEmailLabel;

  /// No description provided for @imprintEmailValue.
  ///
  /// In en, this message translates to:
  /// **'support@deine-domain.de'**
  String get imprintEmailValue;

  /// No description provided for @imprintWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get imprintWebsiteLabel;

  /// No description provided for @imprintWebsiteValue.
  ///
  /// In en, this message translates to:
  /// **'https://deine-domain.de'**
  String get imprintWebsiteValue;

  /// No description provided for @imprintCompanyInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get imprintCompanyInformationTitle;

  /// No description provided for @imprintCompanyFormLabel.
  ///
  /// In en, this message translates to:
  /// **'Legal Form'**
  String get imprintCompanyFormLabel;

  /// No description provided for @imprintCompanyFormValue.
  ///
  /// In en, this message translates to:
  /// **'Will be added before release'**
  String get imprintCompanyFormValue;

  /// No description provided for @imprintBusinessPurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Business Purpose'**
  String get imprintBusinessPurposeLabel;

  /// No description provided for @imprintBusinessPurposeValue.
  ///
  /// In en, this message translates to:
  /// **'Provision of an application for managing 3D printing filament.'**
  String get imprintBusinessPurposeValue;

  /// No description provided for @imprintLegalNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get imprintLegalNotesTitle;

  /// No description provided for @imprintLiabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get imprintLiabilityLabel;

  /// No description provided for @imprintLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'For more information, please visit the \"Liability\" page.'**
  String get imprintLiabilityContent;

  /// No description provided for @imprintCopyrightLabel.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get imprintCopyrightLabel;

  /// No description provided for @imprintCopyrightContent.
  ///
  /// In en, this message translates to:
  /// **'For more information, please visit the \"Copyright\" page.'**
  String get imprintCopyrightContent;

  /// No description provided for @premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium & Subscription'**
  String get premiumSubscription;

  /// No description provided for @premiumMembershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get premiumMembershipTitle;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumContent.
  ///
  /// In en, this message translates to:
  /// **'FilaLog can be tested free of charge for seven days. After that, a Premium membership is required to continue using the app.'**
  String get premiumContent;

  /// No description provided for @premiumTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial Period'**
  String get premiumTrialTitle;

  /// No description provided for @premiumTrialContent.
  ///
  /// In en, this message translates to:
  /// **'All features are available without restrictions during the seven-day trial period.'**
  String get premiumTrialContent;

  /// No description provided for @premiumBillingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get premiumBillingTitle;

  /// No description provided for @premiumPaymentProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Processing'**
  String get premiumPaymentProcessingTitle;

  /// No description provided for @premiumPaymentProcessingContent.
  ///
  /// In en, this message translates to:
  /// **'On Android, payments are processed through Google Play. For the web version, payments are processed through the official website using PayPal.'**
  String get premiumPaymentProcessingContent;

  /// No description provided for @premiumPlatformsTitle.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get premiumPlatformsTitle;

  /// No description provided for @premiumPlatformsContent.
  ///
  /// In en, this message translates to:
  /// **'On Android, the Premium membership is purchased through Google Play. For the web version, Premium can be purchased through the official website using PayPal.'**
  String get premiumPlatformsContent;

  /// No description provided for @premiumTrialAndPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial Period & Premium'**
  String get premiumTrialAndPremiumTitle;

  /// No description provided for @premiumSevenDayTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Trial'**
  String get premiumSevenDayTrialTitle;

  /// No description provided for @premiumSevenDayTrialContent.
  ///
  /// In en, this message translates to:
  /// **'New users can test FilaLog free of charge for seven days.'**
  String get premiumSevenDayTrialContent;

  /// No description provided for @premiumAfterTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'After the Trial'**
  String get premiumAfterTrialTitle;

  /// No description provided for @premiumAfterTrialContent.
  ///
  /// In en, this message translates to:
  /// **'After the trial period ends, a Premium membership is required to continue using FilaLog.'**
  String get premiumAfterTrialContent;

  /// No description provided for @premiumMembershipTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get premiumMembershipTermsTitle;

  /// No description provided for @premiumDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Periods'**
  String get premiumDurationTitle;

  /// No description provided for @premiumDurationContent.
  ///
  /// In en, this message translates to:
  /// **'Premium is offered as a monthly or annual membership.'**
  String get premiumDurationContent;

  /// No description provided for @premiumCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get premiumCancellationTitle;

  /// No description provided for @premiumCancellationContent.
  ///
  /// In en, this message translates to:
  /// **'The membership can be cancelled at any time effective at the end of the current subscription period.'**
  String get premiumCancellationContent;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Right of Withdrawal'**
  String get withdrawal;

  /// No description provided for @withdrawalRightTitle.
  ///
  /// In en, this message translates to:
  /// **'Right of Withdrawal'**
  String get withdrawalRightTitle;

  /// No description provided for @withdrawalPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period'**
  String get withdrawalPeriodTitle;

  /// No description provided for @withdrawalPeriodContent.
  ///
  /// In en, this message translates to:
  /// **'Consumers generally have the right to withdraw from a contract within fourteen days.'**
  String get withdrawalPeriodContent;

  /// No description provided for @withdrawalReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'No Reason Required'**
  String get withdrawalReasonTitle;

  /// No description provided for @withdrawalReasonContent.
  ///
  /// In en, this message translates to:
  /// **'The right of withdrawal may be exercised within the statutory withdrawal period without stating any reason.'**
  String get withdrawalReasonContent;

  /// No description provided for @withdrawalExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercising the Right of Withdrawal'**
  String get withdrawalExerciseTitle;

  /// No description provided for @withdrawalDeclarationTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Declaration'**
  String get withdrawalDeclarationTitle;

  /// No description provided for @withdrawalDeclarationContent.
  ///
  /// In en, this message translates to:
  /// **'To exercise the right of withdrawal, a clear declaration expressing the decision to withdraw from the contract is required.'**
  String get withdrawalDeclarationContent;

  /// No description provided for @withdrawalDeadlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting the Deadline'**
  String get withdrawalDeadlineTitle;

  /// No description provided for @withdrawalDeadlineContent.
  ///
  /// In en, this message translates to:
  /// **'To meet the withdrawal deadline, it is sufficient to send the declaration before the withdrawal period expires.'**
  String get withdrawalDeadlineContent;

  /// No description provided for @withdrawalPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium & Digital Services'**
  String get withdrawalPremiumTitle;

  /// No description provided for @withdrawalDigitalServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Service'**
  String get withdrawalDigitalServiceTitle;

  /// No description provided for @withdrawalDigitalServiceContent.
  ///
  /// In en, this message translates to:
  /// **'The Premium membership provides access to additional digital features and services offered by FilaLog.'**
  String get withdrawalDigitalServiceContent;

  /// No description provided for @withdrawalEarlyExpiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Start of the Service'**
  String get withdrawalEarlyExpiryTitle;

  /// No description provided for @withdrawalEarlyExpiryContent.
  ///
  /// In en, this message translates to:
  /// **'An early start of the provision of digital services or a possible loss of the right of withdrawal is subject to the applicable legal requirements and the information provided when the contract is concluded.'**
  String get withdrawalEarlyExpiryContent;

  /// No description provided for @withdrawalInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Further Information'**
  String get withdrawalInformationTitle;

  /// No description provided for @withdrawalPurchaseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information at Checkout'**
  String get withdrawalPurchaseInfoTitle;

  /// No description provided for @withdrawalPurchaseInfoContent.
  ///
  /// In en, this message translates to:
  /// **'Before completing a Premium membership, the legally required information regarding the right of withdrawal and the processing of the contract is provided for the respective purchase.'**
  String get withdrawalPurchaseInfoContent;

  /// No description provided for @consumerInformation.
  ///
  /// In en, this message translates to:
  /// **'Consumer Information'**
  String get consumerInformation;

  /// No description provided for @consumerProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get consumerProviderTitle;

  /// No description provided for @consumerResponsibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Responsible Party'**
  String get consumerResponsibleTitle;

  /// No description provided for @consumerResponsibleContent.
  ///
  /// In en, this message translates to:
  /// **'Information about the provider can be found in the legal notice.'**
  String get consumerResponsibleContent;

  /// No description provided for @consumerContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get consumerContactTitle;

  /// No description provided for @consumerContactContent.
  ///
  /// In en, this message translates to:
  /// **'Questions can be submitted at any time using the contact details provided in the legal notice.'**
  String get consumerContactContent;

  /// No description provided for @consumerContractTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Information'**
  String get consumerContractTitle;

  /// No description provided for @consumerPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get consumerPremiumTitle;

  /// No description provided for @consumerPremiumContent.
  ///
  /// In en, this message translates to:
  /// **'Before completing a Premium membership, all essential information regarding the price, duration and payment method is provided.'**
  String get consumerPremiumContent;

  /// No description provided for @consumerContractConclusionTitle.
  ///
  /// In en, this message translates to:
  /// **'Conclusion of Contract'**
  String get consumerContractConclusionTitle;

  /// No description provided for @consumerContractConclusionContent.
  ///
  /// In en, this message translates to:
  /// **'The contract is concluded only after the respective purchase process has been successfully completed.'**
  String get consumerContractConclusionContent;

  /// No description provided for @consumerSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get consumerSupportTitle;

  /// No description provided for @consumerHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get consumerHelpTitle;

  /// No description provided for @consumerHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or problems, support is available through the official contact options.'**
  String get consumerHelpContent;

  /// No description provided for @liability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get liability;

  /// No description provided for @liabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get liabilityTitle;

  /// No description provided for @liabilityContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Liability for Content'**
  String get liabilityContentTitle;

  /// No description provided for @liabilityCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Due Care'**
  String get liabilityCareTitle;

  /// No description provided for @liabilityCareContent.
  ///
  /// In en, this message translates to:
  /// **'The content provided by FilaLog is created with due care and reviewed regularly.'**
  String get liabilityCareContent;

  /// No description provided for @liabilityNoWarrantyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Warranty'**
  String get liabilityNoWarrantyTitle;

  /// No description provided for @liabilityNoWarrantyContent.
  ///
  /// In en, this message translates to:
  /// **'Despite careful preparation, no guarantee can be given regarding the accuracy, completeness or timeliness of all information provided.'**
  String get liabilityNoWarrantyContent;

  /// No description provided for @liabilityExternalContentTitle.
  ///
  /// In en, this message translates to:
  /// **'External Content'**
  String get liabilityExternalContentTitle;

  /// No description provided for @liabilityExternalLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Links and External Services'**
  String get liabilityExternalLinksTitle;

  /// No description provided for @liabilityExternalLinksContent.
  ///
  /// In en, this message translates to:
  /// **'The respective operators are responsible for the content of external websites or services referenced within FilaLog.'**
  String get liabilityExternalLinksContent;

  /// No description provided for @liabilityUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice on Use'**
  String get liabilityUsageTitle;

  /// No description provided for @liabilityGeneralInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get liabilityGeneralInformationTitle;

  /// No description provided for @liabilityGeneralInformationContent.
  ///
  /// In en, this message translates to:
  /// **'The information provided in FilaLog is intended to support the management and organization of filament and 3D printing-related data.'**
  String get liabilityGeneralInformationContent;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// No description provided for @copyrightRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyrightRightsTitle;

  /// No description provided for @copyrightAppTitle.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get copyrightAppTitle;

  /// No description provided for @copyrightAppContent.
  ///
  /// In en, this message translates to:
  /// **'FilaLog and all associated content, designs and source code are protected by copyright.'**
  String get copyrightAppContent;

  /// No description provided for @copyrightUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get copyrightUsageTitle;

  /// No description provided for @copyrightUsageContent.
  ///
  /// In en, this message translates to:
  /// **'Reproduction, publication or distribution is not permitted without express permission.'**
  String get copyrightUsageContent;

  /// No description provided for @copyrightGraphicsContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Graphics & Content'**
  String get copyrightGraphicsContentTitle;

  /// No description provided for @copyrightOwnContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Original Content'**
  String get copyrightOwnContentTitle;

  /// No description provided for @copyrightOwnContentContent.
  ///
  /// In en, this message translates to:
  /// **'Original graphics, texts and logos are protected by the developer\'s copyright.'**
  String get copyrightOwnContentContent;

  /// No description provided for @copyrightThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Content'**
  String get copyrightThirdPartyTitle;

  /// No description provided for @copyrightThirdPartyContent.
  ///
  /// In en, this message translates to:
  /// **'Third-party content is used in accordance with the respective applicable licenses.'**
  String get copyrightThirdPartyContent;

  /// No description provided for @copyrightLicenseNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'License Notice'**
  String get copyrightLicenseNoticeTitle;

  /// No description provided for @copyrightOpenSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get copyrightOpenSourceTitle;

  /// No description provided for @copyrightOpenSourceContent.
  ///
  /// In en, this message translates to:
  /// **'Open-source components are used in accordance with their respective licenses.'**
  String get copyrightOpenSourceContent;

  /// No description provided for @imageCredits.
  ///
  /// In en, this message translates to:
  /// **'Image Credits'**
  String get imageCredits;

  /// No description provided for @imageCreditsGraphicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Graphics Used'**
  String get imageCreditsGraphicsTitle;

  /// No description provided for @imageCreditsOwnGraphicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Original Graphics'**
  String get imageCreditsOwnGraphicsTitle;

  /// No description provided for @imageCreditsOwnGraphicsContent.
  ///
  /// In en, this message translates to:
  /// **'All self-created graphics, logos and illustrations are protected by the developer\'s copyright.'**
  String get imageCreditsOwnGraphicsContent;

  /// No description provided for @imageCreditsAppIconsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Icons'**
  String get imageCreditsAppIconsTitle;

  /// No description provided for @imageCreditsAppIconsContent.
  ///
  /// In en, this message translates to:
  /// **'The icons used are from the official Flutter Material Icons.'**
  String get imageCreditsAppIconsContent;

  /// No description provided for @imageCreditsColorsDesignTitle.
  ///
  /// In en, this message translates to:
  /// **'Colors & Design'**
  String get imageCreditsColorsDesignTitle;

  /// No description provided for @imageCreditsInterfaceTitle.
  ///
  /// In en, this message translates to:
  /// **'User Interface'**
  String get imageCreditsInterfaceTitle;

  /// No description provided for @imageCreditsInterfaceContent.
  ///
  /// In en, this message translates to:
  /// **'The design of FilaLog was independently developed.'**
  String get imageCreditsInterfaceContent;

  /// No description provided for @imageCreditsBrandsTitle.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get imageCreditsBrandsTitle;

  /// No description provided for @imageCreditsBrandsContent.
  ///
  /// In en, this message translates to:
  /// **'Brand names and manufacturer designations remain the property of their respective owners.'**
  String get imageCreditsBrandsContent;

  /// No description provided for @imageCreditsNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get imageCreditsNoticeTitle;

  /// No description provided for @imageCreditsUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get imageCreditsUpdateTitle;

  /// No description provided for @imageCreditsUpdateContent.
  ///
  /// In en, this message translates to:
  /// **'If additional images or external graphics are used in the future, the corresponding image credits will be added here.'**
  String get imageCreditsUpdateContent;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get signInFailed;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an existing account.'**
  String get signInSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your user account.'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. We will send you a link to reset your password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendingResetLink.
  ///
  /// In en, this message translates to:
  /// **'Sending link...'**
  String get sendingResetLink;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendResetLink;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new user account.'**
  String get createAccountSubtitle;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerAppBarTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'New User Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your personal user account.'**
  String get registerSubtitle;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get registrationFailed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get weakPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get invalidEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the current account.'**
  String get signOutSubtitle;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {error}'**
  String signOutFailed(String error);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FilaLog'**
  String get appName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

  /// No description provided for @thankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using FilaLog.'**
  String get thankYouMessage;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @feedbackMailGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\n'**
  String get feedbackMailGreeting;

  /// No description provided for @feedbackMailDescription.
  ///
  /// In en, this message translates to:
  /// **'I have the following feedback or suggestion for improvement:\n\n'**
  String get feedbackMailDescription;

  /// No description provided for @errorReportMailGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\n'**
  String get errorReportMailGreeting;

  /// No description provided for @errorReportMailDescription.
  ///
  /// In en, this message translates to:
  /// **'I found the following error.\n\n'**
  String get errorReportMailDescription;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'App Version:'**
  String get appVersionLabel;

  /// No description provided for @deviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Device:'**
  String get deviceLabel;

  /// No description provided for @browserLabel.
  ///
  /// In en, this message translates to:
  /// **'Browser (Web):'**
  String get browserLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionLabel;

  /// No description provided for @stepsToReproduceLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps to Reproduce:'**
  String get stepsToReproduceLabel;

  /// No description provided for @supportMailGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\n'**
  String get supportMailGreeting;

  /// No description provided for @supportMailDescription.
  ///
  /// In en, this message translates to:
  /// **'I need help with the following topic.\n\n'**
  String get supportMailDescription;

  /// No description provided for @thankYouMail.
  ///
  /// In en, this message translates to:
  /// **'Thank you.'**
  String get thankYouMail;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @totalInventory.
  ///
  /// In en, this message translates to:
  /// **'Total Inventory'**
  String get totalInventory;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @printJobs.
  ///
  /// In en, this message translates to:
  /// **'Print Jobs'**
  String get printJobs;

  /// No description provided for @printed.
  ///
  /// In en, this message translates to:
  /// **'Printed'**
  String get printed;

  /// No description provided for @totalPrintCosts.
  ///
  /// In en, this message translates to:
  /// **'Total Print Costs'**
  String get totalPrintCosts;

  /// No description provided for @averageCostPerPrint.
  ///
  /// In en, this message translates to:
  /// **'Avg. Cost per Print'**
  String get averageCostPerPrint;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @calculatePrint.
  ///
  /// In en, this message translates to:
  /// **'Calculate Print'**
  String get calculatePrint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
