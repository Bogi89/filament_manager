import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/filament.dart';
import '../models/print_job.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _appDataCollection = 'appData';
  static const String _mainDocument = 'main';

  static User? get currentUser => _auth.currentUser;

  static DocumentReference<Map<String, dynamic>>? get _dataReference {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(_appDataCollection)
        .doc(_mainDocument);
  }

  static bool get isSignedIn => _auth.currentUser != null;

  static Future<UserAccessStatus?> loadUserAccessStatus() async {
    final reference = _dataReference;
    if (reference == null) return null;
    final snapshot = await reference.get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    final trialStartValue = data['trialStart'];
    DateTime? trialStart;
    if (trialStartValue is String) {
      trialStart = DateTime.tryParse(trialStartValue);
    }
    return UserAccessStatus(
      trialStart: trialStart,
      trialUsed: data['trialUsed'] == true,
      premiumActive: data['premiumActive'] == true,
      manualPremium: data['manualPremium'] == true,
    );
  }

  static Stream<UserAccessStatus?> watchUserAccessStatus() {
    final reference = _dataReference;
    if (reference == null) return Stream<UserAccessStatus?>.value(null);
    return reference.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      final trialStartValue = data['trialStart'];
      DateTime? trialStart;
      if (trialStartValue is String) {
        trialStart = DateTime.tryParse(trialStartValue);
      }
      return UserAccessStatus(
        trialStart: trialStart,
        trialUsed: data['trialUsed'] == true,
        premiumActive: data['premiumActive'] == true,
        manualPremium: data['manualPremium'] == true,
      );
    });
  }

  static Future<void> saveTrialStart(DateTime trialStart) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
    final callable = functions.httpsCallable('initializeUserTrial');
    await callable.call({'trialStart': trialStart.toIso8601String()});
  }

  static List<Filament> _parseFilaments(dynamic raw) {
    if (raw is! List) {
      throw const FormatException(
        'Firestore: Das Feld "filaments" ist keine Liste.',
      );
    }
    final result = <Filament>[];
    for (var index = 0; index < raw.length; index++) {
      final item = raw[index];
      try {
        if (item is! Map) {
          throw const FormatException('Filament-Eintrag ist kein JSON-Objekt.');
        }
        result.add(Filament.fromJson(Map<String, dynamic>.from(item)));
      } catch (error, stackTrace) {
        debugPrint(
          '[FirestoreService] FEHLER beim Filament ${index + 1}/${raw.length}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
        Error.throwWithStackTrace(
          FormatException(
            'Filament ${index + 1}/${raw.length} konnte nicht geladen werden: $error',
          ),
          stackTrace,
        );
      }
    }
    debugPrint(
      '[FirestoreService] Filamente erfolgreich geladen: ${result.length}/${raw.length}',
    );
    return result;
  }

  static List<PrintJob> _parseJobs(dynamic raw) {
    if (raw is! List) {
      throw const FormatException(
        'Firestore: Das Feld "jobs" ist keine Liste.',
      );
    }
    final result = <PrintJob>[];
    for (var index = 0; index < raw.length; index++) {
      final item = raw[index];
      try {
        if (item is! Map) {
          throw const FormatException('Druckauftrag ist kein JSON-Objekt.');
        }
        result.add(PrintJob.fromJson(Map<String, dynamic>.from(item)));
      } catch (error, stackTrace) {
        debugPrint(
          '[FirestoreService] FEHLER beim Druckauftrag ${index + 1}/${raw.length}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
        Error.throwWithStackTrace(
          FormatException(
            'Druckauftrag ${index + 1}/${raw.length} konnte nicht geladen werden: $error',
          ),
          stackTrace,
        );
      }
    }
    debugPrint(
      '[FirestoreService] Druckaufträge erfolgreich geladen: ${result.length}/${raw.length}',
    );
    return result;
  }

  static Future<List<Filament>?> loadFilaments() async {
    final reference = _dataReference;
    if (reference == null) return null;
    final snapshot = await reference.get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null || data['filaments'] == null) return null;
    return _parseFilaments(data['filaments']);
  }

  static Future<List<PrintJob>?> loadJobs() async {
    final reference = _dataReference;
    if (reference == null) return null;
    final snapshot = await reference.get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null || data['jobs'] == null) return null;
    return _parseJobs(data['jobs']);
  }

  static Future<void> saveData({
    required List<Filament> filaments,
    required List<PrintJob> jobs,
  }) async {
    final reference = _dataReference;
    if (reference == null) return;
    final filamentData = filaments
        .map((filament) => filament.toJson())
        .toList();
    final jobData = jobs.map((job) => job.toJson()).toList();
    await reference.set({
      'filaments': filamentData,
      'jobs': jobData,
    }, SetOptions(merge: true));
  }

  /// Ergänzt fehlende Spulen-IDs atomar und idempotent.
  /// Andere Dokumentfelder (insbesondere jobs und Premiumdaten) werden
  /// nicht geschrieben. Bei ungültigen Bestandsdaten wird abgebrochen.
  static Future<int> migrateMissingSpoolIds({
    required String expectedUid,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != expectedUid) {
      throw StateError(
        'Spulen-ID-Migration: Benutzer nicht angemeldet oder gewechselt.',
      );
    }
    final reference = _firestore
        .collection('users')
        .doc(expectedUid)
        .collection(_appDataCollection)
        .doc(_mainDocument);

    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) return 0;
      final data = snapshot.data();
      if (data == null || data['filaments'] is! List || data['jobs'] is! List) {
        throw const FormatException(
          'Spulen-ID-Migration: unvollständiges App-Dokument.',
        );
      }
      final rawFilaments = data['filaments'] as List;
      final updatedFilaments = <Map<String, dynamic>>[];
      final usedIds = <String>{};
      var addedIds = 0;

      // Zuerst alle vorhandenen IDs erfassen und doppelte IDs erkennen.
      for (final rawFilament in rawFilaments) {
        if (rawFilament is! Map) {
          throw const FormatException(
            'Spulen-ID-Migration: ungültiges Filament.',
          );
        }
        final filament = Map<String, dynamic>.from(rawFilament);
        final spools = filament['spools'];
        if (filament['id'] == null || spools is! List) {
          throw const FormatException(
            'Spulen-ID-Migration: Filament-ID oder Spulenliste fehlt.',
          );
        }
        for (final rawSpool in spools) {
          if (rawSpool is! Map) {
            throw const FormatException(
              'Spulen-ID-Migration: ungültige Spule.',
            );
          }
          final id = rawSpool['id']?.toString().trim() ?? '';
          if (id.isNotEmpty && !usedIds.add(id)) {
            throw StateError(
              'Spulen-ID-Migration: doppelte vorhandene Spulen-ID.',
            );
          }
        }
      }

      for (
        var filamentIndex = 0;
        filamentIndex < rawFilaments.length;
        filamentIndex++
      ) {
        final filament = Map<String, dynamic>.from(
          rawFilaments[filamentIndex] as Map,
        );
        final rawSpools = filament['spools'] as List;
        final updatedSpools = <Map<String, dynamic>>[];
        for (var spoolIndex = 0; spoolIndex < rawSpools.length; spoolIndex++) {
          final spool = Map<String, dynamic>.from(rawSpools[spoolIndex] as Map);
          final existingId = spool['id']?.toString().trim() ?? '';
          if (existingId.isEmpty) {
            // Deterministische ID, keine Zufallszahl und keine Kollision
            // mit einer bereits gespeicherten Spulen-ID.
            final base = 'legacy-${filament['id']}-$spoolIndex';
            var candidate = base;
            var suffix = 1;
            while (usedIds.contains(candidate)) {
              candidate = '$base-${suffix++}';
            }
            usedIds.add(candidate);
            spool['id'] = candidate;
            addedIds++;
          }
          updatedSpools.add(spool);
        }
        filament['spools'] = updatedSpools;
        updatedFilaments.add(filament);
      }
      if (addedIds > 0) {
        transaction.update(reference, {'filaments': updatedFilaments});
      }
      return addedIds;
    });
  }

  static Future<FirestoreData?> loadData() async {
    final reference = _dataReference;
    if (reference == null) return null;
    final snapshot = await reference.get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) {
      throw const FormatException(
        'Firestore-Dokument existiert, enthält aber keine lesbaren Daten.',
      );
    }
    final rawFilaments = data['filaments'];
    final rawJobs = data['jobs'];
    if (rawFilaments == null || rawJobs == null) {
      throw const FormatException(
        'Firestore-Dokument enthält nicht beide erforderlichen Datenfelder.',
      );
    }
    debugPrint('[FirestoreService] Cloud-Daten werden geladen.');
    final filaments = _parseFilaments(rawFilaments);
    final jobs = _parseJobs(rawJobs);
    debugPrint(
      '[FirestoreService] Laden abgeschlossen: ${filaments.length} Filamente, ${jobs.length} Druckaufträge.',
    );
    return FirestoreData(filaments: filaments, jobs: jobs);
  }

  static Future<bool> hasCloudData() async {
    final reference = _dataReference;
    if (reference == null) return false;
    final snapshot = await reference.get();
    return snapshot.exists;
  }
}

class FirestoreData {
  final List<Filament> filaments;
  final List<PrintJob> jobs;

  const FirestoreData({required this.filaments, required this.jobs});
}

class UserAccessStatus {
  final DateTime? trialStart;
  final bool trialUsed;
  final bool premiumActive;
  final bool manualPremium;

  const UserAccessStatus({
    required this.trialStart,
    required this.trialUsed,
    required this.premiumActive,
    required this.manualPremium,
  });
}
