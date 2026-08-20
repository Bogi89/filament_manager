import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/filament.dart';
import '../models/print_job.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const String _appDataCollection = 'appData';
  static const String _mainDocument = 'main';

  /// Gibt den aktuell angemeldeten Benutzer zurück.
  ///
  /// Im Gastmodus ist kein Firebase-Benutzer vorhanden.
  static User? get currentUser => _auth.currentUser;

  /// Referenz auf die persönlichen App-Daten des aktuell
  /// angemeldeten Benutzers.
  ///
  /// Struktur:
  ///
  /// users/{uid}/appData/main
  static DocumentReference<Map<String, dynamic>>?
      get _dataReference {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(_appDataCollection)
        .doc(_mainDocument);
  }

  /// Prüft, ob aktuell ein Firebase-Benutzer angemeldet ist.
  static bool get isSignedIn {
    return _auth.currentUser != null;
  }

  /// Lädt die gespeicherten Filamente des angemeldeten Benutzers.
  ///
  /// Gibt null zurück, wenn:
  /// - kein Benutzer angemeldet ist
  /// - noch keine Cloud-Daten existieren
  static Future<List<Filament>?> loadFilaments() async {
    final reference = _dataReference;

    if (reference == null) {
      return null;
    }

    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null || data['filaments'] == null) {
      return null;
    }

    final rawFilaments = data['filaments'];

    if (rawFilaments is! List) {
      return null;
    }

    final filaments = <Filament>[];

    for (final item in rawFilaments) {
      if (item is Map) {
        try {
          filaments.add(
            Filament.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Ein fehlerhaftes einzelnes Element darf nicht
          // verhindern, dass die übrigen Daten geladen werden.
        }
      }
    }

    return filaments;
  }

  /// Lädt die gespeicherten Druckaufträge des angemeldeten Benutzers.
  ///
  /// Gibt null zurück, wenn:
  /// - kein Benutzer angemeldet ist
  /// - noch keine Cloud-Daten existieren
  static Future<List<PrintJob>?> loadJobs() async {
    final reference = _dataReference;

    if (reference == null) {
      return null;
    }

    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null || data['jobs'] == null) {
      return null;
    }

    final rawJobs = data['jobs'];

    if (rawJobs is! List) {
      return null;
    }

    final jobs = <PrintJob>[];

    for (final item in rawJobs) {
      if (item is Map) {
        try {
          jobs.add(
            PrintJob.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          // Ein fehlerhafter einzelner Auftrag darf nicht
          // den kompletten Datenbestand unbrauchbar machen.
        }
      }
    }

    return jobs;
  }

  /// Speichert Filamente und Druckaufträge gemeinsam.
  ///
  /// Die vorhandenen Daten werden nicht gelöscht, wenn nur einer
  /// der beiden Werte übergeben wird.
  static Future<void> saveData({
    required List<Filament> filaments,
    required List<PrintJob> jobs,
  }) async {
    final reference = _dataReference;

    if (reference == null) {
      return;
    }

    final filamentData = filaments
        .map((filament) => filament.toJson())
        .toList();

    final jobData = jobs
        .map((job) => job.toJson())
        .toList();

    await reference.set(
      {
        'filaments': filamentData,
        'jobs': jobData,
      },
      SetOptions(merge: true),
    );
  }

  /// Lädt den kompletten Cloud-Datenbestand.
  ///
  /// Gibt null zurück, wenn keine Cloud-Daten vorhanden sind.
  static Future<FirestoreData?> loadData() async {
    final reference = _dataReference;

    if (reference == null) {
      return null;
    }

    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    final filaments = <Filament>[];
    final jobs = <PrintJob>[];

    final rawFilaments = data['filaments'];

    if (rawFilaments is List) {
      for (final item in rawFilaments) {
        if (item is Map) {
          try {
            filaments.add(
              Filament.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Fehlerhafte Einträge werden übersprungen.
          }
        }
      }
    }

    final rawJobs = data['jobs'];

    if (rawJobs is List) {
      for (final item in rawJobs) {
        if (item is Map) {
          try {
            jobs.add(
              PrintJob.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } catch (_) {
            // Fehlerhafte Einträge werden übersprungen.
          }
        }
      }
    }

    return FirestoreData(
      filaments: filaments,
      jobs: jobs,
    );
  }

  /// Prüft, ob für den aktuell angemeldeten Benutzer bereits
  /// Cloud-Daten existieren.
  static Future<bool> hasCloudData() async {
    final reference = _dataReference;

    if (reference == null) {
      return false;
    }

    final snapshot = await reference.get();

    return snapshot.exists;
  }

  /// Löscht die persönlichen Cloud-Daten des aktuell
  /// angemeldeten Benutzers.
  ///
  /// Wird aktuell noch nicht von der App verwendet.
  static Future<void> deleteCloudData() async {
    final reference = _dataReference;

    if (reference == null) {
      return;
    }

    await reference.delete();
  }
}

/// Container für den kompletten Firestore-Datenbestand
/// eines Benutzers.
class FirestoreData {
  final List<Filament> filaments;
  final List<PrintJob> jobs;

  const FirestoreData({
    required this.filaments,
    required this.jobs,
  });
}