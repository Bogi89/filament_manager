"use strict";

/**
 * FilaLog Monitoring 2.0.
 * Isolated Cloud Functions for authenticated event tracking
 * and administrator-only statistics.
 */

const {onCall} = require("firebase-functions/v2/https");
const {getFirestore} = require("firebase-admin/firestore");

const config = require("./config");
const {createTrackingHandler} = require("./tracking");
const {createOverviewHandler} = require("./overview");

/**
 * Creates the monitoring callable functions.
 *
 * @param {Object} options Optional dependencies for tests.
 * @return {Object} Named Cloud Functions.
 */
function createMonitoringFunctions(options = {}) {
  const db = options.db || getFirestore();
  const callable = options.onCall || onCall;
  const tracking = createTrackingHandler(db);
  const overview = createOverviewHandler(db);
  const callableOptions = {
    region: config.MONITORING_REGION,
    maxInstances: 10,
  };

  return Object.freeze({
    monitoringV2TrackEvent: callable(callableOptions, tracking),
    monitoringV2GetOverview: callable(callableOptions, overview),
  });
}

module.exports = Object.freeze({createMonitoringFunctions});
