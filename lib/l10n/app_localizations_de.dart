// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get filament => 'Filament';

  @override
  String get filaments => 'Filamente';

  @override
  String get cost => 'Kosten';

  @override
  String get history => 'Historie';

  @override
  String get statistics => 'Statistik';

  @override
  String get settings => 'Einstellungen';

  @override
  String get design => 'Design';

  @override
  String get language => 'Sprache';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get critical => 'Kritisch';

  @override
  String criticalFilaments(int count) {
    return '$count Filament(e) kritisch';
  }

  @override
  String get filter => 'Filter';

  @override
  String get close => 'Schließen';

  @override
  String get searchFilament => 'Filament suchen...';

  @override
  String get manufacturer => 'Hersteller';

  @override
  String get material => 'Material';

  @override
  String get editFilament => 'Filament bearbeiten';

  @override
  String get variant => 'Variante';

  @override
  String get color => 'Farbe';

  @override
  String get diameter => 'Durchmesser';

  @override
  String get price => 'Preis';

  @override
  String get colorBlack => 'Schwarz';

  @override
  String get colorWhite => 'Weiß';

  @override
  String get colorGray => 'Grau';

  @override
  String get colorRed => 'Rot';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorYellow => 'Gelb';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorBrown => 'Braun';

  @override
  String get colorTurquoise => 'Türkis';

  @override
  String get colorGold => 'Gold';

  @override
  String get colorSilver => 'Silber';

  @override
  String get colorBronze => 'Bronze';

  @override
  String get colorCopper => 'Kupfer';

  @override
  String get colorBeige => 'Beige';

  @override
  String get colorCream => 'Creme';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorAnthracite => 'Anthrazit';

  @override
  String get colorGraphite => 'Graphit';

  @override
  String get colorKhaki => 'Khaki';

  @override
  String get colorOlive => 'Oliv';

  @override
  String get colorLime => 'Limette';

  @override
  String get colorTeal => 'Blaugrün';

  @override
  String get colorBurgundy => 'Burgunderrot';

  @override
  String get colorTerracotta => 'Terrakotta';

  @override
  String get colorPeach => 'Pfirsich';

  @override
  String get colorApricot => 'Aprikose';

  @override
  String get colorLavender => 'Lavendel';

  @override
  String get colorClear => 'Klar';

  @override
  String get colorTransparent => 'Transparent';

  @override
  String get colorNatural => 'Natur';

  @override
  String get colorDarkBlue => 'Dunkelblau';

  @override
  String get colorLightBlue => 'Hellblau';

  @override
  String get colorDarkGreen => 'Dunkelgrün';

  @override
  String get colorLightGreen => 'Hellgrün';

  @override
  String get colorDarkRed => 'Dunkelrot';

  @override
  String get colorLightRed => 'Hellrot';

  @override
  String get colorDarkGray => 'Dunkelgrau';

  @override
  String get colorLightGray => 'Hellgrau';

  @override
  String get colorDarkBrown => 'Dunkelbraun';

  @override
  String get colorLightBrown => 'Hellbraun';

  @override
  String get colorDarkOrange => 'Dunkelorange';

  @override
  String get colorLightOrange => 'Hellorange';

  @override
  String get remainingWeight => 'Restgewicht';

  @override
  String get editRemainingWeight => 'Restgewicht ändern';

  @override
  String get remainingWeightGrams => 'Restgewicht (g)';

  @override
  String get spools => 'Spulen';

  @override
  String get spool => 'Spule';

  @override
  String get editSpool => 'Spule bearbeiten';

  @override
  String get weight => 'Gewicht';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get deleteLastSpool => 'Letzte Spule löschen';

  @override
  String get deleteSpool => 'Spule löschen';

  @override
  String get delete => 'Löschen';

  @override
  String get newSpool => 'Neue Spule';

  @override
  String get addSpool => 'Spule hinzufügen';

  @override
  String get selectMaterial => 'Material auswählen';

  @override
  String get nozzle => 'Nozzle';

  @override
  String get bed => 'Bed';

  @override
  String spoolNumber(int number) {
    return 'Spule $number';
  }

  @override
  String remainingWeightOfTotal(int remainingWeight, int totalWeight) {
    return '$remainingWeight g von $totalWeight g';
  }

  @override
  String get deleteAndRemoveFilament => 'Löschen & Filament entfernen';

  @override
  String get deleteFilamentTitle => 'Filament löschen?';

  @override
  String get deleteFilamentConfirmation => 'Möchtest du dieses Filament wirklich löschen?';

  @override
  String get deleteLastSpoolWarning => 'Dieses Filament enthält danach keine Spulen mehr.\n\nFilament komplett löschen?';

  @override
  String deleteSpoolConfirmation(int number) {
    return 'Spule $number wirklich löschen?';
  }

  @override
  String get sort => 'Sortieren';

  @override
  String get sortByMaterial => 'Nach Material';

  @override
  String get sortByRemainingWeight => 'Nach Restgewicht';

  @override
  String get sortByName => 'Nach Name';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get warningFilament => 'Filament-Überwachung';

  @override
  String warningBelow(String percent) {
    return 'Warnung unter $percent %';
  }

  @override
  String get backup => 'Backup';

  @override
  String get backupExport => 'Backup exportieren';

  @override
  String get backupImport => 'Backup importieren';

  @override
  String get backupSaveDialog => 'Backup speichern';

  @override
  String get backupCreated => 'Backup erstellt';

  @override
  String get backupLoaded => 'Backup erfolgreich geladen';

  @override
  String get backupLoadError => 'Fehler beim Laden des Backups';

  @override
  String get backupDescription => 'Exportiert und importiert Filamente und Druckjobs.';

  @override
  String get support => 'Support';

  @override
  String get errorReportSubject => 'Fehlerbericht FilaLog';

  @override
  String get sendFeedback => 'Feedback senden';

  @override
  String get reportError => 'Fehler melden';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get contact => 'Kontakt';

  @override
  String get contactSubject => 'Support FilaLog';

  @override
  String get help => 'Hilfe';

  @override
  String get firstSteps => 'Erste Schritte';

  @override
  String get addFilament => 'Filament hinzufügen';

  @override
  String get createPrintJob => 'Druckauftrag erstellen';

  @override
  String get understandStatistics => 'Statistiken verstehen';

  @override
  String get backupAndRestore => 'Backup & Wiederherstellung';

  @override
  String get helpFirstStepsTitle => 'Erste Schritte';

  @override
  String get helpFirstStepsIntroduction => 'Willkommen bei FilaLog. Diese Anleitung hilft dir beim Einstieg und erklärt die wichtigsten Funktionen der App.';

  @override
  String get helpFirstStepsFilamentTitle => '1. Filament hinzufügen';

  @override
  String get helpFirstStepsFilamentContent => 'Lege zunächst dein erstes Filament an. Alle weiteren Funktionen bauen auf deinen Filamentbestand auf.';

  @override
  String get helpFirstStepsPrintTitle => '2. Druckauftrag erstellen';

  @override
  String get helpFirstStepsPrintContent => 'Erstelle anschließend einen Druckauftrag. Der Filamentverbrauch wird automatisch berechnet und vom Bestand abgezogen.';

  @override
  String get helpFirstStepsStatisticsTitle => '3. Statistiken nutzen';

  @override
  String get helpFirstStepsStatisticsContent => 'Im Statistikbereich erhältst du einen Überblick über deinen Verbrauch, deine Kosten und deine Druckhistorie.';

  @override
  String get helpFirstStepsBackupTitle => '4. Backup erstellen';

  @override
  String get helpFirstStepsBackupContent => 'Erstelle regelmäßig ein Backup deiner Daten, damit dein Filamentbestand und deine Druckhistorie jederzeit gesichert sind.';

  @override
  String get helpFirstStepsTip => 'Tipp: Beginne mit wenigen Filamenten. So lernst du die App schnell kennen und behältst jederzeit den Überblick.';

  @override
  String get helpAddFilamentTitle => 'Filament hinzufügen';

  @override
  String get helpAddFilamentIntroduction => 'Auf dieser Seite erfährst du, wie du ein neues Filament korrekt anlegst und welche Informationen dafür benötigt werden.';

  @override
  String get helpAddFilamentNewTitle => 'Neues Filament anlegen';

  @override
  String get helpAddFilamentNewContent => 'Öffne den Filamentbereich und tippe auf die Schaltfläche zum Hinzufügen eines neuen Filaments.';

  @override
  String get helpAddFilamentSelectTitle => 'Filament auswählen';

  @override
  String get helpAddFilamentSelectContent => 'Wähle Hersteller, Material, Variante und Farbe aus. Viele Werte werden automatisch aus dem Filamentkatalog übernommen.';

  @override
  String get helpAddFilamentSettingsTitle => 'Druckeinstellungen';

  @override
  String get helpAddFilamentSettingsContent => 'Kontrolliere Durchmesser sowie Düsen- und Betttemperatur. Diese Werte werden abhängig vom Material automatisch vorgeschlagen.';

  @override
  String get helpAddFilamentStockTitle => 'Bestand und Kosten';

  @override
  String get helpAddFilamentStockContent => 'Lege das Spulengewicht, den aktuellen Bestand und den Kaufpreis fest. Diese Angaben werden später für Kostenberechnung und Lagerverwaltung verwendet.';

  @override
  String get helpAddFilamentTip => 'Tipp: Nutze möglichst den integrierten Filamentkatalog. Dadurch werden viele Eingaben automatisch ausgefüllt und Eingabefehler vermieden.';

  @override
  String get helpPrintJobTitle => 'Druckauftrag erstellen';

  @override
  String get helpPrintJobIntroduction => 'Mit einem Druckauftrag dokumentierst du deine Drucke und der Filamentverbrauch wird automatisch berechnet.';

  @override
  String get helpPrintJobNewTitle => 'Neuen Druckauftrag erstellen';

  @override
  String get helpPrintJobNewContent => 'Öffne den Bereich \"Historie\" und lege einen neuen Druckauftrag an.';

  @override
  String get helpPrintJobFilamentTitle => 'Filament auswählen';

  @override
  String get helpPrintJobFilamentContent => 'Wähle das verwendete Filament aus deinem Bestand aus. Nur vorhandene Filamente können verwendet werden.';

  @override
  String get helpPrintJobUsageTitle => 'Verbrauch eingeben';

  @override
  String get helpPrintJobUsageContent => 'Gib an, wie viele Gramm Filament verbraucht wurden. Der Bestand wird anschließend automatisch aktualisiert.';

  @override
  String get helpPrintJobInfoTitle => 'Druckinformationen';

  @override
  String get helpPrintJobInfoContent => 'Optional kannst du Druckdauer, Drucker, Notizen oder weitere Informationen speichern, um später den Überblick zu behalten.';

  @override
  String get helpPrintJobTip => 'Tipp: Trage deine Druckaufträge möglichst direkt nach dem Druck ein. So bleiben Bestand und Statistiken immer aktuell.';

  @override
  String get helpStatisticsTitle => 'Statistiken verstehen';

  @override
  String get helpStatisticsIntroduction => 'Die Statistik zeigt dir eine Übersicht über deinen Filamentverbrauch, deine Druckaufträge und die entstandenen Kosten.';

  @override
  String get helpStatisticsUsageTitle => 'Verbrauch';

  @override
  String get helpStatisticsUsageContent => 'Hier siehst du, wie viel Filament insgesamt verbraucht wurde und welche Materialien am häufigsten verwendet werden.';

  @override
  String get helpStatisticsCostsTitle => 'Kosten';

  @override
  String get helpStatisticsCostsContent => 'Die Kostenübersicht berechnet deine Materialkosten anhand des hinterlegten Filamentpreises und des tatsächlichen Verbrauchs.';

  @override
  String get helpStatisticsHistoryTitle => 'Druckhistorie';

  @override
  String get helpStatisticsHistoryContent => 'Alle abgeschlossenen Druckaufträge fließen automatisch in deine Statistiken ein.';

  @override
  String get helpStatisticsAnalysisTitle => 'Auswertungen';

  @override
  String get helpStatisticsAnalysisContent => 'Nutze die Diagramme und Übersichten, um Verbrauch, Kosten und Materialeinsatz langfristig auszuwerten.';

  @override
  String get helpStatisticsTip => 'Tipp: Je vollständiger deine Druckaufträge gepflegt sind, desto genauer werden die Statistiken.';

  @override
  String get helpBackupTitle => 'Backup & Wiederherstellung';

  @override
  String get helpBackupIntroduction => 'Mit einem Backup kannst du deine Filamente, Druckaufträge und Einstellungen sichern und später wiederherstellen.';

  @override
  String get helpBackupCreateTitle => 'Backup erstellen';

  @override
  String get helpBackupCreateContent => 'Erstelle regelmäßig ein Backup deiner Daten, damit keine Informationen verloren gehen.';

  @override
  String get helpBackupRestoreTitle => 'Backup wiederherstellen';

  @override
  String get helpBackupRestoreContent => 'Wähle eine zuvor erstellte Sicherungsdatei aus, um deine Daten wieder in FilaLog zu importieren.';

  @override
  String get helpBackupFileTitle => 'Sicherungsdatei';

  @override
  String get helpBackupFileContent => 'Bewahre deine Backup-Dateien an einem sicheren Ort auf, beispielsweise in einer Cloud oder auf einem externen Datenträger.';

  @override
  String get helpBackupRegularTitle => 'Regelmäßig sichern';

  @override
  String get helpBackupRegularContent => 'Erstelle besonders vor größeren Änderungen oder App-Updates ein aktuelles Backup.';

  @override
  String get helpBackupTip => 'Tipp: Mit regelmäßigen Backups kannst du deine Daten jederzeit problemlos wiederherstellen.';

  @override
  String get whatsNew => 'Was ist neu';

  @override
  String get version10 => 'Version 1.0';

  @override
  String get firstOfficialRelease => 'Erstes offizielles Release';

  @override
  String get versionHistory => 'Versionsverlauf';

  @override
  String get whatsNewIntroduction => 'Hier findest du die Neuerungen und Verbesserungen jeder Version von FilaLog.';

  @override
  String get whatsNewVersion100 => 'Version 1.0.0';

  @override
  String get whatsNewVersion100Content => '• Erste offizielle Veröffentlichung\n• Filamentverwaltung\n• Druckhistorie\n• Kostenberechnung\n• Statistiken\n• Backup & Wiederherstellung\n• Benutzerkonto\n• Gastmodus\n• Hilfebereich\n• Rechtliche Informationen';

  @override
  String get whatsNewTip => 'Neue Funktionen werden nach jedem Update hier ergänzt. So behältst du jederzeit den Überblick über alle Änderungen.';

  @override
  String get legal => 'Rechtliches';

  @override
  String get legalLastUpdated => 'Letzte Aktualisierung';

  @override
  String get legalLastUpdatedValue => 'August 2026';

  @override
  String get legalAllRightsReserved => 'Alle Rechte vorbehalten.';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get privacyPolicyUpdated => 'August 2026';

  @override
  String get privacyPolicyResponsible => 'Verantwortlicher';

  @override
  String get privacyPolicyResponsibleLabel => 'Verantwortlich';

  @override
  String get privacyPolicyResponsibleName => 'Robin Pniok';

  @override
  String get privacyPolicyContact => 'Kontakt';

  @override
  String get privacyPolicyContactMissing => 'Diebesweg 8b\n58507 Lüdenscheid\nE-Mail: support@filalog.de';

  @override
  String get privacyPolicyStoredDataTitle => 'Welche Daten werden gespeichert?';

  @override
  String get privacyPolicyLocalDataTitle => 'Lokal gespeicherte Daten';

  @override
  String get privacyPolicyLocalDataContent => 'Filamente, Druckaufträge, Einstellungen und Statistiken werden lokal auf deinem Gerät gespeichert.';

  @override
  String get privacyPolicyNoSharingTitle => 'Keine Weitergabe';

  @override
  String get privacyPolicyNoSharingContent => 'Es erfolgt keine Weitergabe personenbezogener Daten an Dritte, sofern dies nicht für die Nutzung der App erforderlich ist.';

  @override
  String get privacyPolicyAccountTitle => 'Gastmodus & Benutzerkonto';

  @override
  String get privacyPolicyGuestModeTitle => 'Gastmodus';

  @override
  String get privacyPolicyGuestModeContent => 'Die Nutzung der App ist im Gastmodus ohne Registrierung möglich. Die Daten bleiben ausschließlich auf dem Gerät gespeichert.';

  @override
  String get privacyPolicyUserAccountTitle => 'Benutzerkonto';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get termsOfServiceScope => 'Geltungsbereich';

  @override
  String get termsOfServiceAppUsageTitle => 'Nutzung der App';

  @override
  String get termsOfServiceAppUsageContent => 'Diese Nutzungsbedingungen gelten für die Nutzung von FilaLog auf allen unterstützten Plattformen.';

  @override
  String get termsOfServiceAgreementTitle => 'Zustimmung';

  @override
  String get termsOfServiceAgreementContent => 'Mit der Nutzung der App erklärst du dich mit diesen Nutzungsbedingungen einverstanden.';

  @override
  String get termsOfServiceUserObligations => 'Pflichten des Nutzers';

  @override
  String get termsOfServiceResponsibilityTitle => 'Verantwortung';

  @override
  String get termsOfServiceResponsibilityContent => 'Der Nutzer ist für die von ihm eingegebenen Daten selbst verantwortlich.';

  @override
  String get termsOfServiceMisuseTitle => 'Missbrauch';

  @override
  String get termsOfServiceMisuseContent => 'Die App darf nicht missbräuchlich oder zur Durchführung rechtswidriger Handlungen verwendet werden.';

  @override
  String get termsOfServiceLicensesRights => 'Lizenzen & Nutzungsrechte';

  @override
  String get termsOfServiceCopyrightTitle => 'Urheberrechte';

  @override
  String get termsOfServiceCopyrightContent => 'Alle Rechte an der App, ihrem Design und ihren Inhalten verbleiben beim Entwickler.';

  @override
  String get termsOfServiceNoDistributionTitle => 'Keine Weitergabe';

  @override
  String get termsOfServiceNoDistributionContent => 'Die App darf ohne ausdrückliche Zustimmung nicht kopiert, verändert oder weiterverbreitet werden, soweit dies gesetzlich nicht erlaubt ist.';

  @override
  String get termsOfServiceChanges => 'Änderungen';

  @override
  String get termsOfServiceUpdatesTitle => 'Aktualisierung der Bedingungen';

  @override
  String get termsOfServiceUpdatesContent => 'Die Nutzungsbedingungen können bei neuen Funktionen oder gesetzlichen Änderungen angepasst werden.';

  @override
  String get termsOfServiceFinalProvisions => 'Schlussbestimmungen';

  @override
  String get termsOfServiceApplicableLawTitle => 'Geltendes Recht';

  @override
  String get termsOfServiceApplicableLawContent => 'Es gilt das jeweils anwendbare Recht am Sitz des Anbieters, soweit gesetzlich zulässig.';

  @override
  String get privacyPolicyUserAccountContent => 'Bei Verwendung eines Benutzerkontos können Daten zukünftig mit unterstützten Geräten synchronisiert werden.';

  @override
  String get privacyPolicyRightsTitle => 'Deine Rechte';

  @override
  String get privacyPolicyRightsLabel => 'Datenschutzrechte';

  @override
  String get privacyPolicyRightsContent => 'Du hast das Recht auf Auskunft, Berichtigung, Löschung und Einschränkung der Verarbeitung deiner personenbezogenen Daten im Rahmen der geltenden Datenschutzgesetze.';

  @override
  String get privacyPolicyQuestionsTitle => 'Fragen zum Datenschutz';

  @override
  String get privacyPolicyQuestionsContactTitle => 'Kontakt';

  @override
  String get privacyPolicyQuestionsContactContent => 'Bei Fragen zum Datenschutz kannst du uns über die im Impressum angegebenen Kontaktdaten erreichen.';

  @override
  String get imprint => 'Impressum';

  @override
  String get imprintProviderDetailsTitle => 'Angaben zum Anbieter';

  @override
  String get imprintAppNameLabel => 'App-Name';

  @override
  String get imprintAppNameValue => 'FilaLog';

  @override
  String get imprintDeveloperLabel => 'Inhaber';

  @override
  String get imprintDeveloperValue => 'Robin Pniok';

  @override
  String get imprintAddressLabel => 'Anschrift';

  @override
  String get imprintAddressValue => 'Diebesweg 8b\n58507 Lüdenscheid';

  @override
  String get imprintContactTitle => 'Kontakt';

  @override
  String get imprintEmailLabel => 'E-Mail';

  @override
  String get imprintEmailValue => 'support@filalog.de';

  @override
  String get imprintWebsiteLabel => 'Website';

  @override
  String get imprintWebsiteValue => 'https://filalog.de';

  @override
  String get imprintCompanyInformationTitle => 'Unternehmensinformationen';

  @override
  String get imprintCompanyFormLabel => 'Unternehmensform';

  @override
  String get imprintCompanyFormValue => 'Einzelunternehmen';

  @override
  String get imprintBusinessPurposeLabel => 'Unternehmensgegenstand';

  @override
  String get imprintBusinessPurposeValue => 'Entwicklung und Bereitstellung der Softwareanwendung FilaLog zur Verwaltung von 3D-Druck-Filamenten sowie zugehöriger Funktionen.';

  @override
  String get imprintLegalNotesTitle => 'Rechtliche Hinweise';

  @override
  String get imprintLiabilityLabel => 'Haftung';

  @override
  String get imprintLiabilityContent => 'Weitere Informationen findest du auf der Seite „Haftung“.';

  @override
  String get imprintCopyrightLabel => 'Urheberrecht';

  @override
  String get imprintCopyrightContent => 'Weitere Informationen findest du auf der Seite „Urheberrecht“.';

  @override
  String get premiumSubscription => 'Premium & Abonnement';

  @override
  String get premiumMembershipTitle => 'Premium-Mitgliedschaft';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumContent => 'FilaLog kann sieben Tage kostenlos getestet werden. Anschließend ist für die weitere Nutzung eine Premium-Mitgliedschaft erforderlich.';

  @override
  String get premiumTrialTitle => 'Testphase';

  @override
  String get premiumTrialContent => 'Während der siebentägigen Testphase stehen sämtliche Funktionen uneingeschränkt zur Verfügung.';

  @override
  String get premiumBillingTitle => 'Abrechnung';

  @override
  String get premiumPaymentProcessingTitle => 'Zahlungsabwicklung';

  @override
  String get premiumPaymentProcessingContent => 'Auf Android erfolgt die Zahlungsabwicklung über Google Play. Für die Web-Version erfolgt sie über die offizielle Website mit PayPal.';

  @override
  String get premiumPlatformsTitle => 'Plattformen';

  @override
  String get premiumPlatformsContent => 'Auf Android erfolgt der Abschluss über Google Play. Für die Web-Version kann Premium über die offizielle Website mit PayPal erworben werden.';

  @override
  String get premiumTrialAndPremiumTitle => 'Testphase & Premium';

  @override
  String get premiumSevenDayTrialTitle => '7-Tage-Test';

  @override
  String get premiumSevenDayTrialContent => 'Neue Nutzer können FilaLog sieben Tage kostenlos testen.';

  @override
  String get premiumAfterTrialTitle => 'Nach Ablauf';

  @override
  String get premiumAfterTrialContent => 'Nach Ablauf der Testphase ist eine Premium-Mitgliedschaft erforderlich, um FilaLog weiter nutzen zu können.';

  @override
  String get premiumMembershipTermsTitle => 'Mitgliedschaft';

  @override
  String get premiumDurationTitle => 'Laufzeiten';

  @override
  String get premiumDurationContent => 'Premium wird als monatliche oder jährliche Mitgliedschaft angeboten.';

  @override
  String get premiumCancellationTitle => 'Kündigung';

  @override
  String get premiumCancellationContent => 'Eine Kündigung ist jederzeit zum Ende der jeweiligen Laufzeit möglich.';

  @override
  String get withdrawal => 'Widerrufsbelehrung';

  @override
  String get withdrawalRightTitle => 'Widerrufsrecht';

  @override
  String get withdrawalPeriodTitle => 'Widerrufsfrist';

  @override
  String get withdrawalPeriodContent => 'Verbraucher haben grundsätzlich das Recht, einen Vertrag binnen vierzehn Tagen zu widerrufen.';

  @override
  String get withdrawalReasonTitle => 'Ohne Angabe von Gründen';

  @override
  String get withdrawalReasonContent => 'Der Widerruf kann innerhalb der gesetzlichen Widerrufsfrist ohne Angabe von Gründen erfolgen.';

  @override
  String get withdrawalExerciseTitle => 'Ausübung des Widerrufs';

  @override
  String get withdrawalDeclarationTitle => 'Eindeutige Erklärung';

  @override
  String get withdrawalDeclarationContent => 'Zur Ausübung des Widerrufsrechts ist eine eindeutige Erklärung erforderlich, aus der der Entschluss zum Widerruf des Vertrags hervorgeht.';

  @override
  String get withdrawalDeadlineTitle => 'Wahrung der Frist';

  @override
  String get withdrawalDeadlineContent => 'Zur Wahrung der Widerrufsfrist genügt die rechtzeitige Absendung der Erklärung vor Ablauf der Widerrufsfrist.';

  @override
  String get withdrawalPremiumTitle => 'Premium & digitale Leistungen';

  @override
  String get withdrawalDigitalServiceTitle => 'Digitale Leistung';

  @override
  String get withdrawalDigitalServiceContent => 'Die Premium-Mitgliedschaft ermöglicht den Zugriff auf zusätzliche digitale Funktionen und Leistungen von FilaLog.';

  @override
  String get withdrawalEarlyExpiryTitle => 'Vorzeitiger Beginn der Leistung';

  @override
  String get withdrawalEarlyExpiryContent => 'Ein vorzeitiger Beginn der Bereitstellung digitaler Leistungen oder ein mögliches Erlöschen des Widerrufsrechts richtet sich nach den jeweils geltenden gesetzlichen Voraussetzungen und den beim Vertragsabschluss erteilten Informationen.';

  @override
  String get withdrawalInformationTitle => 'Weitere Informationen';

  @override
  String get withdrawalPurchaseInfoTitle => 'Informationen beim Abschluss';

  @override
  String get withdrawalPurchaseInfoContent => 'Vor Abschluss einer Premium-Mitgliedschaft werden die für den jeweiligen Vertrag gesetzlich erforderlichen Informationen zum Widerrufsrecht und zur Vertragsabwicklung bereitgestellt.';

  @override
  String get consumerInformation => 'Verbraucherinformationen';

  @override
  String get consumerProviderTitle => 'Anbieter';

  @override
  String get consumerResponsibleTitle => 'Verantwortlicher';

  @override
  String get consumerResponsibleContent => 'Die Angaben zum Anbieter befinden sich im Impressum.';

  @override
  String get consumerContactTitle => 'Kontakt';

  @override
  String get consumerContactContent => 'Fragen können jederzeit über die im Impressum angegebenen Kontaktdaten gestellt werden.';

  @override
  String get consumerContractTitle => 'Vertragsinformationen';

  @override
  String get consumerPremiumTitle => 'Premium-Mitgliedschaft';

  @override
  String get consumerPremiumContent => 'Vor Abschluss einer Premium-Mitgliedschaft werden alle wesentlichen Informationen zu Preis, Laufzeit und Zahlungsweise angezeigt.';

  @override
  String get consumerContractConclusionTitle => 'Vertragsschluss';

  @override
  String get consumerContractConclusionContent => 'Der Vertrag kommt erst mit erfolgreichem Abschluss des jeweiligen Kaufvorgangs zustande.';

  @override
  String get consumerSupportTitle => 'Support';

  @override
  String get consumerHelpTitle => 'Hilfe';

  @override
  String get consumerHelpContent => 'Bei Fragen oder Problemen steht der Support über die offiziellen Kontaktmöglichkeiten zur Verfügung.';

  @override
  String get liability => 'Haftung';

  @override
  String get liabilityTitle => 'Haftung';

  @override
  String get liabilityContentTitle => 'Haftung für Inhalte';

  @override
  String get liabilityCareTitle => 'Sorgfalt';

  @override
  String get liabilityCareContent => 'Die Inhalte von FilaLog werden mit Sorgfalt erstellt und regelmäßig überprüft.';

  @override
  String get liabilityNoWarrantyTitle => 'Keine Gewähr';

  @override
  String get liabilityNoWarrantyContent => 'Trotz sorgfältiger Erstellung kann keine Gewähr für die Richtigkeit, Vollständigkeit und Aktualität sämtlicher bereitgestellter Informationen übernommen werden.';

  @override
  String get liabilityExternalContentTitle => 'Externe Inhalte';

  @override
  String get liabilityExternalLinksTitle => 'Links und externe Dienste';

  @override
  String get liabilityExternalLinksContent => 'Für Inhalte externer Websites oder Dienste, auf die innerhalb von FilaLog verwiesen wird, sind die jeweiligen Betreiber verantwortlich.';

  @override
  String get liabilityUsageTitle => 'Hinweis zur Nutzung';

  @override
  String get liabilityGeneralInformationTitle => 'Allgemeine Informationen';

  @override
  String get liabilityGeneralInformationContent => 'Die in FilaLog bereitgestellten Informationen dienen der Unterstützung bei der Verwaltung und Organisation von Filament und 3D-Druck-bezogenen Daten.';

  @override
  String get copyright => 'Urheberrecht';

  @override
  String get copyrightRightsTitle => 'Urheberrechte';

  @override
  String get copyrightAppTitle => 'App';

  @override
  String get copyrightAppContent => 'FilaLog sowie sämtliche Inhalte, Designs und Quelltexte sind urheberrechtlich geschützt.';

  @override
  String get copyrightUsageTitle => 'Nutzung';

  @override
  String get copyrightUsageContent => 'Eine Vervielfältigung, Veröffentlichung oder Weitergabe ist ohne ausdrückliche Zustimmung nicht gestattet.';

  @override
  String get copyrightGraphicsContentTitle => 'Grafiken & Inhalte';

  @override
  String get copyrightOwnContentTitle => 'Eigene Inhalte';

  @override
  String get copyrightOwnContentContent => 'Eigene Grafiken, Texte und Logos unterliegen dem Urheberrecht des Entwicklers.';

  @override
  String get copyrightThirdPartyTitle => 'Drittanbieter';

  @override
  String get copyrightThirdPartyContent => 'Verwendete Inhalte Dritter werden entsprechend ihrer jeweiligen Lizenz eingesetzt.';

  @override
  String get copyrightLicenseNoticeTitle => 'Lizenzhinweis';

  @override
  String get copyrightOpenSourceTitle => 'Open-Source';

  @override
  String get copyrightOpenSourceContent => 'Open-Source-Komponenten werden entsprechend ihrer jeweiligen Lizenz verwendet.';

  @override
  String get imageCredits => 'Bildnachweise';

  @override
  String get imageCreditsGraphicsTitle => 'Verwendete Grafiken';

  @override
  String get imageCreditsOwnGraphicsTitle => 'Eigene Grafiken';

  @override
  String get imageCreditsOwnGraphicsContent => 'Alle selbst erstellten Grafiken, Logos und Illustrationen unterliegen dem Urheberrecht des Entwicklers.';

  @override
  String get imageCreditsAppIconsTitle => 'App-Icons';

  @override
  String get imageCreditsAppIconsContent => 'Verwendete Icons stammen aus den offiziellen Flutter Material Icons.';

  @override
  String get imageCreditsColorsDesignTitle => 'Farben & Design';

  @override
  String get imageCreditsInterfaceTitle => 'Benutzeroberfläche';

  @override
  String get imageCreditsInterfaceContent => 'Das Design von FilaLog wurde eigenständig entwickelt.';

  @override
  String get imageCreditsBrandsTitle => 'Marken';

  @override
  String get imageCreditsBrandsContent => 'Markennamen und Herstellerbezeichnungen bleiben Eigentum ihrer jeweiligen Inhaber.';

  @override
  String get imageCreditsNoticeTitle => 'Hinweis';

  @override
  String get imageCreditsUpdateTitle => 'Aktualisierung';

  @override
  String get imageCreditsUpdateContent => 'Sollten künftig weitere Bilder oder externe Grafiken verwendet werden, werden deren Bildnachweise an dieser Stelle ergänzt.';

  @override
  String get account => 'Konto';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signInFailed => 'Anmeldung fehlgeschlagen.';

  @override
  String get signInSubtitle => 'Mit einem bestehenden Konto anmelden.';

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melde dich mit deinem Benutzerkonto an.';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get resetPasswordSubtitle => 'Gib deine E-Mail-Adresse ein. Wir senden dir einen Link zum Zurücksetzen deines Passworts.';

  @override
  String get sendingResetLink => 'Link wird gesendet...';

  @override
  String get sendResetLink => 'Link senden';

  @override
  String get resetLinkSent => 'Link gesendet';

  @override
  String get resetPasswordSent => 'Wir haben dir eine E-Mail zum Zurücksetzen deines Passworts gesendet.';

  @override
  String get resetPasswordFailed => 'Das Zurücksetzen des Passworts ist fehlgeschlagen.';

  @override
  String get signingIn => 'Anmeldung...';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createAccountSubtitle => 'Ein neues Benutzerkonto erstellen.';

  @override
  String get registerAppBarTitle => 'Konto erstellen';

  @override
  String get registerTitle => 'Neues Benutzerkonto';

  @override
  String get registerSubtitle => 'Erstelle dein persönliches Benutzerkonto.';

  @override
  String get repeatPassword => 'Passwort wiederholen';

  @override
  String get registerButton => 'Konto erstellen';

  @override
  String get or => 'oder';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get registrationFailed => 'Registrierung fehlgeschlagen.';

  @override
  String get emailAlreadyInUse => 'Diese E-Mail-Adresse wird bereits verwendet.';

  @override
  String get weakPassword => 'Das Passwort ist zu schwach.';

  @override
  String get invalidEmail => 'Die E-Mail-Adresse ist ungültig.';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutSubtitle => 'Vom aktuellen Konto abmelden.';

  @override
  String signOutFailed(String error) {
    return 'Abmelden fehlgeschlagen: $error';
  }

  @override
  String get about => 'Über';

  @override
  String get appName => 'FilaLog';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get developer => 'Entwickler';

  @override
  String get technology => 'Technologie';

  @override
  String get website => 'Website';

  @override
  String get thankYou => 'Vielen Dank';

  @override
  String get thankYouMessage => 'Vielen Dank, dass du FilaLog verwendest.';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get feedbackMailGreeting => 'Hallo,\n\n';

  @override
  String get feedbackMailDescription => 'ich habe folgendes Feedback oder einen Verbesserungsvorschlag:\n\n';

  @override
  String get errorReportMailGreeting => 'Hallo,\n\n';

  @override
  String get errorReportMailDescription => 'ich habe folgenden Fehler gefunden.\n\n';

  @override
  String get appVersionLabel => 'App-Version:';

  @override
  String get deviceLabel => 'Gerät:';

  @override
  String get browserLabel => 'Browser (bei Web):';

  @override
  String get descriptionLabel => 'Beschreibung:';

  @override
  String get stepsToReproduceLabel => 'Schritte zum Nachstellen:';

  @override
  String get supportMailGreeting => 'Hallo,\n\n';

  @override
  String get supportMailDescription => 'ich benötige Hilfe bei folgendem Thema.\n\n';

  @override
  String get thankYouMail => 'Vielen Dank.';

  @override
  String get details => 'Details';

  @override
  String get totalInventory => 'Gesamtbestand';

  @override
  String get inventoryValue => 'Lagerwert';

  @override
  String get noFilamentsAvailable => 'Keine Filamente vorhanden';

  @override
  String get printJobs => 'Druckjobs';

  @override
  String get statisticsPrints => 'Drucke';

  @override
  String get statisticsMaterials => 'Materialien';

  @override
  String get statisticsConsumption => 'Verbrauch';

  @override
  String get printed => 'Gedruckt';

  @override
  String get totalPrintCosts => 'Druckkosten Gesamt';

  @override
  String get averageCostPerPrint => 'Ø Kosten pro Druck';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get calculatePrint => 'Druck berechnen';

  @override
  String get newManufacturer => 'Neuer Hersteller';

  @override
  String get manufacturerName => 'Herstellername';

  @override
  String get newMaterial => 'Neues Material';

  @override
  String get materialName => 'Materialname';

  @override
  String get newVariant => 'Neue Variante';

  @override
  String get variantName => 'Variantenname';

  @override
  String get newColor => 'Neue Farbe';

  @override
  String get colorName => 'Farbname';

  @override
  String get searchManufacturer => 'Hersteller suchen...';

  @override
  String get searchMaterial => 'Material suchen...';

  @override
  String get searchVariant => 'Variante suchen...';

  @override
  String get searchColor => 'Farbe suchen...';

  @override
  String get add => 'Hinzufügen';

  @override
  String get fillAllRequiredFields => 'Bitte alle Pflichtfelder ausfüllen.';

  @override
  String get temperatures => 'Temperaturen';

  @override
  String get inventoryAndCost => 'Bestand & Kosten';

  @override
  String get spoolWeight => 'Spulengewicht';

  @override
  String get custom => 'Benutzerdefiniert...';

  @override
  String get weightInGrams => 'Gewicht in g';

  @override
  String get printSettings => 'Druckeinstellungen';

  @override
  String get printSaved => 'Druck gespeichert';

  @override
  String get addPrinter => 'Drucker hinzufügen';

  @override
  String get editPrinter => 'Drucker bearbeiten';

  @override
  String get printerName => 'Druckername';

  @override
  String get averageWatt => 'Durchschnittliche Leistung';

  @override
  String get enterPrinterNameAndWatt => 'Bitte Druckername und Leistung eingeben.';

  @override
  String get managePrinters => 'Drucker verwalten';

  @override
  String get noCustomPrinters => 'Keine eigenen Drucker vorhanden.';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get deletePrinter => 'Drucker löschen';

  @override
  String confirmDeletePrinter(String printerName) {
    return 'Drucker $printerName wirklich löschen?';
  }

  @override
  String get searchPrinter => 'Drucker suchen...';

  @override
  String get calculateCosts => 'Kosten berechnen';

  @override
  String get project => 'Projekt';

  @override
  String get projectName => 'Projektname';

  @override
  String get date => 'Datum';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get selectFilament => 'Filament auswählen';

  @override
  String get selectPrinter => 'Drucker auswählen';

  @override
  String get calculation => 'Berechnung';

  @override
  String get watt => 'Watt';

  @override
  String get objectWeight => 'Objektgewicht';

  @override
  String get printTimeMinutes => 'Druckzeit in Minuten';

  @override
  String get spoolPrice => 'Spulenpreis';

  @override
  String get electricityCostPerKwh => 'Stromkosten pro kWh';

  @override
  String get subtractFromStock => 'Vom Bestand abziehen';

  @override
  String get filamentCost => 'Filamentkosten';

  @override
  String get electricityCost => 'Stromkosten';

  @override
  String get totalCost => 'Gesamtkosten';

  @override
  String get usageByMaterial => 'Verbrauch nach Material';

  @override
  String get usageByMonth => 'Verbrauch nach Monat';

  @override
  String get costsByMaterial => 'Kosten nach Material';

  @override
  String get costsByMonth => 'Kosten nach Monat';

  @override
  String get overallOverview => 'Gesamtübersicht';

  @override
  String get printTime => 'Druckzeit';

  @override
  String get costs => 'Kosten';

  @override
  String get welcomeTrialTitle => '7 Tage kostenlos testen';

  @override
  String get welcomeTrialDescription => 'Teste FilaLog 7 Tage kostenlos und entscheide danach, ob du Premium nutzen möchtest.';

  @override
  String get welcomePerMonth => 'pro Monat';

  @override
  String get welcomePerYear => 'pro Jahr';

  @override
  String get welcomeCheaper => 'Günstiger';

  @override
  String get welcomeTrialFooter => 'Nach Ablauf der Testphase kannst du entscheiden, ob du FilaLog Premium weiter nutzen möchtest.';

  @override
  String get averagePerPrint => 'Durchschnitt pro Druck';

  @override
  String get topMaterial => 'Top-Material';

  @override
  String get usageByMaterialWithUnit => 'Verbrauch nach Material (g)';

  @override
  String get usageByMonthWithUnit => 'Verbrauch nach Monat (g)';

  @override
  String get costsByMaterialWithUnit => 'Kosten nach Material (€)';

  @override
  String get costsByMonthWithUnit => 'Kosten nach Monat (€)';

  @override
  String get noPrintData => 'Keine Druckdaten vorhanden.';

  @override
  String get sortByDateNewest => 'Datum (neu → alt)';

  @override
  String get sortByDateOldest => 'Datum (alt → neu)';

  @override
  String get sortByCost => 'Kosten';

  @override
  String get sortByWeight => 'Gewicht';

  @override
  String get sortByProjectName => 'Projektname';

  @override
  String get all => 'Alle';

  @override
  String get today => 'Heute';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get thisYear => 'Dieses Jahr';

  @override
  String get printHistory => 'Druckhistorie';

  @override
  String get searchProject => 'Projekt suchen...';

  @override
  String get resetFilters => 'Filter zurücksetzen';

  @override
  String get noPrintsAvailable => 'Keine Druckaufträge vorhanden.';

  @override
  String historyJobs(int count) {
    return '$count Auftrag(e)';
  }

  @override
  String get guestMode => 'Gastmodus';

  @override
  String get guestModeDescription => 'Testen Sie FilaLog 7 Tage kostenlos und ohne Registrierung.';

  @override
  String get guestModeDataInfo => 'Alle während dieser Zeit erstellten Daten bleiben erhalten und können später in ein Benutzerkonto übernommen werden.';

  @override
  String get startAsGuest => 'Als Gast starten';

  @override
  String get login => 'Anmelden';

  @override
  String get loginDescription => 'Melden Sie sich mit Ihrem bestehenden Benutzerkonto an.';

  @override
  String get loginDataInfo => 'Ihre Daten werden automatisch synchronisiert und stehen Ihnen auf Android und in der Web-Version zur Verfügung.';

  @override
  String get registerAccount => 'Konto erstellen';

  @override
  String get registerAccountDescription => 'Erstellen Sie ein neues Benutzerkonto und sichern Sie Ihre Daten dauerhaft.';

  @override
  String get registerAccountDataInfo => 'Ihre vorhandenen Daten aus dem Gastmodus werden automatisch übernommen und stehen Ihnen anschließend auf allen unterstützten Geräten zur Verfügung.';

  @override
  String get accountCreated => 'Konto erstellt';

  @override
  String get accountSuccessfullyCreated => 'Konto erfolgreich erstellt';

  @override
  String get accountCreatedDescription => 'Dein Benutzerkonto wurde erfolgreich erstellt.';

  @override
  String get verifyEmailTitle => 'E-Mail bestätigen';

  @override
  String get verifyEmailAlmostDone => 'Fast geschafft';

  @override
  String get verifyEmailInstructions => 'Wir haben dir eine Bestätigungs-E-Mail gesendet.\n\nBitte öffne den Link in der E-Mail, um dein Benutzerkonto zu aktivieren.';

  @override
  String get verifyEmailNotVerified => 'E-Mail wurde noch nicht bestätigt.';

  @override
  String get verifyEmailCheckFailed => 'Die E-Mail-Bestätigung konnte nicht überprüft werden. Bitte versuche es erneut.';

  @override
  String get verifyEmailResent => 'Bestätigungs-E-Mail wurde erneut gesendet.';

  @override
  String get verifyEmailSendFailed => 'Die Bestätigungs-E-Mail konnte nicht gesendet werden.';

  @override
  String get verifyEmailChecking => 'Wird geprüft...';

  @override
  String get verifyEmailCheckAgain => 'Erneut prüfen';

  @override
  String get verifyEmailSending => 'Wird gesendet...';

  @override
  String get verifyEmailResend => 'E-Mail erneut senden';

  @override
  String get accountCreatedEmailVerificationInfo => 'Bitte bestätige jetzt deine E-Mail-Adresse. Anschließend kannst du dich anmelden und FilaLog nutzen.';

  @override
  String get emailConfirmed => 'E-Mail bestätigt';

  @override
  String get emailRequired => 'Bitte gib deine E-Mail-Adresse ein.';

  @override
  String get emailInvalid => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get passwordRequired => 'Bitte gib dein Passwort ein.';

  @override
  String get passwordTooShort => 'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get confirmPasswordRequired => 'Bitte wiederhole dein Passwort.';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get back => 'Zurück';

  @override
  String get trialExpiredTitle => 'Deine Testphase ist beendet';

  @override
  String get trialExpiredSubtitle => 'Du hast FilaLog 7 Tage lang kostenlos getestet.';

  @override
  String get trialExpiredLoginHint => 'Melde dich mit deinem FilaLog-Konto an, um Premium freizuschalten.';

  @override
  String get trialExpiredPremiumHint => 'Wähle jetzt dein Premium-Abonnement und nutze weiterhin alle Funktionen ohne Einschränkungen.';

  @override
  String get trialExpiredLoginButton => 'Anmelden';

  @override
  String get trialExpiredRegisterButton => 'Konto erstellen';

  @override
  String get trialExpiredLoginRequiredInfo => 'Ein PayPal-Abonnement kann erst nach der Anmeldung eindeutig deinem FilaLog-Konto zugeordnet werden.';

  @override
  String get trialExpiredMonthlyTitle => 'Monatlich';

  @override
  String get trialExpiredMonthlyPrice => '2,49 €';

  @override
  String get trialExpiredMonthlyPeriod => 'pro Monat';

  @override
  String get trialExpiredYearlyTitle => 'Jährlich';

  @override
  String get trialExpiredYearlyPrice => '19,99 €';

  @override
  String get trialExpiredYearlyPeriod => 'pro Jahr';

  @override
  String get trialExpiredYearlyBadge => 'Günstiger';

  @override
  String get trialExpiredPaypalOpened => 'PayPal wurde geöffnet. Schließe dort das Abonnement ab.';

  @override
  String get trialExpiredPaypalOpenedInfo => 'PayPal wurde geöffnet. Schließe dort das Abonnement ab. Die Freischaltung erfolgt anschließend automatisch.';

  @override
  String get trialExpiredPaypalStartError => 'Das PayPal-Abonnement konnte nicht gestartet werden.';

  @override
  String get trialExpiredPaypalManagementInfo => 'Die Zahlung und Verwaltung des Abonnements erfolgt über PayPal.';
}
