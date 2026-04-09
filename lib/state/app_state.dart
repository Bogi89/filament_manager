import 'package:flutter/material.dart';

import '../models/filament.dart';
import '../models/print_job.dart';

import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../services/filament_catalog_service.dart';

class AppState extends ChangeNotifier {

  List<Filament> filaments = [];
  List<PrintJob> jobs = [];

  Locale locale = const Locale('de');
  ThemeMode themeMode = ThemeMode.light;

  double warningPercent = 20;

  String sortMode = "Material";

  bool isInitialized = false;

  AppState() {
    init();
  }

  /// ================= INIT =================

  Future<void> init() async {

    await loadSettings();

    await FilamentCatalogService.loadCatalog();

    filaments =
        await StorageService.loadFilaments();

    jobs =
        await StorageService.loadJobs();

    /// 🔥 Alte Filamente reparieren
    for (var f in filaments) {

      List<String> detectedNames = [];

      for (var c in f.colors) {

        final hex =
            c.value
                .toRadixString(16)
                .substring(2);

        final name =
            FilamentCatalogService
                .findColorNameByHex(hex);

        if (!detectedNames.contains(name)) {

          detectedNames.add(name);

        }

      }

      /// 🔥 WICHTIG: Wenn ein echter Name existiert → nur diesen nehmen
      final validNames =
          detectedNames
              .where((n) => n != "Unknown")
              .toList();

      if (validNames.isNotEmpty) {

        /// Wenn mehrere gleiche → zusammenfassen
        f.colorNames =
            validNames
                .toSet()
                .toList();

      } else {

        f.colorNames = ["Unknown"];

      }

    }

    await saveData();

    isInitialized = true;

    notifyListeners();
  }

  /// ================= SETTINGS =================

  Future<void> loadSettings() async {

    final settings =
        await SettingsService.loadSettings();

    themeMode =
        settings['themeMode'];

    locale =
        settings['locale'];

    warningPercent =
        settings['warningPercent'];

    sortMode =
        settings['sortMode'];
  }

  Future<void> saveData() async {

    await StorageService
        .saveFilaments(filaments);

    await StorageService
        .saveJobs(jobs);
  }

  void setLocale(Locale newLocale) async {

    locale = newLocale;

    await SettingsService
        .saveLocale(newLocale);

    notifyListeners();
  }

  void setThemeMode(ThemeMode newTheme) async {

    themeMode = newTheme;

    await SettingsService
        .saveThemeMode(newTheme);

    notifyListeners();
  }

  void setWarningPercent(double value) async {

    warningPercent = value;

    await SettingsService
        .saveWarningPercent(value);

    notifyListeners();
  }

  void setSortMode(String mode) async {

    sortMode = mode;

    await SettingsService
        .saveSortMode(mode);

    notifyListeners();
  }

  /// ================= WARNLOGIK =================

  double getRemainingPercent(Filament f) {

    if (f.totalWeight == 0) return 0;

    return
        (f.remainingWeight / f.totalWeight) * 100;
  }

  bool isCritical(Filament f) {

    return
        getRemainingPercent(f)
        <= warningPercent;
  }

  int get criticalCount {

    return filaments
        .where((f) => isCritical(f))
        .length;
  }

  /// ================= FILAMENT =================

  void addFilament(Filament filament) {

    List<String> detectedNames = [];

    for (var c in filament.colors) {

      final hex =
          c.value
              .toRadixString(16)
              .substring(2);

      final name =
          FilamentCatalogService
              .findColorNameByHex(hex);

      if (!detectedNames.contains(name)) {

        detectedNames.add(name);

      }

    }

    final validNames =
        detectedNames
            .where((n) => n != "Unknown")
            .toList();

    if (validNames.isNotEmpty) {

      filament.colorNames =
          validNames
              .toSet()
              .toList();

    } else {

      filament.colorNames =
          ["Unknown"];

    }

    filaments.add(filament);

    saveData();

    notifyListeners();
  }

  void removeFilament(Filament filament) {

    filaments.removeWhere(
        (f) => f.id == filament.id);

    saveData();

    notifyListeners();
  }

  void updateFilament(Filament updated) {

    final index =
        filaments.indexWhere(
            (f) => f.id == updated.id);

    if (index != -1) {

      filaments[index] = updated;

    }

    saveData();

    notifyListeners();
  }

  /// ================= PRINT JOBS =================

  void addJob(PrintJob job) {

    jobs.add(job);

    saveData();

    notifyListeners();
  }

}