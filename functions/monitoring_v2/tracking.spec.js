"use strict";

/** In-memory tracking tests, including nested Firestore transforms. */

const assert = require("node:assert/strict");
const {test} = require("node:test");
const {createTrackingHandler} = require("./tracking");
const {validateEvent} = require("./events");

const START_AT = new Date("2026-11-05T00:00:00.000Z");
const NOW = new Date("2026-11-05T12:00:00.000Z");
const TRIAL_START = "2026-11-05T01:00:00.000Z";

/**
 * @param {boolean} enabled Whether enabled.
 * @return {Object} Test configuration.
 */
function createTestConfig(enabled) {
  return {
    isMonitoringEnabled: () => enabled,
    MONITORING_START_AT: START_AT,
    MONITORING_GENERATION: "test-generation",
    COLLECTIONS: {generations: "monitoringV2Test"},
  };
}

/**
 * Recursively applies Firestore increments and server timestamps.
 * @param {*} previous Existing value.
 * @param {*} incoming New value.
 * @return {*} Materialized value.
 */
const fakeFieldValue = Object.freeze({
  increment: (amount) => ({__testTransform: "increment", amount}),
  serverTimestamp: () => ({__testTransform: "serverTimestamp"}),
});

/**
 * Applies deterministic test-only Firestore transforms.
 * @param {*} previous Existing value.
 * @param {*} incoming New value.
 * @return {*} Materialized value.
 */
function mergeFirestoreValue(previous, incoming) {
  if (incoming && typeof incoming === "object" &&
      incoming.__testTransform === "increment") {
    return (typeof previous === "number" ? previous : 0) +
        incoming.amount;
  }
  if (incoming && typeof incoming === "object" &&
      incoming.__testTransform === "serverTimestamp") {
    return NOW;
  }
  if (incoming && typeof incoming === "object" &&
      !Array.isArray(incoming) && !(incoming instanceof Date)) {
    const base = previous && typeof previous === "object" &&
        !Array.isArray(previous) ? previous : {};
    const result = {...base};
    for (const [key, value] of Object.entries(incoming)) {
      result[key] = mergeFirestoreValue(base[key], value);
    }
    return result;
  }
  return incoming;
}

/**
 * Creates an isolated fake Firestore with transactional writes.
 * @return {Object} Fake database and inspection handles.
 */
function createFakeFirestore() {
  const documents = new Map();
  const counters = {transactions: 0, writes: 0};

  /**
   * @param {string} path Document path.
   * @return {Object} Document reference.
   */
  function reference(path) {
    return {
      path,
      collection: (name) => ({
        doc: (id) => reference(`${path}/${name}/${id}`),
      }),
    };
  }

  const db = {
    collection: (name) => ({doc: (id) => reference(`${name}/${id}`)}),
    runTransaction: async (callback) => {
      counters.transactions++;
      const operations = [];
      const transaction = {
        get: async (ref) => ({
          exists: documents.has(ref.path),
          data: () => documents.get(ref.path),
        }),
        create: (ref, data) => operations.push({type: "create", ref, data}),
        update: (ref, data) => operations.push({type: "update", ref, data}),
        set: (ref, data, options) => operations.push({
          type: "set", ref, data, options,
        }),
      };
      const result = await callback(transaction);
      for (const operation of operations) {
        const path = operation.ref.path;
        const exists = documents.has(path);
        if (operation.type === "create" && exists) {
          throw new Error("Document already exists.");
        }
        if (operation.type === "update" && !exists) {
          throw new Error("Document does not exist.");
        }
        const previous = documents.get(path);
        const merged = operation.type === "set" &&
            !(operation.options && operation.options.merge) ?
              undefined : previous;
        documents.set(path, mergeFirestoreValue(merged, operation.data));
        counters.writes++;
      }
      return result;
    },
  };
  return {db, documents, counters};
}

/**
 * @param {string} eventId Unique event ID.
 * @param {string} eventName Event name.
 * @param {string} platform Platform.
 * @return {Object} Callable request.
 */
function createRequest(
    eventId = "test_event_00000001",
    eventName = "app_started",
    platform = "web",
) {
  return {
    auth: {uid: "test-user-001"},
    data: {eventId, eventName, platform},
  };
}

/**
 * @param {Object} fake Fake Firestore.
 * @param {Date} now Server time.
 * @return {Function} Tracking handler.
 */
function createHandler(fake, now = NOW) {
  return createTrackingHandler(fake.db, {
    config: createTestConfig(true),
    nowProvider: () => now,
    fieldValue: fakeFieldValue,
  });
}

/**
 * @param {Object} fake Fake Firestore.
 * @param {string} day UTC day.
 * @return {Object} Daily aggregate.
 */
function getDaily(fake, day = "2026-11-05") {
  return fake.documents.get(
      `monitoringV2Test/test-generation/daily/${day}`,
  );
}

test("Disabled monitoring does not write data", async () => {
  const fake = createFakeFirestore();
  const handler = createTrackingHandler(fake.db, {
    config: createTestConfig(false), nowProvider: () => NOW,
    fieldValue: fakeFieldValue,
  });
  assert.deepEqual(await handler(createRequest()), {
    recorded: false, reason: "monitoring_disabled",
  });
  assert.equal(fake.counters.transactions, 0);
  assert.equal(fake.counters.writes, 0);
});

test("First event is recorded with nested counters and platform", async () => {
  const fake = createFakeFirestore();
  const result = await createHandler(fake)(createRequest());
  assert.deepEqual(result, {
    recorded: true, duplicate: false, newUser: true, newActiveDay: true,
  });
  assert.equal(fake.counters.transactions, 1);
  assert.equal(fake.counters.writes, 4);
  assert.equal(getDaily(fake).eventCount, 1);
  assert.equal(getDaily(fake).activeUsers, 1);
  assert.equal(getDaily(fake).newUsers, 1);
  assert.deepEqual(getDaily(fake).events, {app_started: 1});
  assert.equal(Object.hasOwn(getDaily(fake), "events.app_started"), false);
  const event = [...fake.documents.entries()].find(([key]) =>
    key.includes("/events/"))[1];
  assert.equal(event.platform, "web");
});

test("Duplicate event is ignored without counter changes", async () => {
  const fake = createFakeFirestore();
  const handler = createHandler(fake);
  const request = createRequest();
  await handler(request);
  const before = fake.counters.writes;
  assert.deepEqual(await handler(request), {recorded: false, duplicate: true});
  assert.equal(fake.counters.writes, before);
  assert.equal(getDaily(fake).eventCount, 1);
});

test("Second event increments only event counters", async () => {
  const fake = createFakeFirestore();
  const handler = createHandler(fake);
  await handler(createRequest());
  const result = await handler(createRequest(
      "test_event_00000002", "calculation_completed", "android"));
  assert.equal(result.newUser, false);
  assert.equal(result.newActiveDay, false);
  assert.equal(getDaily(fake).eventCount, 2);
  assert.equal(getDaily(fake).activeUsers, 1);
  assert.equal(getDaily(fake).newUsers, 1);
  assert.deepEqual(getDaily(fake).events, {
    app_started: 1, calculation_completed: 1,
  });
});

test("Same event type increments its nested counter", async () => {
  const fake = createFakeFirestore();
  const handler = createHandler(fake);
  await handler(createRequest());
  await handler(createRequest("test_event_00000002"));
  assert.equal(getDaily(fake).events.app_started, 2);
});

test("New UTC day adds one active day, not another new user", async () => {
  const fake = createFakeFirestore();
  await createHandler(fake)(createRequest());
  const tomorrow = new Date("2026-11-06T12:00:00.000Z");
  const result = await createHandler(fake, tomorrow)(
      createRequest("test_event_00000002"));
  assert.equal(result.newUser, false);
  assert.equal(result.newActiveDay, true);
  assert.equal(getDaily(fake, "2026-11-06").activeUsers, 1);
  assert.equal(getDaily(fake, "2026-11-06").newUsers, undefined);
});

test("Unauthenticated calls are rejected", async () => {
  const fake = createFakeFirestore();
  await assert.rejects(createHandler(fake)({data: createRequest().data}),
      (error) => error.code === "unauthenticated");
  assert.equal(fake.counters.writes, 0);
});

test("Unsupported events are rejected", async () => {
  const fake = createFakeFirestore();
  await assert.rejects(createHandler(fake)(createRequest(
      "test_event_00000004", "unknown_event")),
  (error) => error.code === "invalid-argument");
  assert.equal(fake.counters.writes, 0);
});

test("Unsupported platforms are rejected", async () => {
  const fake = createFakeFirestore();
  await assert.rejects(createHandler(fake)(createRequest(
      "test_event_00000004", "app_started", "untrusted")),
  (error) => error.code === "invalid-argument");
  assert.equal(fake.counters.writes, 0);
});

test("Missing platform is rejected", async () => {
  const fake = createFakeFirestore();
  const request = createRequest();
  delete request.data.platform;
  await assert.rejects(createHandler(fake)(request),
      (error) => error.code === "invalid-argument");
});

test("Screen events require a supported screen", async () => {
  const fake = createFakeFirestore();
  const handler = createHandler(fake);
  const request = createRequest("test_event_00000003", "screen_viewed");
  await assert.rejects(handler(request),
      (error) => error.code === "invalid-argument");
  request.data.screenName = "dashboard";
  assert.equal((await handler(request)).recorded, true);
  const event = [...fake.documents.entries()].find(([key]) =>
    key.includes("/events/"))[1];
  assert.equal(event.screenName, "dashboard");
});

test("Unknown properties are discarded", () => {
  const sanitized = validateEvent({
    eventId: "test_event_00000001", eventName: "app_started",
    platform: "web", secret: "not persisted",
  });
  assert.equal(Object.hasOwn(sanitized, "secret"), false);
});

test("Events before start date are ignored", async () => {
  const fake = createFakeFirestore();
  const handler = createHandler(fake,
      new Date("2026-11-04T23:00:00.000Z"));
  assert.deepEqual(await handler(createRequest()), {
    recorded: false, reason: "before_monitoring_start",
  });
  assert.equal(fake.counters.writes, 0);
});

/**
 * @param {Object} fake Fake Firestore.
 * @param {Object} data Access status.
 * @return {void}
 */
function setTrial(fake, data) {
  fake.documents.set("users/test-user-001/appData/main", data);
}

test("Trial start requires server-side access data", async () => {
  const fake = createFakeFirestore();
  const result = await createHandler(fake)(createRequest(
      "trial_start_event_0001", "trial_started"));
  assert.deepEqual(result, {recorded: false, reason: "ineligible_trial"});
  assert.equal(fake.counters.writes, 0);
});

test("Valid trial start is recorded only once across event IDs", async () => {
  const fake = createFakeFirestore();
  setTrial(fake, {trialUsed: true, trialStart: TRIAL_START});
  const handler = createHandler(fake);
  assert.equal((await handler(createRequest(
      "trial_start_event_0001", "trial_started"))).recorded, true);
  const writes = fake.counters.writes;
  assert.deepEqual(await handler(createRequest(
      "trial_start_event_0002", "trial_started")),
  {recorded: false, duplicate: true});
  assert.equal(fake.counters.writes, writes);
  assert.equal(getDaily(fake).events.trial_started, 1);
});

test("Trial events reject starts before monitoring generation", async () => {
  const fake = createFakeFirestore();
  setTrial(fake, {trialUsed: true,
    trialStart: "2026-11-04T23:59:59.000Z"});
  const result = await createHandler(fake)(createRequest(
      "trial_start_event_0001", "trial_started"));
  assert.deepEqual(result, {recorded: false, reason: "ineligible_trial"});
  assert.equal(fake.counters.writes, 0);
});

test("Trial start rejects invalid and future timestamps", async () => {
  const fake = createFakeFirestore();
  const handler = createHandler(fake);
  for (const trialStart of ["invalid", "2026-11-06T00:00:00.000Z"]) {
    setTrial(fake, {trialUsed: true, trialStart});
    assert.equal((await handler(createRequest(
        "trial_start_event_0001", "trial_started"))).recorded, false);
  }
  assert.equal(fake.counters.writes, 0);
});

test("Trial expiry is rejected before seven days", async () => {
  const fake = createFakeFirestore();
  setTrial(fake, {trialUsed: true, trialStart: TRIAL_START});
  const result = await createHandler(fake)(createRequest(
      "trial_expiry_event_001", "trial_expired"));
  assert.deepEqual(result, {recorded: false, reason: "trial_not_expired"});
  assert.equal(fake.counters.writes, 0);
});

test("Expired trial is recorded once, separately from trial start",
    async () => {
      const fake = createFakeFirestore();
      setTrial(fake, {trialUsed: true, trialStart: TRIAL_START});
      const handler = createHandler(fake,
          new Date("2026-11-12T01:00:00.000Z"));
      assert.equal((await handler(createRequest(
          "trial_start_event_0001", "trial_started"))).recorded, true);
      assert.equal((await handler(createRequest(
          "trial_expiry_event_001", "trial_expired"))).recorded, true);
      const writes = fake.counters.writes;
      assert.deepEqual(await handler(createRequest(
          "trial_expiry_event_002", "trial_expired")),
      {recorded: false, duplicate: true});
      assert.equal(fake.counters.writes, writes);
      assert.equal(getDaily(fake, "2026-11-12").events.trial_started, 1);
      assert.equal(getDaily(fake, "2026-11-12").events.trial_expired, 1);
    });

test("Non-trial events do not require access status", async () => {
  const fake = createFakeFirestore();
  assert.equal((await createHandler(fake)(createRequest())).recorded, true);
});
