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
  ThemeMode themeMode = ThemeMode.system;

  double warningPercent = 20;

  FilamentSortMode sortMode = FilamentSortMode.material;

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

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      await _handleAuthStateChanged(user);
    });

    await _loadDataForCurrentUser();

    if (_isDisposed) {
      return;
    }

    isInitialized = true;

    notifyListeners();
  }

  /// ================= AUTH / DATENSYNC =================

  Future<void> _handleAuthStateChanged(User? user) async {
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
      final user = FirebaseAuth.instance.currentUser;

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

      /// Lokale Daten können Gastdaten enthalten, die vor der
      /// Anmeldung erstellt wurden.
      final localFilaments = await StorageService.loadFilaments();
      final localJobs = await StorageService.loadJobs();

      final hasLocalData = localFilaments.isNotEmpty || localJobs.isNotEmpty;

      /// Cloud-Daten IMMER zuerst laden, bevor lokale Daten
      /// in das Benutzerkonto übernommen werden.
      ///
      /// Dadurch kann ein bestehender Cloud-Bestand nicht mehr
      /// versehentlich durch lokale Gastdaten überschrieben werden.
      final cloudData = await FirestoreService.loadData();

      final hasCloudAppData =
          cloudData != null &&
          (cloudData.filaments.isNotEmpty || cloudData.jobs.isNotEmpty);

      /// ======================
      /// FALL 1:
      /// Keine lokalen Gastdaten
      /// ======================

      if (!hasLocalData) {
        if (cloudData != null) {
          filaments = cloudData.filaments;
          jobs = cloudData.jobs;
        } else {
          filaments = [];
          jobs = [];
        }

        return;
      }

      /// ======================
      /// FALL 2:
      /// Lokale Gastdaten vorhanden,
      /// aber keine App-Daten in der Cloud
      /// ======================

      if (!hasCloudAppData) {
        filaments = List<Filament>.from(localFilaments);
        jobs = List<PrintJob>.from(localJobs);

        await FirestoreService.saveData(filaments: filaments, jobs: jobs);

        /// Lokale Daten dürfen erst entfernt werden,
        /// nachdem das Speichern in Firestore erfolgreich war.
        await StorageService.clearLocalData();

        return;
      }

      /// ======================
      /// FALL 3:
      /// Lokale UND Cloud-Daten vorhanden
      ///
      /// Beide Datenbestände werden zusammengeführt.
      /// Bestehende Cloud-Daten werden niemals einfach
      /// durch lokale Gastdaten ersetzt.
      /// ======================

      final mergedFilaments = _mergeFilaments(
        cloudData.filaments,
        localFilaments,
      );

      final mergedJobs = _mergeJobs(cloudData.jobs, localJobs);

      /// Zuerst den vollständigen zusammengeführten Bestand
      /// erfolgreich in Firestore speichern.
      await FirestoreService.saveData(
        filaments: mergedFilaments,
        jobs: mergedJobs,
      );

      /// Erst NACH erfolgreichem Cloud-Speichern werden
      /// die lokalen Gastdaten entfernt.
      await StorageService.clearLocalData();

      filaments = mergedFilaments;
      jobs = mergedJobs;
    } catch (_) {
      /// Falls während des Vorgangs keine Anmeldung mehr
      /// vorhanden ist, werden weiterhin die lokalen Daten geladen.
      ///
      /// Wichtig:
      /// Bei einem Cloud-Fehler werden lokale Gastdaten nicht
      /// gelöscht, weil clearLocalData() nur nach einem
      /// erfolgreichen Cloud-Speichervorgang ausgeführt wird.
      if (FirebaseAuth.instance.currentUser == null) {
        await _loadLocalData();
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Führt Cloud- und lokale Filamente anhand ihrer eindeutigen
  /// Filament-ID zusammen.
  ///
  /// Cloud-Daten bilden die Grundlage.
  /// Ein lokales Filament mit einer bisher unbekannten ID
  /// wird ergänzt.
  List<Filament> _mergeFilaments(
    List<Filament> cloudFilaments,
    List<Filament> localFilaments,
  ) {
    final merged = <Filament>[...cloudFilaments];

    final existingIds = cloudFilaments.map((filament) => filament.id).toSet();

    for (final localFilament in localFilaments) {
      if (!existingIds.contains(localFilament.id)) {
        merged.add(localFilament);
        existingIds.add(localFilament.id);
      }
    }

    return merged;
  }

  /// Führt Cloud- und lokale Druckjobs zusammen.
  ///
  /// PrintJob besitzt aktuell keine eigene ID.
  /// Deshalb wird aus allen gespeicherten Eigenschaften
  /// ein stabiler Vergleichsschlüssel erzeugt.
  ///
  /// Ein vollständig identischer Job wird dadurch nicht
  /// doppelt übernommen. Unterschiedliche Druckjobs bleiben
  /// erhalten.
  List<PrintJob> _mergeJobs(
    List<PrintJob> cloudJobs,
    List<PrintJob> localJobs,
  ) {
    final merged = <PrintJob>[...cloudJobs];

    final existingKeys = cloudJobs.map(_createPrintJobKey).toSet();

    for (final localJob in localJobs) {
      final key = _createPrintJobKey(localJob);

      if (!existingKeys.contains(key)) {
        merged.add(localJob);
        existingKeys.add(key);
      }
    }

    return merged;
  }

  String _createPrintJobKey(PrintJob job) {
    return [
      job.projectName,
      job.filamentBrand,
      job.material,
      job.variant,
      job.color.toARGB32().toString(),
      job.weightUsed.toString(),
      job.printHours.toString(),
      job.totalCost.toString(),
      job.date.toIso8601String(),
    ].join('|');
  }

  Future<void> _loadLocalData() async {
    filaments = await StorageService.loadFilaments();

    jobs = await StorageService.loadJobs();
  }

  /// ================= SETTINGS =================

  Future<void> loadSettings() async {
    final settings = await SettingsService.loadSettings();

    themeMode = settings['themeMode'];

    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.system;
      await SettingsService.saveThemeMode(ThemeMode.system);
    }

    locale = settings['locale'];

    warningPercent = settings['warningPercent'];

    sortMode = settings['sortMode'];
  }

  /// ================= DATENSPEICHERUNG =================

  Future<void> saveData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirestoreService.saveData(filaments: filaments, jobs: jobs);

      return;
    }

    await StorageService.saveFilaments(filaments);

    await StorageService.saveJobs(jobs);
  }

  /// ================= SETTINGS =================

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

  void setSortMode(FilamentSortMode mode) async {
    sortMode = mode;

    await SettingsService.saveSortMode(mode);

    notifyListeners();
  }

  /// ================= WARNLOGIK =================

  double getRemainingPercent(Filament f) {
    if (f.totalWeight == 0) {
      return 0;
    }

    return (f.remainingWeight / f.totalWeight) * 100;
  }

  bool isCritical(Filament f) {
    return getRemainingPercent(f) <= warningPercent;
  }

  int get criticalCount {
    return filaments.where((f) => isCritical(f)).length;
  }

  /// ================= FILAMENT =================

  void addFilament(Filament filament) {
    final existingValidNames = filament.colorNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty && name.toLowerCase() != 'unknown')
        .toList();

    if (existingValidNames.isNotEmpty) {
      filament.colorNames = existingValidNames.toSet().toList();
    } else {
      final List<String> detectedNames = [];

      for (final color in filament.colors) {
        final hex = color
            .toARGB32()
            .toRadixString(16)
            .substring(2)
            .toUpperCase();

        final name = FilamentCatalogService.findColorNameByHex(hex);

        if (!detectedNames.contains(name)) {
          detectedNames.add(name);
        }
      }

      final validNames = detectedNames
          .where(
            (name) => name.trim().isNotEmpty && name.toLowerCase() != 'unknown',
          )
          .toList();

      filament.colorNames = validNames.isNotEmpty
          ? validNames.toSet().toList()
          : ['Unknown'];
    }

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

  /// ================= PRINT JOBS =================

  void addJob(PrintJob job) {
    jobs.add(job);

    saveData();

    notifyListeners();
  }

  void removeJob(PrintJob job) {
    jobs.remove(job);

    saveData();

    notifyListeners();
  }

  bool updateJob(PrintJob oldJob, PrintJob updatedJob) {
    final index = jobs.indexOf(oldJob);

    if (index == -1) {
      return false;
    }

    final filamentId = oldJob.filamentId;
    final weightDifference = updatedJob.weightUsed - oldJob.weightUsed;

    if (filamentId != null && weightDifference != 0) {
      final filamentIndex = filaments.indexWhere(
        (filament) => filament.id == filamentId,
      );

      if (filamentIndex != -1) {
        final filament = filaments[filamentIndex];

        if (weightDifference > 0) {
          if (filament.remainingWeight < weightDifference) {
            return false;
          }

          double remainingToSubtract = weightDifference;

          for (final spool in filament.spools) {
            if (remainingToSubtract <= 0) {
              break;
            }

            if (spool.weight >= remainingToSubtract) {
              spool.weight -= remainingToSubtract;
              remainingToSubtract = 0;
            } else {
              remainingToSubtract -= spool.weight;
              spool.weight = 0;
            }
          }
        } else {
          final weightToRestore = -weightDifference;

          if (filament.spools.isNotEmpty) {
            filament.spools.first.weight += weightToRestore;
          }
        }

        filament.remainingWeight = filament.spools.fold(
          0.0,
          (sum, spool) => sum + spool.weight,
        );
      }
    }

    jobs[index] = updatedJob;

    saveData();

    notifyListeners();

    return true;
  }

  @override
  void dispose() {
    _isDisposed = true;

    _authSubscription?.cancel();

    super.dispose();
  }
}
