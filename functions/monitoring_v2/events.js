"use strict";

/** FilaLog Monitoring 2.0: allowlisted event payloads. */

const EVENT_NAMES = Object.freeze({
  APP_STARTED: "app_started",
  APP_RESUMED: "app_resumed",
  GUEST_STARTED: "guest_started",
  SCREEN_VIEWED: "screen_viewed",
  REGISTRATION_OPENED: "registration_opened",
  REGISTRATION_ATTEMPTED: "registration_attempted",
  REGISTRATION_COMPLETED: "registration_completed",
  EMAIL_VERIFIED: "email_verified",
  LOGIN_OPENED: "login_opened",
  LOGIN_COMPLETED: "login_completed",
  FILAMENT_ADDED: "filament_added",
  FILAMENT_UPDATED: "filament_updated",
  FILAMENT_DELETED: "filament_deleted",
  SPOOL_ADDED: "spool_added",
  SPOOL_DELETED: "spool_deleted",
  CALCULATION_COMPLETED: "calculation_completed",
  PRINT_JOB_SAVE_ATTEMPTED: "print_job_save_attempted",
  PRINT_JOB_SAVED: "print_job_saved",
  PRINT_JOB_SAVE_FAILED: "print_job_save_failed",
  PRINT_JOB_UPDATED: "print_job_updated",
  PRINT_JOB_DELETED: "print_job_deleted",
  TRIAL_STARTED: "trial_started",
  TRIAL_EXPIRED: "trial_expired",
  PREMIUM_PAGE_OPENED: "premium_page_opened",
  PREMIUM_PURCHASE_STARTED: "premium_purchase_started",
  PREMIUM_PURCHASE_COMPLETED: "premium_purchase_completed",
});

const SCREEN_NAMES = Object.freeze([
  "dashboard", "filaments", "calculator", "history", "statistics", "settings",
]);

const PLATFORM_NAMES = Object.freeze([
  "web", "android", "ios", "windows", "macos", "linux", "fuchsia",
]);

const ALLOWED_EVENTS = Object.freeze(Object.values(EVENT_NAMES));
const ALLOWED_EVENT_SET = new Set(ALLOWED_EVENTS);
const ALLOWED_SCREEN_SET = new Set(SCREEN_NAMES);
const ALLOWED_PLATFORM_SET = new Set(PLATFORM_NAMES);
const EVENT_ID_PATTERN = /^[a-zA-Z0-9_-]{16,128}$/;

/**
 * @param {string} eventName Event name.
 * @return {boolean} Whether supported.
 */
function isAllowedEvent(eventName) {
  return typeof eventName === "string" && ALLOWED_EVENT_SET.has(eventName);
}

/**
 * @param {string} screenName Screen name.
 * @return {boolean} Whether supported.
 */
function isAllowedScreen(screenName) {
  return typeof screenName === "string" && ALLOWED_SCREEN_SET.has(screenName);
}

/**
 * @param {string} platform Platform name.
 * @return {boolean} Whether supported.
 */
function isAllowedPlatform(platform) {
  return typeof platform === "string" && ALLOWED_PLATFORM_SET.has(platform);
}

/**
 * @param {string} eventId Client event ID.
 * @return {boolean} Whether valid.
 */
function isValidEventId(eventId) {
  return typeof eventId === "string" && EVENT_ID_PATTERN.test(eventId);
}

/**
 * Allowlist input; do not persist arbitrary user data.
 * Platform is required for new events.
 *
 * @param {Object} input Incoming payload.
 * @return {Object} Frozen sanitized payload.
 */
function validateEvent(input) {
  if (input === null || typeof input !== "object" || Array.isArray(input)) {
    throw new TypeError("Invalid event payload.");
  }

  const {eventId, eventName, screenName, platform} = input;

  if (!isValidEventId(eventId)) {
    throw new TypeError("Invalid event ID.");
  }
  if (!isAllowedEvent(eventName)) {
    throw new TypeError("Unsupported event name.");
  }
  if (!isAllowedPlatform(platform)) {
    throw new TypeError("Invalid platform.");
  }
  if (eventName === EVENT_NAMES.SCREEN_VIEWED &&
      !isAllowedScreen(screenName)) {
    throw new TypeError("Invalid screen name.");
  }
  if (screenName !== undefined && !isAllowedScreen(screenName)) {
    throw new TypeError("Unsupported screen name.");
  }

  const result = {eventId, eventName, platform};
  if (eventName === EVENT_NAMES.SCREEN_VIEWED) {
    result.screenName = screenName;
  }
  return Object.freeze(result);
}

module.exports = Object.freeze({
  EVENT_NAMES,
  SCREEN_NAMES,
  PLATFORM_NAMES,
  ALLOWED_EVENTS,
  isAllowedEvent,
  isAllowedScreen,
  isAllowedPlatform,
  isValidEventId,
  validateEvent,
});
