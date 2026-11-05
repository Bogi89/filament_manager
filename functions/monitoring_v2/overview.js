
"use strict";

/**
 * FilaLog Monitoring 2.0
 *
 * Serverseitige Auswertung registrierter Nutzer.
 *
 * Berechnet eindeutige aktive Nutzer, Rückkehrer,
 * Kohorten-Retention und Funktionsereignisse.
 *
 * Gasterfassung und produktive Aktivierung
 * folgen in späteren Entwicklungsschritten.
 */

const {
  HttpsError,
} = require("firebase-functions/v2/https");

const defaultConfig = require("./config");

const {ALLOWED_EVENTS} = require("./events");

const DAY_MS = 24 * 60 * 60 * 1000;
const MAX_USERS = 5000;
const MAX_DAYS_PER_USER = 1000;
const MAX_EVENTS = 20000;

/**
 * Formatiert ein UTC-Datum als Kalendertag.
 *
 * @param {Date} date Gültiges Datum.
 * @return {string} Kalendertag.
 */
function utcDay(date) {
  return date.toISOString().slice(0, 10);
}

/**
 * Ermittelt die UTC-Tagesnummer.
 *
 * @param {string} day Datum YYYY-MM-DD.
 * @return {number} Tagesnummer.
 */
function dayNumber(day) {
  const value = Date.parse(`${day}T00:00:00.000Z`);

  if (!Number.isFinite(value)) {
    throw new Error("Invalid monitoring day.");
  }

  return Math.floor(value / DAY_MS);
}

/**
 * Berechnet den Abstand zweier UTC-Tage.
 *
 * @param {string} first Erster Tag.
 * @param {string} second Zweiter Tag.
 * @return {number} Abstand in Tagen.
 */
function dayDifference(first, second) {
  return dayNumber(second) - dayNumber(first);
}

/**
 * Prüft die Berechtigung des Administrators.
 *
 * @param {Object} request Firebase Callable Request.
 * @param {Object} config Monitoring-Konfiguration.
 * @return {void}
 */
function requireAdmin(request, config) {
  if (!request || !request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Authentication required.",
    );
  }

  if (!config.isAdmin(request.auth.uid)) {
    throw new HttpsError(
        "permission-denied",
        "Monitoring access denied.",
    );
  }
}

/**
 * Liest eine begrenzte Collection vollständig.
 *
 * Die zusätzliche Dokumentabfrage erkennt,
 * ob das konfigurierte Limit überschritten wird.
 * Unvollständige Daten werden nicht als
 * vollständige Statistik ausgegeben.
 *
 * @param {Object} reference Firestore-Collection.
 * @param {number} maximum Maximale Dokumentanzahl.
 * @return {Promise<Array>} Dokumente.
 */
async function readLimited(reference, maximum) {
  const snapshot = await reference
      .limit(maximum + 1)
      .get();

  if (snapshot.size > maximum) {
    throw new HttpsError(
        "resource-exhausted",
        "Monitoring query limit exceeded.",
    );
  }

  return snapshot.docs;
}

/**
 * Ermittelt die Kohorten-Retention.
 *
 * Nur Nutzer, deren erster Nutzungstag
 * ausreichend weit zurückliegt, gehören
 * zur jeweiligen auswertbaren Kohorte.
 *
 * @param {Array} users Ausgewertete Nutzer.
 * @param {string} today Aktueller UTC-Tag.
 * @param {number} offset Kohortentag.
 * @return {Object} Retention-Ergebnis.
 */
function calculateRetention(users, today, offset) {
  let eligible = 0;
  let returned = 0;

  for (const user of users) {
    if (
      dayDifference(user.firstDay, today) < offset
    ) {
      continue;
    }

    eligible++;

    const targetDay =
        dayNumber(user.firstDay) + offset;

    if (user.activeDays.has(targetDay)) {
      returned++;
    }
  }

  return {
    day: offset,
    eligibleUsers: eligible,
    returnedUsers: returned,
    ratePercent: eligible === 0 ?
      null :
      Number((returned / eligible * 100).toFixed(2)),
  };
}

/**
 * Erstellt den geschützten Monitoring-Handler.
 *
 * @param {FirebaseFirestore.Firestore} db Firestore.
 * @param {Object} options Optionale Abhängigkeiten.
 * @return {Function} Callable-Handler.
 */
function createOverviewHandler(db, options = {}) {
  if (!db || typeof db.collection !== "function") {
    throw new TypeError("Invalid Firestore instance.");
  }

  const config = options.config || defaultConfig;
  const nowProvider =
      options.nowProvider || (() => new Date());

  if (
    typeof config.isAdmin !== "function" ||
    typeof config.isMonitoringEnabled !== "function" ||
    typeof nowProvider !== "function"
  ) {
    throw new TypeError("Invalid overview dependencies.");
  }

  /**
   * Erstellt die Monitoring-Übersicht.
   *
   * @param {Object} request Firebase Callable Request.
   * @return {Promise<Object>} Monitoring-Auswertung.
   */
  return async function getOverview(request) {
    requireAdmin(request, config);

    if (!config.isMonitoringEnabled()) {
      return {
        enabled: false,
        version: 2,
        reason: "monitoring_disabled",
      };
    }

    const now = nowProvider();

    if (
      !(now instanceof Date) ||
      !Number.isFinite(now.getTime())
    ) {
      throw new Error("Invalid monitoring clock.");
    }

    const today = utcDay(now);
    const todayNumber = dayNumber(today);

    const generationReference = db
        .collection(config.COLLECTIONS.generations)
        .doc(config.MONITORING_GENERATION);

    const userDocuments = await readLimited(
        generationReference.collection("users"),
        MAX_USERS,
    );

    const users = [];

    for (const document of userDocuments) {
      const data = document.data();
      const firstDay = data.firstActiveDay;

      if (typeof firstDay !== "string") {
        throw new Error(
            "Missing first activity day.",
        );
      }

      const dayDocuments = await readLimited(
          document.ref.collection("days"),
          MAX_DAYS_PER_USER,
      );

      const activeDays = new Set();

      for (const dayDocument of dayDocuments) {
        activeDays.add(dayNumber(dayDocument.id));
      }

      users.push({
        firstDay,
        activeDays,
      });
    }

    let dau = 0;
    let wau = 0;
    let mau = 0;
    let returningUsers = 0;
    let newUsersToday = 0;

    for (const user of users) {
      if (user.firstDay === today) {
        newUsersToday++;
      }

      if (user.activeDays.has(todayNumber)) {
        dau++;
      }

      if (
        [...user.activeDays].some(
            (day) =>
              day >= todayNumber - 6 &&
              day <= todayNumber,
        )
      ) {
        wau++;
      }

      if (
        [...user.activeDays].some(
            (day) =>
              day >= todayNumber - 29 &&
              day <= todayNumber,
        )
      ) {
        mau++;
      }

      if (
        [...user.activeDays].some(
            (day) =>
              day > dayNumber(user.firstDay),
        )
      ) {
        returningUsers++;
      }
    }

    const eventDocuments = await readLimited(
        generationReference.collection("events"),
        MAX_EVENTS,
    );

    const eventCounts = {};

    for (const eventName of ALLOWED_EVENTS) {
      eventCounts[eventName] = 0;
    }

    const screenViews = {};

    for (const document of eventDocuments) {
      const data = document.data();

      if (
        typeof data.eventName !== "string" ||
        !Object.prototype.hasOwnProperty.call(
            eventCounts,
            data.eventName,
        )
      ) {
        continue;
      }

      eventCounts[data.eventName]++;

      if (
        data.eventName === "screen_viewed" &&
        typeof data.screenName === "string"
      ) {
        screenViews[data.screenName] =
            (screenViews[data.screenName] || 0) + 1;
      }
    }

    return {
      enabled: true,
      version: 2,
      generation: config.MONITORING_GENERATION,
      timezone: "UTC",
      calculatedAt: now.toISOString(),
      scope: "registered_users_only",
      users: {
        totalTracked: users.length,
        newToday: newUsersToday,
        activeToday: dau,
        active7Days: wau,
        active30Days: mau,
        returning: returningUsers,
      },
      retention: {
        day1: calculateRetention(users, today, 1),
        day7: calculateRetention(users, today, 7),
        day30: calculateRetention(users, today, 30),
      },
      usage: {
        totalEvents: eventDocuments.length,
        events: eventCounts,
        screenViews,
      },
    };
  };
}

module.exports = Object.freeze({
  createOverviewHandler,
});
