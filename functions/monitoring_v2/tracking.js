"use strict";

/** FilaLog Monitoring 2.0: transactional, idempotent event tracking. */

const crypto = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const defaultConfig = require("./config");
const {validateEvent} = require("./events");

const TRIAL_DURATION_MS = 7 * 24 * 60 * 60 * 1000;
const TRIAL_EVENTS = new Set(["trial_started", "trial_expired"]);

/**
 * @param {string} value Value to hash.
 * @return {string} SHA-256 hex digest.
 */
function hashValue(value) {
  return crypto.createHash("sha256").update(value, "utf8").digest("hex");
}

/**
 * @param {Date} date Server time.
 * @return {string} UTC date.
 */
function getUtcDay(date) {
  return date.toISOString().slice(0, 10);
}

/**
 * @param {Object} request Callable request.
 * @return {string} Authenticated Firebase UID.
 */
function requireAuthenticatedUser(request) {
  if (!request || !request.auth ||
      typeof request.auth.uid !== "string" ||
      request.auth.uid.length === 0) {
    throw new HttpsError(
        "unauthenticated",
        "Authentication required for monitoring.",
    );
  }
  return request.auth.uid;
}

/**
 * @param {Object} data Incoming data.
 * @return {Object} Validated event.
 */
function parseEvent(data) {
  try {
    return validateEvent(data);
  } catch (error) {
    throw new HttpsError("invalid-argument", "Invalid monitoring event.");
  }
}

/**
 * @param {Object} data Trusted account access data.
 * @return {Date|null} Valid trial start or null.
 */
function parseTrialStart(data) {
  if (!data || data.trialUsed !== true ||
      typeof data.trialStart !== "string") {
    return null;
  }
  const start = new Date(data.trialStart);
  return Number.isFinite(start.getTime()) ? start : null;
}

/**
 * Creates an isolated callable handler.
 *
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {Object} options Injected test dependencies.
 * @return {Function} Callable handler.
 */
function createTrackingHandler(db, options = {}) {
  if (!db || typeof db.collection !== "function" ||
      typeof db.runTransaction !== "function") {
    throw new TypeError("Invalid Firestore instance.");
  }

  const monitoringConfig = options.config || defaultConfig;
  const nowProvider = options.nowProvider || (() => new Date());
  const fieldValue = options.fieldValue || FieldValue;

  if (typeof monitoringConfig.isMonitoringEnabled !== "function" ||
      typeof nowProvider !== "function" ||
      typeof fieldValue.increment !== "function" ||
      typeof fieldValue.serverTimestamp !== "function") {
    throw new TypeError("Invalid monitoring dependencies.");
  }

  /**
   * @param {Object} request Firebase callable request.
   * @return {Promise<Object>} Tracking result.
   */
  return async function trackEvent(request) {
    if (!monitoringConfig.isMonitoringEnabled()) {
      return {recorded: false, reason: "monitoring_disabled"};
    }

    const uid = requireAuthenticatedUser(request);
    const event = parseEvent(request.data);
    const now = nowProvider();

    if (!(now instanceof Date) || !Number.isFinite(now.getTime())) {
      throw new Error("Invalid monitoring clock.");
    }
    const startAt = monitoringConfig.MONITORING_START_AT;
    if (!(startAt instanceof Date) || !Number.isFinite(startAt.getTime())) {
      throw new Error("Invalid monitoring start date.");
    }
    if (now.getTime() < startAt.getTime()) {
      return {recorded: false, reason: "before_monitoring_start"};
    }

    const day = getUtcDay(now);
    const userId = hashValue(`registered:${uid}`);
    const eventDocumentId = hashValue(`${uid}:${event.eventId}`);
    const generationReference = db
        .collection(monitoringConfig.COLLECTIONS.generations)
        .doc(monitoringConfig.MONITORING_GENERATION);
    const eventReference = generationReference
        .collection("events").doc(eventDocumentId);
    const userReference = generationReference
        .collection("users").doc(userId);
    const dayReference = userReference.collection("days").doc(day);
    const dailyReference = generationReference.collection("daily").doc(day);
    const isTrialEvent = TRIAL_EVENTS.has(event.eventName);
    const accessReference = isTrialEvent ? db.collection("users")
        .doc(uid).collection("appData").doc("main") : null;

    return db.runTransaction(async (transaction) => {
      const eventSnapshot = await transaction.get(eventReference);
      if (eventSnapshot.exists) {
        return {recorded: false, duplicate: true};
      }

      let uniqueTrialReference = null;
      if (isTrialEvent) {
        const accessSnapshot = await transaction.get(accessReference);
        const trialStart = parseTrialStart(
            accessSnapshot.exists ? accessSnapshot.data() : null);
        if (!trialStart || trialStart.getTime() < startAt.getTime() ||
            trialStart.getTime() > now.getTime()) {
          return {recorded: false, reason: "ineligible_trial"};
        }
        const expiryTime = trialStart.getTime() + TRIAL_DURATION_MS;
        if (!Number.isFinite(expiryTime) ||
            (event.eventName === "trial_expired" &&
            now.getTime() < expiryTime)) {
          return {recorded: false, reason: "trial_not_expired"};
        }
        const uniqueTrialId = hashValue(
            `${uid}:${trialStart.toISOString()}:${event.eventName}`);
        uniqueTrialReference = generationReference
            .collection("trialEvents").doc(uniqueTrialId);
        const uniqueSnapshot = await transaction.get(uniqueTrialReference);
        if (uniqueSnapshot.exists) {
          return {recorded: false, duplicate: true};
        }
      }

      const userSnapshot = await transaction.get(userReference);
      const daySnapshot = await transaction.get(dayReference);
      const isNewUser = !userSnapshot.exists;
      const isNewActiveDay = !daySnapshot.exists;

      const eventData = {
        eventName: event.eventName,
        userType: "registered",
        userId,
        day,
        platform: event.platform,
        createdAt: fieldValue.serverTimestamp(),
      };
      if (event.screenName) {
        eventData.screenName = event.screenName;
      }
      transaction.create(eventReference, eventData);
      if (uniqueTrialReference) {
        transaction.create(uniqueTrialReference, {
          eventName: event.eventName,
          eventId: eventDocumentId,
          createdAt: fieldValue.serverTimestamp(),
        });
      }

      if (isNewUser) {
        transaction.create(userReference, {
          userType: "registered",
          firstSeenAt: fieldValue.serverTimestamp(),
          lastSeenAt: fieldValue.serverTimestamp(),
          firstActiveDay: day,
          lastActiveDay: day,
          eventCount: 1,
          activeDayCount: 1,
        });
      } else {
        const userUpdate = {
          lastSeenAt: fieldValue.serverTimestamp(),
          lastActiveDay: day,
          eventCount: fieldValue.increment(1),
        };
        if (isNewActiveDay) {
          userUpdate.activeDayCount = fieldValue.increment(1);
        }
        transaction.update(userReference, userUpdate);
      }

      if (isNewActiveDay) {
        transaction.create(dayReference, {
          day,
          firstEventAt: fieldValue.serverTimestamp(),
          lastEventAt: fieldValue.serverTimestamp(),
          eventCount: 1,
        });
      } else {
        transaction.update(dayReference, {
          lastEventAt: fieldValue.serverTimestamp(),
          eventCount: fieldValue.increment(1),
        });
      }

      // Nested maps prevent accidental literal dotted Firestore field names.
      const dailyUpdate = {
        day,
        eventCount: fieldValue.increment(1),
        updatedAt: fieldValue.serverTimestamp(),
        events: {
          [event.eventName]: fieldValue.increment(1),
        },
      };
      if (isNewActiveDay) {
        dailyUpdate.activeUsers = fieldValue.increment(1);
      }
      if (isNewUser) {
        dailyUpdate.newUsers = fieldValue.increment(1);
      }
      transaction.set(dailyReference, dailyUpdate, {merge: true});

      return {
        recorded: true,
        duplicate: false,
        newUser: isNewUser,
        newActiveDay: isNewActiveDay,
      };
    });
  };
}

module.exports = Object.freeze({createTrackingHandler});
