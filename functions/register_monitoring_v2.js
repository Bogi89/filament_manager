"use strict";

/**
 * One-time, non-deploying registration of Monitoring 2.0 exports.
 * Run from the functions directory with:
 * node register_monitoring_v2.js
 */

const fs = require("node:fs");
const path = require("node:path");

const root = __dirname;
const indexPath = path.join(root, "index.js");
const handlersPath = path.join(root, "monitoring_v2", "handlers.js");
const backupPath = path.join(root, "index.js.before_monitoring_v2.bak");

const registration = [
  "",
  "// FilaLog Monitoring 2.0 - separate, disabled-by-default handlers.",
  "const {createMonitoringFunctions} = require(\"./monitoring_v2/handlers\");",
  "const monitoringV2Functions = createMonitoringFunctions();",
  "exports.monitoringV2TrackEvent = " +
      "monitoringV2Functions.monitoringV2TrackEvent;",
  "exports.monitoringV2GetOverview = " +
      "monitoringV2Functions.monitoringV2GetOverview;",
  "",
].join("\n");

/**
 * Registers the two exports exactly once.
 *
 * @return {void}
 */
function main() {
  if (!fs.existsSync(indexPath) || !fs.existsSync(handlersPath)) {
    throw new Error("Required index.js or monitoring_v2/handlers.js missing.");
  }

  const original = fs.readFileSync(indexPath, "utf8");
  const trackExists = /exports\.monitoringV2TrackEvent\s*=/.test(original);
  const overviewExists = /exports\.monitoringV2GetOverview\s*=/.test(original);

  if (trackExists && overviewExists) {
    process.stdout.write("Monitoring 2.0 exports already registered.\n");
    return;
  }

  if (trackExists || overviewExists) {
    throw new Error("Partial Monitoring 2.0 registration: no changes made.");
  }

  if (original.includes("createMonitoringFunctions")) {
    throw new Error("Existing Monitoring 2.0 registration detected.");
  }

  if (fs.existsSync(backupPath)) {
    throw new Error("Backup already exists; no changes made.");
  }

  const updated = original.replace(/\s*$/, "\n") + registration;
  fs.writeFileSync(backupPath, original, {flag: "wx"});

  try {
    fs.writeFileSync(indexPath, updated);
  } catch (error) {
    fs.writeFileSync(indexPath, original);
    throw error;
  }

  process.stdout.write("Registered two Monitoring 2.0 exports.\n");
  process.stdout.write("Backup: index.js.before_monitoring_v2.bak\n");
  process.stdout.write("No deployment was performed.\n");
}

if (require.main === module) {
  main();
}

module.exports = Object.freeze({main});
