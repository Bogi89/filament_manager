
"use strict";

/**
 * FilaLog Monitoring 2.0
 *
 * Zentrale, unveränderliche Konfiguration.
 *
 * Die produktive Erfassung bleibt deaktiviert,
 * bis sämtliche Funktionen und Tests abgeschlossen sind.
 */

const MONITORING_VERSION = 2;

const MONITORING_MODE = "disabled";

const MONITORING_REGION = "europe-west1";

const MONITORING_TIMEZONE = "UTC";

const MONITORING_GENERATION = "v2-production-001";

const MONITORING_START_AT = null;

const HISTORICAL_START_AT =
    new Date("2026-09-25T01:30:00+02:00");

const ADMIN_UIDS = Object.freeze([
  "6ifAvEdTTQUv3Ej16940ir3sRip1",
]);

const ALLOWED_PLATFORMS = Object.freeze([
  "web",
  "android",
  "ios",
  "windows",
  "macos",
  "linux",
  "fuchsia",
]);

const COLLECTIONS = Object.freeze({
  configuration: "monitoringV2Config",
  generations: "monitoringV2Generations",
  users: "monitoringV2Users",
  events: "monitoringV2Events",
  daily: "monitoringV2Daily",
});

/**
 * Prüft, ob die produktive Monitoring-Erfassung aktiviert ist.
 *
 * @return {boolean} True, wenn Monitoring aktiviert ist.
 */
function isMonitoringEnabled() {
  return MONITORING_MODE === "production" &&
      MONITORING_START_AT instanceof Date &&
      Number.isFinite(MONITORING_START_AT.getTime());
}

/**
 * Prüft, ob eine Firebase-UID Administratorrechte besitzt.
 *
 * @param {string} uid Firebase-Benutzer-ID.
 * @return {boolean} True, wenn die UID berechtigt ist.
 */
function isAdmin(uid) {
  return typeof uid === "string" &&
      ADMIN_UIDS.includes(uid);
}

/**
 * Prüft, ob eine Plattform für Monitoring zugelassen ist.
 *
 * @param {string} platform Name der Plattform.
 * @return {boolean} True, wenn die Plattform erlaubt ist.
 */
function isAllowedPlatform(platform) {
  return typeof platform === "string" &&
      ALLOWED_PLATFORMS.includes(platform);
}

/**
 * Liefert die aktuelle Monitoring-Konfiguration.
 *
 * @return {Object} Monitoring-Konfiguration.
 */
function getMonitoringConfig() {
  return {
    version: MONITORING_VERSION,
    mode: MONITORING_MODE,
    region: MONITORING_REGION,
    timezone: MONITORING_TIMEZONE,
    generation: MONITORING_GENERATION,
    startAt: MONITORING_START_AT,
    enabled: isMonitoringEnabled(),
  };
}

module.exports = Object.freeze({
  MONITORING_VERSION,
  MONITORING_MODE,
  MONITORING_REGION,
  MONITORING_TIMEZONE,
  MONITORING_GENERATION,
  MONITORING_START_AT,
  HISTORICAL_START_AT,
  ADMIN_UIDS,
  ALLOWED_PLATFORMS,
  COLLECTIONS,
  isMonitoringEnabled,
  isAdmin,
  isAllowedPlatform,
  getMonitoringConfig,
});
