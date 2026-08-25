import 'package:firebase_auth/firebase_auth.dart';

import '../auth/services/guest_service.dart';
import 'firestore_service.dart';

enum AccessStatus {
  guestTrialActive,
  guestTrialExpired,
  accountTrialActive,
  accountTrialExpired,
  premiumActive,
  noAccess,
}

class AccessService {
  AccessService._();

  static const Duration trialDuration = Duration(days: 7);

  /// Ermittelt den aktuellen Zugriffsstatus.
  static Future<AccessStatus> getAccessStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    /// ================= GASTNUTZER =================

    if (user == null) {
      final guestEnabled = await GuestService.isGuestModeEnabled();

      final trialUsed = await GuestService.hasUsedTrial();

      if (!trialUsed) {
        return AccessStatus.noAccess;
      }

      final trialActive = await GuestService.isTrialActive();

      if (guestEnabled && trialActive) {
        return AccessStatus.guestTrialActive;
      }

      return AccessStatus.guestTrialExpired;
    }

    /// ================= ANGEMELDETER BENUTZER =================

    final accessStatus = await FirestoreService.loadUserAccessStatus();

    /// Für ältere Konten, insbesondere bestehende Google-Konten,
    /// kann noch kein Zugriffsstatus in Firestore vorhanden sein.
    ///
    /// Wenn vorher bereits ein Gast-Test verwendet wurde, wird
    /// dessen ursprünglicher Startzeitpunkt übernommen.
    ///
    /// Andernfalls verwenden wir das Erstellungsdatum des
    /// Firebase-Kontos.
    if (accessStatus == null) {
      final guestTrialUsed = await GuestService.hasUsedTrial();

      final guestTrialStart = guestTrialUsed
          ? await GuestService.getGuestStartDate()
          : null;

      final accountCreationTime = user.metadata.creationTime;

      final trialStart =
          guestTrialStart ?? accountCreationTime ?? DateTime.now();

      await FirestoreService.saveTrialStart(trialStart);

      return _evaluateTrial(trialStart);
    }

    /// Premium hat immer Vorrang.
    if (accessStatus.premiumActive) {
      return AccessStatus.premiumActive;
    }

    /// Sobald ein angemeldetes Konto einen eigenen
    /// Firestore-Zugriffsstatus besitzt, ist ausschließlich
    /// dieser Status maßgeblich.
    ///
    /// Der lokale Gaststatus darf einen abgelaufenen
    /// Account-Test nicht erneut aktivieren.
    if (accessStatus.trialUsed) {
      final trialStart = accessStatus.trialStart;

      if (trialStart == null) {
        return AccessStatus.accountTrialExpired;
      }

      return _evaluateTrial(trialStart);
    }

    /// Ältere oder unvollständige Account-Datensätze ohne
    /// gespeicherten Teststart werden einmalig initialisiert.
    final accountCreationTime = user.metadata.creationTime;

    final trialStart = accountCreationTime ?? DateTime.now();

    await FirestoreService.saveTrialStart(trialStart);

    return _evaluateTrial(trialStart);
  }

  static AccessStatus _evaluateTrial(DateTime trialStart) {
    final expirationDate = trialStart.add(trialDuration);

    if (DateTime.now().isBefore(expirationDate)) {
      return AccessStatus.accountTrialActive;
    }

    return AccessStatus.accountTrialExpired;
  }

  /// Prüft, ob der aktuelle Benutzer Zugriff
  /// auf die App hat.
  static Future<bool> hasFullAccess() async {
    final status = await getAccessStatus();

    return status == AccessStatus.guestTrialActive ||
        status == AccessStatus.accountTrialActive ||
        status == AccessStatus.premiumActive;
  }

  /// Prüft, ob der aktuelle Benutzer Premium besitzt.
  static Future<bool> isPremiumActive() async {
    final status = await getAccessStatus();

    return status == AccessStatus.premiumActive;
  }

  /// Prüft, ob die Testphase abgelaufen ist.
  static Future<bool> isTrialExpired() async {
    final status = await getAccessStatus();

    return status == AccessStatus.guestTrialExpired ||
        status == AccessStatus.accountTrialExpired;
  }
}
