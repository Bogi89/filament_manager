
"use strict";

/**
 * FilaLog Monitoring 2.0
 *
 * Automatisierte Tests der Monitoring-Auswertung.
 *
 * Alle Daten sind künstliche Testdaten.
 * Es wird keine Verbindung zu Firebase hergestellt.
 */

const assert = require("node:assert/strict");
const {test} = require("node:test");

const {
  createOverviewHandler,
} = require("./overview");

const NOW = new Date("2026-11-05T12:00:00.000Z");

const ADMIN_UID = "test-monitoring-admin";

/**
 * Erstellt eine kontrollierte Monitoring-Konfiguration.
 *
 * @param {boolean} enabled Monitoring aktiviert.
 * @return {Object} Testkonfiguration.
 */
function createTestConfig(enabled = true) {
  return {
    isMonitoringEnabled: () => enabled,
    isAdmin: (uid) => uid === ADMIN_UID,
    MONITORING_GENERATION: "test-generation",
    COLLECTIONS: {
      generations: "monitoringV2Test",
    },
  };
}

/**
 * Erstellt eine lokale Firestore-Simulation.
 *
 * @param {Array} users Testnutzer.
 * @param {Array} events Testereignisse.
 * @return {Object} Simulierte Datenbank.
 */
function createFakeFirestore(users = [], events = []) {
  const collections = new Map();

  /**
   * Registriert eine simulierte Collection.
   *
   * @param {string} path Collection-Pfad.
   * @param {Array} documents Dokumente.
   * @return {void}
   */
  function registerCollection(path, documents) {
    collections.set(path, documents);
  }

  const root = "monitoringV2Test/test-generation";

  for (const user of users) {
    const userPath = `${root}/users/${user.id}`;

    registerCollection(
        `${userPath}/days`,
        user.days.map((day) => ({
          id: day,
          data: {},
        })),
    );
  }

  registerCollection(
      `${root}/users`,
      users.map((user) => ({
        id: user.id,
        data: {
          firstActiveDay: user.firstDay,
        },
      })),
  );

  registerCollection(
      `${root}/events`,
      events.map((event, index) => ({
        id: `event-${index}`,
        data: event,
      })),
  );

  /**
   * Erstellt eine simulierte Collection-Referenz.
   *
   * @param {string} path Collection-Pfad.
   * @return {Object} Collection-Referenz.
   */
  function collectionReference(path) {
    return {
      limit: (maximum) => ({
        get: async () => {
          const documents =
              (collections.get(path) || []).slice(0, maximum);

          return {
            size: documents.length,
            docs: documents.map((document) => ({
              id: document.id,
              ref: documentReference(
                  `${path}/${document.id}`,
              ),
              data: () => document.data,
            })),
          };
        },
      }),

      doc: (id) =>
        documentReference(`${path}/${id}`),
    };
  }

  /**
   * Erstellt eine simulierte Dokumentreferenz.
   *
   * @param {string} path Dokumentpfad.
   * @return {Object} Dokumentreferenz.
   */
  function documentReference(path) {
    return {
      path,
      collection: (name) =>
        collectionReference(`${path}/${name}`),
    };
  }

  return {
    collection: (name) =>
      collectionReference(name),
  };
}

/**
 * Erstellt einen Administratoraufruf.
 *
 * @return {Object} Firebase Callable Request.
 */
function adminRequest() {
  return {
    auth: {
      uid: ADMIN_UID,
    },
    data: {},
  };
}

/**
 * Erstellt einen Monitoring-Handler für Tests.
 *
 * @param {Object} db Simulierte Datenbank.
 * @param {boolean} enabled Monitoring aktiviert.
 * @return {Function} Monitoring-Handler.
 */
function createHandler(db, enabled = true) {
  return createOverviewHandler(db, {
    config: createTestConfig(enabled),
    nowProvider: () => NOW,
  });
}

/**
 * Liefert Testnutzer für die Aktivitätsauswertung.
 *
 * @return {Array} Testnutzer.
 */
function sampleUsers() {
  return [
    {
      id: "user-a",
      firstDay: "2026-11-01",
      days: [
        "2026-11-01",
        "2026-11-02",
        "2026-11-05",
      ],
    },
    {
      id: "user-b",
      firstDay: "2026-11-03",
      days: [
        "2026-11-03",
        "2026-11-05",
      ],
    },
    {
      id: "user-c",
      firstDay: "2026-10-01",
      days: [
        "2026-10-01",
      ],
    },
    {
      id: "user-d",
      firstDay: "2026-11-05",
      days: [
        "2026-11-05",
      ],
    },
  ];
}

test("Disabled monitoring returns no statistics", async () => {
  const db = createFakeFirestore();
  const handler = createHandler(db, false);

  const result = await handler(adminRequest());

  assert.equal(result.enabled, false);
  assert.equal(result.reason, "monitoring_disabled");
});

test("Administrator can access monitoring", async () => {
  const db = createFakeFirestore();
  const handler = createHandler(db);

  const result = await handler(adminRequest());

  assert.equal(result.enabled, true);
  assert.equal(result.version, 2);
  assert.equal(result.users.totalTracked, 0);
});

test("Unauthenticated requests are rejected", async () => {
  const db = createFakeFirestore();
  const handler = createHandler(db);

  await assert.rejects(
      handler({data: {}}),
      (error) => error.code === "unauthenticated",
  );
});

test("Non-admin users are rejected", async () => {
  const db = createFakeFirestore();
  const handler = createHandler(db);

  await assert.rejects(
      handler({
        auth: {
          uid: "unauthorized-user",
        },
        data: {},
      }),
      (error) => error.code === "permission-denied",
  );
});

test("DAU WAU and MAU count unique users", async () => {
  const db = createFakeFirestore(sampleUsers());
  const handler = createHandler(db);

  const result = await handler(adminRequest());

  assert.equal(result.users.totalTracked, 4);
  assert.equal(result.users.newToday, 1);
  assert.equal(result.users.activeToday, 3);
  assert.equal(result.users.active7Days, 3);
  assert.equal(result.users.active30Days, 3);
  assert.equal(result.users.returning, 2);
});

test("Retention uses eligible cohorts only", async () => {
  const db = createFakeFirestore(sampleUsers());
  const handler = createHandler(db);

  const result = await handler(adminRequest());

  assert.deepEqual(result.retention.day1, {
    day: 1,
    eligibleUsers: 3,
    returnedUsers: 1,
    ratePercent: 33.33,
  });

  assert.deepEqual(result.retention.day7, {
    day: 7,
    eligibleUsers: 1,
    returnedUsers: 0,
    ratePercent: 0,
  });

  assert.deepEqual(result.retention.day30, {
    day: 30,
    eligibleUsers: 1,
    returnedUsers: 0,
    ratePercent: 0,
  });
});

test("Events and screen views are counted", async () => {
  const events = [
    {
      eventName: "app_started",
    },
    {
      eventName: "screen_viewed",
      screenName: "dashboard",
    },
    {
      eventName: "screen_viewed",
      screenName: "calculator",
    },
    {
      eventName: "screen_viewed",
      screenName: "calculator",
    },
    {
      eventName: "calculation_completed",
    },
    {
      eventName: "filament_added",
    },
  ];

  const db = createFakeFirestore([], events);
  const handler = createHandler(db);

  const result = await handler(adminRequest());

  assert.equal(result.usage.totalEvents, 6);
  assert.equal(result.usage.events.app_started, 1);
  assert.equal(result.usage.events.screen_viewed, 3);
  assert.equal(
      result.usage.events.calculation_completed,
      1,
  );
  assert.equal(result.usage.events.filament_added, 1);
  assert.equal(result.usage.screenViews.dashboard, 1);
  assert.equal(result.usage.screenViews.calculator, 2);
});

test("Exceeding user limit is rejected", async () => {
  const users = [];

  for (let index = 0; index < 5001; index++) {
    users.push({
      id: `user-${index}`,
      firstDay: "2026-11-05",
      days: ["2026-11-05"],
    });
  }

  const db = createFakeFirestore(users);
  const handler = createHandler(db);

  await assert.rejects(
      handler(adminRequest()),
      (error) => error.code === "resource-exhausted",
  );
});
