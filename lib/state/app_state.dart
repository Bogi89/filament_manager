import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/filament.dart';
import '../models/filament_sort_mode.dart';
import '../models/print_job.dart';

import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../services/filament_catalog_service.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  List<Filament> filaments = [];
  List<PrintJob> jobs = [];

  Locale locale = const Locale('de');
  ThemeMode themeMode = ThemeMode.light;

  double warningPercent = 20;

  FilamentSortMode sortMode =
      FilamentSortMode.material;

  bool isInitialized = false;

  StreamSubscription<User?>? _authSubscription;

  bool _isSyncing = false;
  bool _isDisposed = false;

  AppState() {
    init();
  }

  /// ================= INIT =================

  Future<void> init() async {
    await loadSettings();

    await FilamentCatalogService.loadCatalog();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        await _handleAuthStateChanged(user);
      },
    );

    await _loadDataForCurrentUser();

    if (_isDisposed) {
      return;
    }

    isInitialized = true;

    notifyListeners();
  }

  /// ================= AUTH / DATENSYNC =================

  Future<void> _handleAuthStateChanged(
    User? user,
  ) async {
    if (!isInitialized || _isDisposed) {
      return;
    }

    await _loadDataForCurrentUser();

    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }

  Future<void> _loadDataForCurrentUser() async {
    if (_isSyncing || _isDisposed) {
      return;
    }

    _isSyncing = true;

    try {
      final user =
          FirebaseAuth.instance.currentUser;

      /// ======================
      /// GASTMODUS
      /// ======================

      if (user == null) {
        await _loadLocalData();
        return;
      }

      /// ======================
      /// ANGEMELDETER BENUTZER
      /// ======================

      final cloudData =
          await FirestoreService.loadData();

      if (cloudData != null) {
        filaments = cloudData.filaments;
        jobs = cloudData.jobs;

        await StorageService.clearLocalData();

        return;
      }

      final localFilaments =
          await StorageService.loadFilaments();

      final localJobs =
          await StorageService.loadJobs();

      filaments = localFilaments;
      jobs = localJobs;

      final hasLocalData =
          localFilaments.isNotEmpty ||
          localJobs.isNotEmpty;

      if (!hasLocalData) {
        return;
      }

      await FirestoreService.saveData(
        filaments: filaments,
        jobs: jobs,
      );

      await StorageService.clearLocalData();
    } catch (_) {
      if (FirebaseAuth.instance.currentUser == null) {
        await _loadLocalData();
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _loadLocalData() async {
    filaments =
        await StorageService.loadFilaments();

    jobs =
        await StorageService.loadJobs();
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

  /// ================= DATENSPEICHERUNG =================

  Future<void> saveData() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirestoreService.saveData(
        filaments: filaments,
        jobs: jobs,
      );

      return;
    }

    await StorageService.saveFilaments(
      filaments,
    );

    await StorageService.saveJobs(
      jobs,
    );
  }

  /// ================= SETTINGS =================

  void setLocale(
    Locale newLocale,
  ) async {
    locale = newLocale;

    await SettingsService.saveLocale(
      newLocale,
    );

    notifyListeners();
  }

  void setThemeMode(
    ThemeMode newTheme,
  ) async {
    themeMode = newTheme;

    await SettingsService.saveThemeMode(
      newTheme,
    );

    notifyListeners();
  }

  void setWarningPercent(
    double value,
  ) async {
    warningPercent = value;

    await SettingsService.saveWarningPercent(
      value,
    );

    notifyListeners();
  }

  void setSortMode(
    FilamentSortMode mode,
  ) async {
    sortMode = mode;

    await SettingsService.saveSortMode(
      mode,
    );

    notifyListeners();
  }

  /// ================= WARNLOGIK =================

  double getRemainingPercent(
    Filament f,
  ) {
    if (f.totalWeight == 0) {
      return 0;
    }

    return
        (f.remainingWeight /
            f.totalWeight) *
        100;
  }

  bool isCritical(
    Filament f,
  ) {
    return getRemainingPercent(f) <=
        warningPercent;
  }

  int get criticalCount {
    return filaments
        .where(
          (f) => isCritical(f),
        )
        .length;
  }

  /// ================= FILAMENT =================

  void addFilament(
    Filament filament,
  ) {
    final existingValidNames =
        filament.colorNames
            .map(
              (name) => name.trim(),
            )
            .where(
              (name) =>
                  name.isNotEmpty &&
                  name.toLowerCase() !=
                      'unknown',
            )
            .toList();

    if (existingValidNames.isNotEmpty) {
      filament.colorNames =
          existingValidNames
              .toSet()
              .toList();
    } else {
      final List<String> detectedNames =
          [];

      for (final color
          in filament.colors) {
        final hex = color
            .toARGB32()
            .toRadixString(16)
            .substring(2)
            .toUpperCase();

        final name =
            FilamentCatalogService
                .findColorNameByHex(
          hex,
        );

        if (!detectedNames.contains(
          name,
        )) {
          detectedNames.add(name);
        }
      }

      final validNames =
          detectedNames
              .where(
                (name) =>
                    name
                        .trim()
                        .isNotEmpty &&
                    name.toLowerCase() !=
                        'unknown',
              )
              .toList();

      filament.colorNames =
          validNames.isNotEmpty
              ? validNames
                  .toSet()
                  .toList()
              : ['Unknown'];
    }

    filaments.add(filament);

    saveData();

    notifyListeners();
  }

  void removeFilament(
    Filament filament,
  ) {
    filaments.removeWhere(
      (f) => f.id == filament.id,
    );

    saveData();

    notifyListeners();
  }

  void updateFilament(
    Filament updated,
  ) {
    final index =
        filaments.indexWhere(
      (f) => f.id == updated.id,
    );

    if (index != -1) {
      filaments[index] = updated;
    }

    saveData();

    notifyListeners();
  }

  /// ================= PRINT JOBS =================

  void addJob(
    PrintJob job,
  ) {
    jobs.add(job);

    saveData();

    notifyListeners();
  }

  /// ================= DISPOSE =================

  @override
  void dispose() {
    _isDisposed = true;

    _authSubscription?.cancel();

    super.dispose();
  }
}