import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../models/print_job.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {

  List<Filament> filaments = [];
  List<PrintJob> jobs = [];

  Locale locale = const Locale('de');
  ThemeMode themeMode = ThemeMode.light;

  double warningPercent = 20;

  bool isInitialized = false;

  AppState() {
    init();
  }

  Future<void> init() async {

    await loadSettings();

    filaments = await StorageService.loadFilaments();
    jobs = await StorageService.loadJobs();

    isInitialized = true;

    notifyListeners();
  }

  /// SETTINGS

  Future<void> loadSettings() async {

    final settings = await SettingsService.loadSettings();

    themeMode = settings['themeMode'];
    locale = settings['locale'];
    warningPercent = settings['warningPercent'];
  }

  Future<void> saveData() async {

    await StorageService.saveFilaments(filaments);
    await StorageService.saveJobs(jobs);
  }

  void setLocale(Locale newLocale) async {

    locale = newLocale;

    await SettingsService.saveLocale(newLocale);

    notifyListeners();
  }

  void setThemeMode(ThemeMode newTheme) async {

    themeMode = newTheme;

    await SettingsService.saveThemeMode(newTheme);

    notifyListeners();
  }

  void setWarningPercent(double value) async {

    warningPercent = value;

    await SettingsService.saveWarningPercent(value);

    notifyListeners();
  }

  /// WARNLOGIK

  double getRemainingPercent(Filament f) {

    if (f.totalWeight == 0) return 0;

    return (f.remainingWeight / f.totalWeight) * 100;
  }

  bool isCritical(Filament f) {

    return getRemainingPercent(f) <= warningPercent;
  }

  int get criticalCount {

    return filaments.where((f) => isCritical(f)).length;
  }

  /// FILAMENT

  void addFilament(Filament filament) {

    filaments.add(filament);

    saveData();

    notifyListeners();
  }

  void removeFilament(Filament filament) {

    filaments.removeWhere((f) => f.id == filament.id);

    saveData();

    notifyListeners();
  }

  void updateFilament(Filament updated) {

    final index = filaments.indexWhere((f) => f.id == updated.id);

    if (index != -1) {
      filaments[index] = updated;
    }

    saveData();

    notifyListeners();
  }

  /// PRINT JOBS

  void addJob(PrintJob job) {

    jobs.add(job);

    saveData();

    notifyListeners();
  }
}