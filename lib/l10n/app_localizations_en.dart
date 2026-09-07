// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get filament => 'Filament';

  @override
  String get filaments => 'Filaments';

  @override
  String get cost => 'Costs';

  @override
  String get history => 'History';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get design => 'Design';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get critical => 'Critical';

  @override
  String criticalFilaments(int count) {
    return '$count critical filament(s)';
  }

  @override
  String get filter => 'Filter';

  @override
  String get close => 'Close';

  @override
  String get searchFilament => 'Search filament...';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get material => 'Material';

  @override
  String get editFilament => 'Edit filament';

  @override
  String get variant => 'Variant';

  @override
  String get color => 'Color';

  @override
  String get diameter => 'Diameter';

  @override
  String get price => 'Price';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorWhite => 'White';

  @override
  String get colorGray => 'Gray';

  @override
  String get colorRed => 'Red';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorTurquoise => 'Turquoise';

  @override
  String get colorGold => 'Gold';

  @override
  String get colorSilver => 'Silver';

  @override
  String get colorBronze => 'Bronze';

  @override
  String get colorCopper => 'Copper';

  @override
  String get colorBeige => 'Beige';

  @override
  String get colorCream => 'Cream';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorAnthracite => 'Anthracite';

  @override
  String get colorGraphite => 'Graphite';

  @override
  String get colorKhaki => 'Khaki';

  @override
  String get colorOlive => 'Olive';

  @override
  String get colorLime => 'Lime';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorBurgundy => 'Burgundy';

  @override
  String get colorTerracotta => 'Terracotta';

  @override
  String get colorPeach => 'Peach';

  @override
  String get colorApricot => 'Apricot';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorClear => 'Clear';

  @override
  String get colorTransparent => 'Transparent';

  @override
  String get colorNatural => 'Natural';

  @override
  String get colorDarkBlue => 'Dark Blue';

  @override
  String get colorLightBlue => 'Light Blue';

  @override
  String get colorDarkGreen => 'Dark Green';

  @override
  String get colorLightGreen => 'Light Green';

  @override
  String get colorDarkRed => 'Dark Red';

  @override
  String get colorLightRed => 'Light Red';

  @override
  String get colorDarkGray => 'Dark Gray';

  @override
  String get colorLightGray => 'Light Gray';

  @override
  String get colorDarkBrown => 'Dark Brown';

  @override
  String get colorLightBrown => 'Light Brown';

  @override
  String get colorDarkOrange => 'Dark Orange';

  @override
  String get colorLightOrange => 'Light Orange';

  @override
  String get remainingWeight => 'Remaining weight';

  @override
  String get editRemainingWeight => 'Edit remaining weight';

  @override
  String get remainingWeightGrams => 'Remaining weight (g)';

  @override
  String get spools => 'Spools';

  @override
  String get spool => 'Spool';

  @override
  String get editSpool => 'Edit spool';

  @override
  String get weight => 'Weight';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteLastSpool => 'Delete last spool';

  @override
  String get deleteSpool => 'Delete spool';

  @override
  String get delete => 'Delete';

  @override
  String get newSpool => 'New spool';

  @override
  String get addSpool => 'Add spool';

  @override
  String get selectMaterial => 'Select material';

  @override
  String get nozzle => 'Nozzle';

  @override
  String get bed => 'Bed';

  @override
  String spoolNumber(int number) {
    return 'Spool $number';
  }

  @override
  String remainingWeightOfTotal(int remainingWeight, int totalWeight) {
    return '$remainingWeight g of $totalWeight g';
  }

  @override
  String get deleteAndRemoveFilament => 'Delete & remove filament';

  @override
  String get deleteFilamentTitle => 'Delete filament?';

  @override
  String get deleteFilamentConfirmation => 'Do you really want to delete this filament?';

  @override
  String get deleteLastSpoolWarning => 'This filament will no longer contain any spools.\n\nDelete filament completely?';

  @override
  String deleteSpoolConfirmation(int number) {
    return 'Really delete spool $number?';
  }

  @override
  String get sort => 'Sort';

  @override
  String get sortByMaterial => 'By material';

  @override
  String get sortByRemainingWeight => 'By remaining weight';

  @override
  String get sortByName => 'By name';

  @override
  String get reset => 'Reset';

  @override
  String get warningFilament => 'Filament Monitoring';

  @override
  String warningBelow(String percent) {
    return 'Warning below $percent%';
  }

  @override
  String get backup => 'Backup';

  @override
  String get backupExport => 'Export Backup';

  @override
  String get backupImport => 'Import Backup';

  @override
  String get backupSaveDialog => 'Save Backup';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get backupLoaded => 'Backup loaded successfully';

  @override
  String get backupLoadError => 'Error loading backup';

  @override
  String get backupDescription => 'Exports and imports filaments and print jobs.';

  @override
  String get support => 'Support';

  @override
  String get errorReportSubject => 'Error Report FilaLog';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get reportError => 'Report an error';

  @override
  String get rateApp => 'Rate App';

  @override
  String get contact => 'Contact';

  @override
  String get contactSubject => 'Support FilaLog';

  @override
  String get help => 'Help';

  @override
  String get firstSteps => 'Getting Started';

  @override
  String get addFilament => 'Add Filament';

  @override
  String get createPrintJob => 'Create Print Job';

  @override
  String get understandStatistics => 'Understanding Statistics';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get helpFirstStepsTitle => 'Getting Started';

  @override
  String get helpFirstStepsIntroduction => 'Welcome to FilaLog. This guide will help you get started and explains the most important features of the app.';

  @override
  String get helpFirstStepsFilamentTitle => '1. Add Filament';

  @override
  String get helpFirstStepsFilamentContent => 'First, add your first filament. All other features are based on your filament inventory.';

  @override
  String get helpFirstStepsPrintTitle => '2. Create a Print Job';

  @override
  String get helpFirstStepsPrintContent => 'Next, create a print job. Filament consumption is calculated automatically and deducted from your inventory.';

  @override
  String get helpFirstStepsStatisticsTitle => '3. Use Statistics';

  @override
  String get helpFirstStepsStatisticsContent => 'The statistics section gives you an overview of your consumption, costs, and print history.';

  @override
  String get helpFirstStepsBackupTitle => '4. Create a Backup';

  @override
  String get helpFirstStepsBackupContent => 'Create regular backups of your data so that your filament inventory and print history are always protected.';

  @override
  String get helpFirstStepsTip => 'Tip: Start with a few filaments. This helps you get familiar with the app quickly and keeps everything easy to manage.';

  @override
  String get helpAddFilamentTitle => 'Add Filament';

  @override
  String get helpAddFilamentIntroduction => 'This page explains how to correctly add a new filament and which information is required.';

  @override
  String get helpAddFilamentNewTitle => 'Add a New Filament';

  @override
  String get helpAddFilamentNewContent => 'Open the filament section and tap the button to add a new filament.';

  @override
  String get helpAddFilamentSelectTitle => 'Select Filament';

  @override
  String get helpAddFilamentSelectContent => 'Select the manufacturer, material, variant, and color. Many values are automatically filled in from the filament catalog.';

  @override
  String get helpAddFilamentSettingsTitle => 'Print Settings';

  @override
  String get helpAddFilamentSettingsContent => 'Check the diameter as well as nozzle and bed temperature. These values are automatically suggested based on the material.';

  @override
  String get helpAddFilamentStockTitle => 'Stock and Costs';

  @override
  String get helpAddFilamentStockContent => 'Set the spool weight, current stock, and purchase price. These details are later used for cost calculation and inventory management.';

  @override
  String get helpAddFilamentTip => 'Tip: Use the integrated filament catalog whenever possible. This automatically fills in many fields and helps prevent input errors.';

  @override
  String get helpPrintJobTitle => 'Create a Print Job';

  @override
  String get helpPrintJobIntroduction => 'A print job allows you to document your prints while filament consumption is calculated automatically.';

  @override
  String get helpPrintJobNewTitle => 'Create a New Print Job';

  @override
  String get helpPrintJobNewContent => 'Open the \"History\" section and create a new print job.';

  @override
  String get helpPrintJobFilamentTitle => 'Select Filament';

  @override
  String get helpPrintJobFilamentContent => 'Select the filament used from your inventory. Only available filaments can be used.';

  @override
  String get helpPrintJobUsageTitle => 'Enter Consumption';

  @override
  String get helpPrintJobUsageContent => 'Enter how many grams of filament were used. The inventory will then be updated automatically.';

  @override
  String get helpPrintJobInfoTitle => 'Print Information';

  @override
  String get helpPrintJobInfoContent => 'Optionally, you can save the print duration, printer, notes, or other information to keep track of your prints later.';

  @override
  String get helpPrintJobTip => 'Tip: Enter your print jobs as soon as possible after printing. This keeps your inventory and statistics up to date.';

  @override
  String get helpStatisticsTitle => 'Understanding Statistics';

  @override
  String get helpStatisticsIntroduction => 'The statistics show you an overview of your filament consumption, your print jobs, and the resulting costs.';

  @override
  String get helpStatisticsUsageTitle => 'Consumption';

  @override
  String get helpStatisticsUsageContent => 'Here you can see how much filament has been used in total and which materials are used most frequently.';

  @override
  String get helpStatisticsCostsTitle => 'Costs';

  @override
  String get helpStatisticsCostsContent => 'The cost overview calculates your material costs based on the stored filament price and actual consumption.';

  @override
  String get helpStatisticsHistoryTitle => 'Print History';

  @override
  String get helpStatisticsHistoryContent => 'All completed print jobs are automatically included in your statistics.';

  @override
  String get helpStatisticsAnalysisTitle => 'Analysis';

  @override
  String get helpStatisticsAnalysisContent => 'Use the charts and overviews to analyze consumption, costs, and material usage over time.';

  @override
  String get helpStatisticsTip => 'Tip: The more complete your print jobs are, the more accurate your statistics will be.';

  @override
  String get helpBackupTitle => 'Backup & Restore';

  @override
  String get helpBackupIntroduction => 'With a backup, you can save your filaments, print jobs, and settings and restore them later.';

  @override
  String get helpBackupCreateTitle => 'Create a Backup';

  @override
  String get helpBackupCreateContent => 'Create regular backups of your data to prevent any information from being lost.';

  @override
  String get helpBackupRestoreTitle => 'Restore a Backup';

  @override
  String get helpBackupRestoreContent => 'Select a previously created backup file to import your data back into FilaLog.';

  @override
  String get helpBackupFileTitle => 'Backup File';

  @override
  String get helpBackupFileContent => 'Keep your backup files in a safe place, such as a cloud service or an external storage device.';

  @override
  String get helpBackupRegularTitle => 'Back Up Regularly';

  @override
  String get helpBackupRegularContent => 'Create an up-to-date backup especially before making major changes or updating the app.';

  @override
  String get helpBackupTip => 'Tip: With regular backups, you can restore your data at any time without any problems.';

  @override
  String get whatsNew => 'What\'s New';

  @override
  String get version10 => 'Version 1.0';

  @override
  String get firstOfficialRelease => 'First Official Release';

  @override
  String get versionHistory => 'Version History';

  @override
  String get whatsNewIntroduction => 'Here you can find the new features and improvements introduced in each version of FilaLog.';

  @override
  String get whatsNewVersion100 => 'Version 1.0.0';

  @override
  String get whatsNewVersion100Content => '• First official release\n• Filament management\n• Print history\n• Cost calculation\n• Statistics\n• Backup & Restore\n• User account\n• Guest mode\n• Help section\n• Legal information';

  @override
  String get whatsNewTip => 'New features will be added here after each update, so you can always keep track of all changes.';

  @override
  String get legal => 'Legal';

  @override
  String get legalLastUpdated => 'Last updated';

  @override
  String get legalLastUpdatedValue => 'August 2026';

  @override
  String get legalAllRightsReserved => 'All rights reserved.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyUpdated => 'August 2026';

  @override
  String get privacyPolicyResponsible => 'Data Controller';

  @override
  String get privacyPolicyResponsibleLabel => 'Responsible';

  @override
  String get privacyPolicyResponsibleName => 'Robin Pniok';

  @override
  String get privacyPolicyContact => 'Contact';

  @override
  String get privacyPolicyContactMissing => 'Diebesweg 8b\n58507 Lüdenscheid\nGermany\nEmail: support@filalog.de';

  @override
  String get privacyPolicyStoredDataTitle => 'What data is stored?';

  @override
  String get privacyPolicyLocalDataTitle => 'Locally stored data';

  @override
  String get privacyPolicyLocalDataContent => 'Filaments, print jobs, settings, and statistics are stored locally on your device.';

  @override
  String get privacyPolicyNoSharingTitle => 'No data sharing';

  @override
  String get privacyPolicyNoSharingContent => 'No personal data is shared with third parties unless this is required for the use of the app.';

  @override
  String get privacyPolicyAccountTitle => 'Guest Mode & User Account';

  @override
  String get privacyPolicyGuestModeTitle => 'Guest Mode';

  @override
  String get privacyPolicyGuestModeContent => 'The app can be used in guest mode without registration. The data remains stored exclusively on the device.';

  @override
  String get privacyPolicyUserAccountTitle => 'User Account';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceScope => 'Scope';

  @override
  String get termsOfServiceAppUsageTitle => 'Use of the App';

  @override
  String get termsOfServiceAppUsageContent => 'These Terms of Service apply to the use of FilaLog on all supported platforms.';

  @override
  String get termsOfServiceAgreementTitle => 'Agreement';

  @override
  String get termsOfServiceAgreementContent => 'By using the app, you agree to these Terms of Service.';

  @override
  String get termsOfServiceUserObligations => 'User Obligations';

  @override
  String get termsOfServiceResponsibilityTitle => 'Responsibility';

  @override
  String get termsOfServiceResponsibilityContent => 'The user is responsible for the data they enter into the app.';

  @override
  String get termsOfServiceMisuseTitle => 'Misuse';

  @override
  String get termsOfServiceMisuseContent => 'The app must not be misused or used to carry out unlawful activities.';

  @override
  String get termsOfServiceLicensesRights => 'Licenses & Usage Rights';

  @override
  String get termsOfServiceCopyrightTitle => 'Copyright';

  @override
  String get termsOfServiceCopyrightContent => 'All rights to the app, its design, and its content remain with the developer.';

  @override
  String get termsOfServiceNoDistributionTitle => 'No Distribution';

  @override
  String get termsOfServiceNoDistributionContent => 'The app may not be copied, modified, or redistributed without express permission, unless permitted by law.';

  @override
  String get termsOfServiceChanges => 'Changes';

  @override
  String get termsOfServiceUpdatesTitle => 'Updates to the Terms';

  @override
  String get termsOfServiceUpdatesContent => 'The Terms of Service may be updated when new features are introduced or when required by changes in applicable law.';

  @override
  String get termsOfServiceFinalProvisions => 'Final Provisions';

  @override
  String get termsOfServiceApplicableLawTitle => 'Applicable Law';

  @override
  String get termsOfServiceApplicableLawContent => 'The applicable law at the provider\'s place of business shall apply, to the extent permitted by law.';

  @override
  String get privacyPolicyUserAccountContent => 'When using a user account, data may be synchronized with supported devices in the future.';

  @override
  String get privacyPolicyRightsTitle => 'Your Rights';

  @override
  String get privacyPolicyRightsLabel => 'Data Protection Rights';

  @override
  String get privacyPolicyRightsContent => 'You have the right to access, correct, delete, and restrict the processing of your personal data within the scope of applicable data protection laws.';

  @override
  String get privacyPolicyQuestionsTitle => 'Questions About Data Protection';

  @override
  String get privacyPolicyQuestionsContactTitle => 'Contact';

  @override
  String get privacyPolicyQuestionsContactContent => 'If you have questions about data protection, you can contact us using the contact details provided in the legal notice.';

  @override
  String get imprint => 'Legal Notice';

  @override
  String get imprintProviderDetailsTitle => 'Provider Information';

  @override
  String get imprintAppNameLabel => 'App Name';

  @override
  String get imprintAppNameValue => 'FilaLog';

  @override
  String get imprintDeveloperLabel => 'Owner';

  @override
  String get imprintDeveloperValue => 'Robin Pniok';

  @override
  String get imprintAddressLabel => 'Address';

  @override
  String get imprintAddressValue => 'Diebesweg 8b\n58507 Lüdenscheid\nGermany';

  @override
  String get imprintContactTitle => 'Contact';

  @override
  String get imprintEmailLabel => 'Email';

  @override
  String get imprintEmailValue => 'support@filalog.de';

  @override
  String get imprintWebsiteLabel => 'Website';

  @override
  String get imprintWebsiteValue => 'https://filalog.de';

  @override
  String get imprintCompanyInformationTitle => 'Company Information';

  @override
  String get imprintCompanyFormLabel => 'Legal Form';

  @override
  String get imprintCompanyFormValue => 'Sole proprietorship';

  @override
  String get imprintBusinessPurposeLabel => 'Business Purpose';

  @override
  String get imprintBusinessPurposeValue => 'Development and provision of the FilaLog software application for managing 3D printing filament and related functions.';

  @override
  String get imprintLegalNotesTitle => 'Legal Information';

  @override
  String get imprintLiabilityLabel => 'Liability';

  @override
  String get imprintLiabilityContent => 'For more information, please visit the \"Liability\" page.';

  @override
  String get imprintCopyrightLabel => 'Copyright';

  @override
  String get imprintCopyrightContent => 'For more information, please visit the \"Copyright\" page.';

  @override
  String get premiumSubscription => 'Premium & Subscription';

  @override
  String get premiumMembershipTitle => 'Premium Membership';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumContent => 'FilaLog can be tested free of charge for seven days. After that, a Premium membership is required to continue using the app.';

  @override
  String get premiumTrialTitle => 'Trial Period';

  @override
  String get premiumTrialContent => 'All features are available without restrictions during the seven-day trial period.';

  @override
  String get premiumBillingTitle => 'Billing';

  @override
  String get premiumPaymentProcessingTitle => 'Payment Processing';

  @override
  String get premiumPaymentProcessingContent => 'For the web version, payments are processed through Paddle. On Android, payments are processed through Google Play.';

  @override
  String get premiumPlatformsTitle => 'Platforms';

  @override
  String get premiumPlatformsContent => 'For the web version, Premium can be purchased through the official FilaLog website using Paddle. On Android, Premium is purchased through Google Play.';

  @override
  String get premiumTrialAndPremiumTitle => 'Trial Period & Premium';

  @override
  String get premiumSevenDayTrialTitle => '7-Day Trial';

  @override
  String get premiumSevenDayTrialContent => 'New users can test FilaLog free of charge for seven days.';

  @override
  String get premiumAfterTrialTitle => 'After the Trial';

  @override
  String get premiumAfterTrialContent => 'After the trial period ends, a Premium membership is required to continue using FilaLog.';

  @override
  String get premiumMembershipTermsTitle => 'Membership';

  @override
  String get premiumDurationTitle => 'Subscription Periods';

  @override
  String get premiumDurationContent => 'For the web version, Premium is offered as an annual subscription for €19.99 per year. On Android, monthly and annual subscriptions are available through Google Play.';

  @override
  String get premiumCancellationTitle => 'Cancellation';

  @override
  String get premiumCancellationContent => 'The membership can be cancelled at any time effective at the end of the current subscription period.';

  @override
  String get withdrawal => 'Right of Withdrawal';

  @override
  String get withdrawalRightTitle => 'Right of Withdrawal';

  @override
  String get withdrawalPeriodTitle => 'Withdrawal Period';

  @override
  String get withdrawalPeriodContent => 'Consumers generally have the right to withdraw from a contract within fourteen days.';

  @override
  String get withdrawalReasonTitle => 'No Reason Required';

  @override
  String get withdrawalReasonContent => 'The right of withdrawal may be exercised within the statutory withdrawal period without stating any reason.';

  @override
  String get withdrawalExerciseTitle => 'Exercising the Right of Withdrawal';

  @override
  String get withdrawalDeclarationTitle => 'Clear Declaration';

  @override
  String get withdrawalDeclarationContent => 'To exercise the right of withdrawal, a clear declaration expressing the decision to withdraw from the contract is required.';

  @override
  String get withdrawalDeadlineTitle => 'Meeting the Deadline';

  @override
  String get withdrawalDeadlineContent => 'To meet the withdrawal deadline, it is sufficient to send the declaration before the withdrawal period expires.';

  @override
  String get withdrawalPremiumTitle => 'Premium & Digital Services';

  @override
  String get withdrawalDigitalServiceTitle => 'Digital Service';

  @override
  String get withdrawalDigitalServiceContent => 'The Premium membership provides access to additional digital features and services offered by FilaLog.';

  @override
  String get withdrawalEarlyExpiryTitle => 'Early Start of the Service';

  @override
  String get withdrawalEarlyExpiryContent => 'An early start of the provision of digital services or a possible loss of the right of withdrawal is subject to the applicable legal requirements and the information provided when the contract is concluded.';

  @override
  String get withdrawalInformationTitle => 'Further Information';

  @override
  String get withdrawalPurchaseInfoTitle => 'Information at Checkout';

  @override
  String get withdrawalPurchaseInfoContent => 'Before completing a Premium membership, the legally required information regarding the right of withdrawal and the processing of the contract is provided for the respective purchase.';

  @override
  String get refundPolicy => 'Refund Policy';

  @override
  String get refundGeneralTitle => 'Refunds';

  @override
  String get refundGeneralContent => 'Payments for FilaLog Premium are processed by the respective payment provider. Refunds are subject to the applicable terms of that provider as well as mandatory statutory consumer rights.';

  @override
  String get refundWebTitle => 'Web Version via Paddle';

  @override
  String get refundWebContent => 'For Premium subscriptions purchased through the FilaLog web version, payments are processed by Paddle. Refund requests can be submitted through Paddle\'s buyer support. Statutory consumer rights remain unaffected.';

  @override
  String get refundAndroidTitle => 'Android via Google Play';

  @override
  String get refundAndroidContent => 'For Premium subscriptions purchased through the Android app, payments are processed through Google Play. Refunds are subject to the terms and procedures of Google Play. Statutory consumer rights remain unaffected.';

  @override
  String get refundCancellationTitle => 'Subscription Cancellation';

  @override
  String get refundCancellationContent => 'Cancelling a subscription stops its automatic renewal. Amounts already paid are not automatically refunded when a subscription is cancelled. Any potential refund is assessed separately from the cancellation.';

  @override
  String get refundWithdrawalTitle => 'Right of Withdrawal';

  @override
  String get refundWithdrawalContent => 'This refund policy does not restrict any statutory rights of withdrawal or other consumer rights. Further information is available in FilaLog\'s separate Right of Withdrawal notice.';

  @override
  String get refundSupportTitle => 'Questions and Support';

  @override
  String get refundSupportContent => 'If you have questions about a purchase or refund, you can contact support@filalog.de.';

  @override
  String get consumerInformation => 'Consumer Information';

  @override
  String get consumerProviderTitle => 'Provider';

  @override
  String get consumerResponsibleTitle => 'Responsible Party';

  @override
  String get consumerResponsibleContent => 'Information about the provider can be found in the legal notice.';

  @override
  String get consumerContactTitle => 'Contact';

  @override
  String get consumerContactContent => 'Questions can be submitted at any time using the contact details provided in the legal notice.';

  @override
  String get consumerContractTitle => 'Contract Information';

  @override
  String get consumerPremiumTitle => 'Premium Membership';

  @override
  String get consumerPremiumContent => 'Before completing a Premium membership, all essential information regarding the price, duration and payment method is provided.';

  @override
  String get consumerContractConclusionTitle => 'Conclusion of Contract';

  @override
  String get consumerContractConclusionContent => 'The contract is concluded only after the respective purchase process has been successfully completed.';

  @override
  String get consumerSupportTitle => 'Support';

  @override
  String get consumerHelpTitle => 'Help';

  @override
  String get consumerHelpContent => 'If you have any questions or problems, support is available through the official contact options.';

  @override
  String get liability => 'Liability';

  @override
  String get liabilityTitle => 'Liability';

  @override
  String get liabilityContentTitle => 'Liability for Content';

  @override
  String get liabilityCareTitle => 'Due Care';

  @override
  String get liabilityCareContent => 'The content provided by FilaLog is created with due care and reviewed regularly.';

  @override
  String get liabilityNoWarrantyTitle => 'No Warranty';

  @override
  String get liabilityNoWarrantyContent => 'Despite careful preparation, no guarantee can be given regarding the accuracy, completeness or timeliness of all information provided.';

  @override
  String get liabilityExternalContentTitle => 'External Content';

  @override
  String get liabilityExternalLinksTitle => 'Links and External Services';

  @override
  String get liabilityExternalLinksContent => 'The respective operators are responsible for the content of external websites or services referenced within FilaLog.';

  @override
  String get liabilityUsageTitle => 'Notice on Use';

  @override
  String get liabilityGeneralInformationTitle => 'General Information';

  @override
  String get liabilityGeneralInformationContent => 'The information provided in FilaLog is intended to support the management and organization of filament and 3D printing-related data.';

  @override
  String get copyright => 'Copyright';

  @override
  String get copyrightRightsTitle => 'Copyright';

  @override
  String get copyrightAppTitle => 'App';

  @override
  String get copyrightAppContent => 'FilaLog and all associated content, designs and source code are protected by copyright.';

  @override
  String get copyrightUsageTitle => 'Use';

  @override
  String get copyrightUsageContent => 'Reproduction, publication or distribution is not permitted without express permission.';

  @override
  String get copyrightGraphicsContentTitle => 'Graphics & Content';

  @override
  String get copyrightOwnContentTitle => 'Original Content';

  @override
  String get copyrightOwnContentContent => 'Original graphics, texts and logos are protected by the developer\'s copyright.';

  @override
  String get copyrightThirdPartyTitle => 'Third-Party Content';

  @override
  String get copyrightThirdPartyContent => 'Third-party content is used in accordance with the respective applicable licenses.';

  @override
  String get copyrightLicenseNoticeTitle => 'License Notice';

  @override
  String get copyrightOpenSourceTitle => 'Open Source';

  @override
  String get copyrightOpenSourceContent => 'Open-source components are used in accordance with their respective licenses.';

  @override
  String get imageCredits => 'Image Credits';

  @override
  String get imageCreditsGraphicsTitle => 'Graphics Used';

  @override
  String get imageCreditsOwnGraphicsTitle => 'Original Graphics';

  @override
  String get imageCreditsOwnGraphicsContent => 'All self-created graphics, logos and illustrations are protected by the developer\'s copyright.';

  @override
  String get imageCreditsAppIconsTitle => 'App Icons';

  @override
  String get imageCreditsAppIconsContent => 'The icons used are from the official Flutter Material Icons.';

  @override
  String get imageCreditsColorsDesignTitle => 'Colors & Design';

  @override
  String get imageCreditsInterfaceTitle => 'User Interface';

  @override
  String get imageCreditsInterfaceContent => 'The design of FilaLog was independently developed.';

  @override
  String get imageCreditsBrandsTitle => 'Brands';

  @override
  String get imageCreditsBrandsContent => 'Brand names and manufacturer designations remain the property of their respective owners.';

  @override
  String get imageCreditsNoticeTitle => 'Notice';

  @override
  String get imageCreditsUpdateTitle => 'Updates';

  @override
  String get imageCreditsUpdateContent => 'If additional images or external graphics are used in the future, the corresponding image credits will be added here.';

  @override
  String get account => 'Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInFailed => 'Sign in failed.';

  @override
  String get signInSubtitle => 'Sign in with an existing account.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in with your user account.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSubtitle => 'Enter your email address. We will send you a link to reset your password.';

  @override
  String get sendingResetLink => 'Sending link...';

  @override
  String get sendResetLink => 'Send Link';

  @override
  String get resetLinkSent => 'Link sent';

  @override
  String get resetPasswordSent => 'We have sent you an email to reset your password.';

  @override
  String get resetPasswordFailed => 'Password reset failed.';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountSubtitle => 'Create a new user account.';

  @override
  String get registerAppBarTitle => 'Create Account';

  @override
  String get registerTitle => 'New User Account';

  @override
  String get registerSubtitle => 'Create your personal user account.';

  @override
  String get repeatPassword => 'Repeat Password';

  @override
  String get registerButton => 'Create Account';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get registrationFailed => 'Registration failed.';

  @override
  String get emailAlreadyInUse => 'This email address is already in use.';

  @override
  String get weakPassword => 'The password is too weak.';

  @override
  String get invalidEmail => 'The email address is invalid.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutSubtitle => 'Sign out of the current account.';

  @override
  String signOutFailed(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String get about => 'About';

  @override
  String get appName => 'FilaLog';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get developer => 'Developer';

  @override
  String get technology => 'Technology';

  @override
  String get website => 'Website';

  @override
  String get thankYou => 'Thank You';

  @override
  String get thankYouMessage => 'Thank you for using FilaLog.';

  @override
  String get openSourceLicenses => 'Open-Source Licenses';

  @override
  String get feedbackMailGreeting => 'Hello,\n\n';

  @override
  String get feedbackMailDescription => 'I have the following feedback or suggestion for improvement:\n\n';

  @override
  String get errorReportMailGreeting => 'Hello,\n\n';

  @override
  String get errorReportMailDescription => 'I found the following error.\n\n';

  @override
  String get appVersionLabel => 'App Version:';

  @override
  String get deviceLabel => 'Device:';

  @override
  String get browserLabel => 'Browser (Web):';

  @override
  String get descriptionLabel => 'Description:';

  @override
  String get stepsToReproduceLabel => 'Steps to Reproduce:';

  @override
  String get supportMailGreeting => 'Hello,\n\n';

  @override
  String get supportMailDescription => 'I need help with the following topic.\n\n';

  @override
  String get thankYouMail => 'Thank you.';

  @override
  String get details => 'Details';

  @override
  String get totalInventory => 'Total Inventory';

  @override
  String get inventoryValue => 'Inventory Value';

  @override
  String get noFilamentsAvailable => 'No filaments available';

  @override
  String get printJobs => 'Print Jobs';

  @override
  String get statisticsPrints => 'Prints';

  @override
  String get statisticsMaterials => 'Materials';

  @override
  String get statisticsConsumption => 'Consumption';

  @override
  String get printed => 'Printed';

  @override
  String get totalPrintCosts => 'Total Print Costs';

  @override
  String get averageCostPerPrint => 'Avg. Cost per Print';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get calculatePrint => 'Calculate print';

  @override
  String get newManufacturer => 'New manufacturer';

  @override
  String get manufacturerName => 'Manufacturer name';

  @override
  String get newMaterial => 'New material';

  @override
  String get materialName => 'Material name';

  @override
  String get newVariant => 'New variant';

  @override
  String get variantName => 'Variant name';

  @override
  String get newColor => 'New color';

  @override
  String get colorName => 'Color name';

  @override
  String get searchManufacturer => 'Search manufacturer...';

  @override
  String get searchMaterial => 'Search material...';

  @override
  String get searchVariant => 'Search variant...';

  @override
  String get searchColor => 'Search color...';

  @override
  String get add => 'Add';

  @override
  String get fillAllRequiredFields => 'Please fill in all required fields.';

  @override
  String get temperatures => 'Temperatures';

  @override
  String get inventoryAndCost => 'Inventory & Cost';

  @override
  String get spoolWeight => 'Spool weight';

  @override
  String get custom => 'Custom...';

  @override
  String get weightInGrams => 'Weight in g';

  @override
  String get printSettings => 'Print Settings';

  @override
  String get printSaved => 'Print saved';

  @override
  String get addPrinter => 'Add printer';

  @override
  String get editPrinter => 'Edit printer';

  @override
  String get printerName => 'Printer name';

  @override
  String get averageWatt => 'Average power';

  @override
  String get enterPrinterNameAndWatt => 'Please enter a printer name and power.';

  @override
  String get managePrinters => 'Manage printers';

  @override
  String get noCustomPrinters => 'No custom printers available.';

  @override
  String get edit => 'Edit';

  @override
  String get deletePrinter => 'Delete printer';

  @override
  String confirmDeletePrinter(String printerName) {
    return 'Really delete printer $printerName?';
  }

  @override
  String get searchPrinter => 'Search printer...';

  @override
  String get calculateCosts => 'Calculate costs';

  @override
  String get project => 'Project';

  @override
  String get projectName => 'Project name';

  @override
  String get date => 'Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectFilament => 'Select filament';

  @override
  String get selectPrinter => 'Select printer';

  @override
  String get calculation => 'Calculation';

  @override
  String get watt => 'Watts';

  @override
  String get objectWeight => 'Object weight';

  @override
  String get printTimeMinutes => 'Print time in minutes';

  @override
  String get spoolPrice => 'Spool price';

  @override
  String get electricityCostPerKwh => 'Electricity cost per kWh';

  @override
  String get subtractFromStock => 'Deduct from inventory';

  @override
  String get filamentCost => 'Filament cost';

  @override
  String get electricityCost => 'Electricity cost';

  @override
  String get totalCost => 'Total cost';

  @override
  String get usageByMaterial => 'Usage by material';

  @override
  String get usageByMonth => 'Usage by month';

  @override
  String get costsByMaterial => 'Costs by material';

  @override
  String get costsByMonth => 'Costs by month';

  @override
  String get overallOverview => 'Overall overview';

  @override
  String get printTime => 'Print time';

  @override
  String get costs => 'Costs';

  @override
  String get welcomeTrialTitle => 'Try for 7 days free';

  @override
  String get welcomeTrialDescription => 'Try FilaLog free for 7 days and decide afterwards whether you want to continue with Premium.';

  @override
  String get welcomePerMonth => 'per month';

  @override
  String get welcomePerYear => 'per year';

  @override
  String get welcomeCheaper => 'Better value';

  @override
  String get welcomeTrialFooter => 'After the trial period, you can decide whether you want to continue using FilaLog Premium.';

  @override
  String get averagePerPrint => 'Average per print';

  @override
  String get topMaterial => 'Top material';

  @override
  String get usageByMaterialWithUnit => 'Usage by material (g)';

  @override
  String get usageByMonthWithUnit => 'Usage by month (g)';

  @override
  String get costsByMaterialWithUnit => 'Costs by material (€)';

  @override
  String get costsByMonthWithUnit => 'Costs by month (€)';

  @override
  String get noPrintData => 'No print data available.';

  @override
  String get sortByDateNewest => 'Date (newest → oldest)';

  @override
  String get sortByDateOldest => 'Date (oldest → newest)';

  @override
  String get sortByCost => 'Cost';

  @override
  String get sortByWeight => 'Weight';

  @override
  String get sortByProjectName => 'Project name';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get printHistory => 'Print History';

  @override
  String get searchProject => 'Search project...';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get noPrintsAvailable => 'No print jobs available.';

  @override
  String historyJobs(int count) {
    return '$count job(s)';
  }

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get guestModeDescription => 'Try FilaLog free for 7 days without registration.';

  @override
  String get guestModeDataInfo => 'All data created during this period will be retained and can later be transferred to a user account.';

  @override
  String get startAsGuest => 'Start as Guest';

  @override
  String get login => 'Sign In';

  @override
  String get loginDescription => 'Sign in with your existing user account.';

  @override
  String get loginDataInfo => 'Your data is automatically synchronized and available on Android and in the web version.';

  @override
  String get registerAccount => 'Create Account';

  @override
  String get registerAccountDescription => 'Create a new user account and keep your data permanently secure.';

  @override
  String get registerAccountDataInfo => 'Your existing data from Guest Mode will be automatically transferred and will then be available on all supported devices.';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get accountSuccessfullyCreated => 'Account Successfully Created';

  @override
  String get accountCreatedDescription => 'Your user account has been successfully created.';

  @override
  String get verifyEmailTitle => 'Verify email';

  @override
  String get verifyEmailAlmostDone => 'Almost done';

  @override
  String get verifyEmailInstructions => 'We sent you a verification email.\n\nPlease open the link in the email to activate your account.';

  @override
  String get verifyEmailNotVerified => 'Email has not been verified yet.';

  @override
  String get verifyEmailCheckFailed => 'The email verification could not be checked. Please try again.';

  @override
  String get verifyEmailResent => 'Verification email has been sent again.';

  @override
  String get verifyEmailSendFailed => 'The verification email could not be sent.';

  @override
  String get verifyEmailChecking => 'Checking...';

  @override
  String get verifyEmailCheckAgain => 'Check again';

  @override
  String get verifyEmailSending => 'Sending...';

  @override
  String get verifyEmailResend => 'Resend email';

  @override
  String get accountCreatedEmailVerificationInfo => 'Please confirm your email address now. You can then sign in and start using FilaLog.';

  @override
  String get emailConfirmed => 'Email Confirmed';

  @override
  String get emailRequired => 'Please enter your email address.';

  @override
  String get emailInvalid => 'Please enter a valid email address.';

  @override
  String get passwordRequired => 'Please enter your password.';

  @override
  String get passwordTooShort => 'The password must be at least 8 characters long.';

  @override
  String get confirmPasswordRequired => 'Please repeat your password.';

  @override
  String get passwordsDoNotMatch => 'The passwords do not match.';

  @override
  String get back => 'Back';

  @override
  String get trialExpiredTitle => 'Your trial has ended';

  @override
  String get trialExpiredSubtitle => 'You have tested FilaLog free of charge for 7 days.';

  @override
  String get trialExpiredLoginHint => 'Sign in with your FilaLog account to activate Premium.';

  @override
  String get trialExpiredPremiumHint => 'Choose your Premium subscription now and continue using all features without restrictions.';

  @override
  String get trialExpiredLoginButton => 'Sign in';

  @override
  String get trialExpiredRegisterButton => 'Create account';

  @override
  String get trialExpiredLoginRequiredInfo => 'A PayPal subscription can only be clearly assigned to your FilaLog account after you sign in.';

  @override
  String get trialExpiredMonthlyTitle => 'Monthly';

  @override
  String get trialExpiredMonthlyPrice => '€2.49';

  @override
  String get trialExpiredMonthlyPeriod => 'per month';

  @override
  String get trialExpiredYearlyTitle => 'Yearly';

  @override
  String get trialExpiredYearlyPrice => '€19.99';

  @override
  String get trialExpiredYearlyPeriod => 'per year';

  @override
  String get trialExpiredYearlyBadge => 'Best value';

  @override
  String get trialExpiredPaypalOpened => 'PayPal has been opened. Complete the subscription there.';

  @override
  String get trialExpiredPaypalOpenedInfo => 'PayPal has been opened. Complete the subscription there. Premium access will then be activated automatically.';

  @override
  String get trialExpiredPaypalStartError => 'The PayPal subscription could not be started.';

  @override
  String get trialExpiredPaypalManagementInfo => 'Payment and subscription management are handled through PayPal.';
}
