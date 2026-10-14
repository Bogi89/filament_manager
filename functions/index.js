const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");

const {
  FieldValue,
  getFirestore,
} = require("firebase-admin/firestore");

const {
  HttpsError,
  onCall,
  onRequest,
} = require("firebase-functions/v2/https");

const {
  setGlobalOptions,
} = require("firebase-functions/v2");

const {
  onMessagePublished,
} = require("firebase-functions/v2/pubsub");

const {
  defineSecret,
} = require("firebase-functions/params");

const logger = require("firebase-functions/logger");

const crypto = require("node:crypto");

const {Paddle, Environment} = require("@paddle/paddle-node-sdk");
const {google} = require("googleapis");

initializeApp();

const db = getFirestore();

const GOOGLE_PLAY_PACKAGE_NAME = "de.filalog.app";
const GOOGLE_PLAY_PRODUCT_ID = "filalog_premium";

const GOOGLE_PLAY_MONTHLY_BASE_PLAN_ID = "monthly";
const GOOGLE_PLAY_YEARLY_BASE_PLAN_ID = "yearly";

const GOOGLE_PLAY_MONTHLY_AMOUNT_CENTS = 249;
const GOOGLE_PLAY_YEARLY_AMOUNT_CENTS = 1999;
const GOOGLE_PLAY_CURRENCY_CODE = "EUR";

const GOOGLE_PLAY_ENTITLED_STATES = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  "SUBSCRIPTION_STATE_CANCELED",
]);

const googlePlayAuth = new google.auth.GoogleAuth({
  scopes: [
    "https://www.googleapis.com/auth/androidpublisher",
  ],
});

const androidPublisher = google.androidpublisher({
  version: "v3",
  auth: googlePlayAuth,
});

const paypalWebhookId =
    defineSecret("PAYPAL_WEBHOOK_ID");

const paypalClientId =
    defineSecret("PAYPAL_CLIENT_ID");

const paypalClientSecret =
    defineSecret("PAYPAL_CLIENT_SECRET");

const paddleSandboxApiKey =
    defineSecret("PADDLE_API_KEY");

const paddleSandboxWebhookSecret =
    defineSecret("PADDLE_WEBHOOK_SECRET");

const paddleLiveApiKey =
    defineSecret("PADDLE_LIVE_API_KEY");

const paddleLiveWebhookSecret =
    defineSecret("PADDLE_LIVE_WEBHOOK_SECRET");

const PADDLE_SANDBOX_YEARLY_PRICE_ID =
    "pri_01m1d11wsxe99cv3522p6eszj3";

const PADDLE_SANDBOX_PRODUCT_ID =
    "pro_01m1d0mvxnzvjqa2qnmzmxb9zp";

const PADDLE_LIVE_YEARLY_PRICE_ID =
    "pri_01m25gb3x18a0n7h758facnr3f";

const PADDLE_LIVE_PRODUCT_ID =
    "pro_01m25fww5e3177g7p94jxv4qrt";

const PADDLE_YEARLY_AMOUNT = "1999";

const PADDLE_CURRENCY_CODE = "EUR";

const PAYPAL_API_BASE_URL =
    "https://api-m.paypal.com";

const PAYPAL_MONTHLY_PLAN_ID =
    "P-4K319853GS1698522NKHBTJA";

const PAYPAL_YEARLY_PLAN_ID =
    "P-0B954851GR4992613NKHBUAQ";

const PAYPAL_PLAN_IDS = Object.freeze({
  monthly: PAYPAL_MONTHLY_PLAN_ID,
  yearly: PAYPAL_YEARLY_PLAN_ID,
});

const SUBSCRIPTION_EVENT_TYPES = new Set([
  "BILLING.SUBSCRIPTION.ACTIVATED",
  "BILLING.SUBSCRIPTION.CANCELLED",
  "BILLING.SUBSCRIPTION.EXPIRED",
  "BILLING.SUBSCRIPTION.PAYMENT.FAILED",
  "BILLING.SUBSCRIPTION.SUSPENDED",
]);

const PAYMENT_EVENT_TYPES = new Set([
  "PAYMENT.CAPTURE.COMPLETED",
  "PAYMENT.CAPTURE.REFUNDED",
  "PAYMENT.CAPTURE.REVERSED",
  "PAYMENT.SALE.COMPLETED",
  "PAYMENT.SALE.REFUNDED",
  "PAYMENT.SALE.REVERSED",
]);

const SUPPORTED_EVENT_TYPES = new Set([
  ...SUBSCRIPTION_EVENT_TYPES,
  ...PAYMENT_EVENT_TYPES,
]);

setGlobalOptions({
  maxInstances: 10,
});

/**
 * Erstellt die Firestore-Referenz für die Access-Daten eines Benutzers.
 *
 * @param {string} uid Firebase User-ID.
 * @return {FirebaseFirestore.DocumentReference} Firestore-Referenz.
 */
function getUserAccessReference(uid) {
  return db
      .collection("users")
      .doc(uid)
      .collection("appData")
      .doc("main");
}

/**
 * Erfasst einen anonymen Start des FilaLog-Gastmodus.
 *
 * Der Client übermittelt ausschließlich eine zufällige anonyme Gast-ID
 * und die Plattform.
 */
exports.trackGuestStart = onCall(
    {
      region: "europe-west1",
    },
    async (request) => {
      const guestId = request.data && request.data.guestId;
      const platform = request.data && request.data.platform;

      const allowedPlatforms = new Set([
        "web",
        "android",
        "ios",
        "windows",
        "macos",
        "linux",
        "fuchsia",
      ]);

      if (
        typeof guestId !== "string" ||
      !/^[a-f0-9]{32}$/.test(guestId)
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid guest ID.",
        );
      }

      if (
        typeof platform !== "string" ||
      !allowedPlatforms.has(platform)
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid platform.",
        );
      }

      const guestReference = db
          .collection("guestAnalytics")
          .doc(guestId);

      await db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(guestReference);

        if (!snapshot.exists) {
          transaction.set(guestReference, {
            firstStartedAt: FieldValue.serverTimestamp(),
            lastStartedAt: FieldValue.serverTimestamp(),
            startCount: 1,
            platform,
          });

          return;
        }

        transaction.update(guestReference, {
          lastStartedAt: FieldValue.serverTimestamp(),
          startCount: FieldValue.increment(1),
          platform,
        });
      });

      return {
        recorded: true,
      };
    },
);

/**
 * Erfasst einen anonymen App-Start eines bereits aktiven Gastnutzers.
 *
 * Der Client übermittelt ausschließlich die bereits vorhandene
 * zufällige anonyme Gast-ID und die Plattform.
 */
exports.trackGuestActivity = onCall(
    {
      region: "europe-west1",
    },
    async (request) => {
      const guestId = request.data && request.data.guestId;
      const platform = request.data && request.data.platform;

      const allowedPlatforms = new Set([
        "web",
        "android",
        "ios",
        "windows",
        "macos",
        "linux",
        "fuchsia",
      ]);

      if (
        typeof guestId !== "string" ||
      !/^[a-f0-9]{32}$/.test(guestId)
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid guest ID.",
        );
      }

      if (
        typeof platform !== "string" ||
      !allowedPlatforms.has(platform)
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid platform.",
        );
      }

      const guestReference = db
          .collection("guestAnalytics")
          .doc(guestId);

      await db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(guestReference);

        // Activity darf keinen neuen Gast erzeugen.
        // Ein Gast muss zuvor über trackGuestStart registriert worden sein.
        if (!snapshot.exists) {
          return;
        }

        transaction.update(guestReference, {
          lastActiveAt: FieldValue.serverTimestamp(),
          appStartCount: FieldValue.increment(1),
          platform,
        });
      });

      return {
        recorded: true,
      };
    },
);

/**
 * Erfasst den App-Start eines angemeldeten FilaLog-Benutzers.
 *
 * Die Benutzer-ID stammt ausschließlich aus Firebase Authentication.
 * Bestehende App- und Premium-Daten werden nicht verändert.
 */
exports.trackRegisteredUserActivity = onCall(
    {
      region: "europe-west1",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Authentication required.",
        );
      }

      const uid = request.auth.uid;

      const activityReference = db
          .collection("users")
          .doc(uid)
          .collection("monitoring")
          .doc("activity");

      await activityReference.set(
          {
            lastActiveAt: FieldValue.serverTimestamp(),
            appStartCount: FieldValue.increment(1),
          },
          {merge: true},
      );

      return {
        recorded: true,
      };
    },
);

/**
 * Prüft einen Google-Play-Kauftoken serverseitig und aktiviert
 * FilaLog Premium ausschließlich nach erfolgreicher Play-Verifizierung.
 */
exports.verifyGooglePlaySubscription = onCall(
    {
      region: "europe-west1",
      serviceAccount:
      "filalog-play-billing@filament-manager-7d123.iam.gserviceaccount.com",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "You must be signed in.",
        );
      }

      const purchaseToken =
      request.data &&
      typeof request.data.purchaseToken === "string" ?
        request.data.purchaseToken.trim() :
        "";

      if (
        purchaseToken.length === 0 ||
      purchaseToken.length > 4096
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid Google Play purchase token.",
        );
      }

      const uid = request.auth.uid;

      const expectedAccountId = crypto
          .createHash("sha256")
          .update(uid, "utf8")
          .digest("hex");

      try {
        const response =
    await androidPublisher.purchases.subscriptionsv2.get({
      packageName: GOOGLE_PLAY_PACKAGE_NAME,
      token: purchaseToken,
    });

        const subscription = response.data;

        const externalAccountIdentifiers =
  subscription.externalAccountIdentifiers;

        const obfuscatedExternalAccountId =
  externalAccountIdentifiers &&
  typeof externalAccountIdentifiers.obfuscatedExternalAccountId ===
    "string" ?
    externalAccountIdentifiers.obfuscatedExternalAccountId :
    null;

        if (
          obfuscatedExternalAccountId !== expectedAccountId
        ) {
          throw new HttpsError(
              "permission-denied",
              "Google Play purchase does not belong to this account.",
          );
        }

        const lineItems =
        Array.isArray(subscription.lineItems) ?
          subscription.lineItems :
          [];

        const premiumLineItem =
        lineItems.find(
            (lineItem) =>
              lineItem &&
              lineItem.productId === GOOGLE_PLAY_PRODUCT_ID,
        );

        if (!premiumLineItem) {
          throw new HttpsError(
              "failed-precondition",
              "Purchase does not belong to FilaLog Premium.",
          );
        }

        const subscriptionState =
        typeof subscription.subscriptionState === "string" ?
          subscription.subscriptionState :
          "";

        if (
          !GOOGLE_PLAY_ENTITLED_STATES.has(
              subscriptionState,
          )
        ) {
          throw new HttpsError(
              "failed-precondition",
              "Google Play subscription is not active.",
          );
        }

        const expiryTime =
        typeof premiumLineItem.expiryTime === "string" ?
          premiumLineItem.expiryTime :
          null;

        const expiryTimestamp =
        expiryTime ?
          Date.parse(expiryTime) :
          Number.NaN;

        if (
          !Number.isFinite(expiryTimestamp) ||
        expiryTimestamp <= Date.now()
        ) {
          throw new HttpsError(
              "failed-precondition",
              "Google Play subscription has expired.",
          );
        }

        const offerDetails =
        premiumLineItem.offerDetails &&
        typeof premiumLineItem.offerDetails === "object" ?
          premiumLineItem.offerDetails :
          null;

        const basePlanId =
        offerDetails &&
        typeof offerDetails.basePlanId === "string" ?
          offerDetails.basePlanId :
          null;

        if (
          basePlanId !== GOOGLE_PLAY_MONTHLY_BASE_PLAN_ID &&
        basePlanId !== GOOGLE_PLAY_YEARLY_BASE_PLAN_ID
        ) {
          throw new HttpsError(
              "failed-precondition",
              "Unsupported Google Play base plan.",
          );
        }

        const planType =
        basePlanId === GOOGLE_PLAY_MONTHLY_BASE_PLAN_ID ?
          "monthly" :
          "yearly";

        const purchaseTokenHash = crypto
            .createHash("sha256")
            .update(purchaseToken, "utf8")
            .digest("hex");

        const googlePlaySubscriptionReference = db
            .collection("googlePlaySubscriptions")
            .doc(purchaseTokenHash);

        const googlePlayPurchaseReference = db
            .collection("purchaseAnalytics")
            .doc(`google_play_${purchaseTokenHash}`);

        const userAccessReference =
            getUserAccessReference(uid);

        await db.runTransaction(async (transaction) => {
          const existingSubscription =
                  await transaction.get(
                      googlePlaySubscriptionReference,
                  );

          const existingPurchase =
                  await transaction.get(
                      googlePlayPurchaseReference,
                  );

          if (existingPurchase.exists) {
            const existingPurchaseData =
                    existingPurchase.data();

            if (
              existingPurchaseData &&
                  typeof existingPurchaseData.uid === "string" &&
                  existingPurchaseData.uid !== uid
            ) {
              throw new HttpsError(
                  "permission-denied",
                  "Google Play purchase is already linked to another account.",
              );
            }
          }

          if (existingSubscription.exists) {
            const existingData =
            existingSubscription.data();

            if (
              existingData &&
            typeof existingData.uid === "string" &&
            existingData.uid !== uid
            ) {
              throw new HttpsError(
                  "permission-denied",
                  "Google Play purchase is already linked to another account.",
              );
            }
          }

          transaction.set(
              googlePlaySubscriptionReference,
              {
                uid,
                productId: GOOGLE_PLAY_PRODUCT_ID,
                basePlanId,
                subscriptionState,
                expiryTime,
                acknowledgementState:
                subscription.acknowledgementState || null,
                updatedAt: FieldValue.serverTimestamp(),
              },
              {
                merge: true,
              },
          );

          if (!existingPurchase.exists) {
            transaction.set(
                googlePlayPurchaseReference,
                {
                  uid,
                  provider: "google_play",
                  plan: planType,
                  amount:
                    planType === "monthly" ?
                      GOOGLE_PLAY_MONTHLY_AMOUNT_CENTS :
                      GOOGLE_PLAY_YEARLY_AMOUNT_CENTS,
                  currency: GOOGLE_PLAY_CURRENCY_CODE,
                  purchaseTokenHash,
                  productId: GOOGLE_PLAY_PRODUCT_ID,
                  basePlanId,
                  purchasedAt:
                    FieldValue.serverTimestamp(),
                },
            );
          }

          transaction.set(
              userAccessReference,
              {
                premiumActive: true,
                premiumProvider: "google_play",
                premiumPlan: planType,

                googlePlayProductId:
                GOOGLE_PLAY_PRODUCT_ID,

                googlePlayBasePlanId:
                basePlanId,

                googlePlaySubscriptionState:
                subscriptionState,

                googlePlayExpiryTime:
                expiryTime,

                googlePlayAcknowledgementState:
                subscription.acknowledgementState || null,

                googlePlayPurchaseTokenHash:
                purchaseTokenHash,

                googlePlayUpdatedAt:
                FieldValue.serverTimestamp(),
              },
              {
                merge: true,
              },
          );
        });

        logger.info(
            "FilaLog Google Play subscription verified",
            {
              uid,
              productId: GOOGLE_PLAY_PRODUCT_ID,
              basePlanId,
              subscriptionState,
              expiryTime,
            },
        );

        return {
          verified: true,
          premiumActive: true,
          planType,
          subscriptionState,
          expiryTime,
        };
      } catch (error) {
        if (error instanceof HttpsError) {
          throw error;
        }

        logger.error(
            "Google Play subscription verification failed",
            {
              uid,
              message:
              error instanceof Error ?
                error.message :
                "Unknown error",
              code:
              error && typeof error === "object" ?
                error.code || null :
                null,
              status:
                error &&
                typeof error === "object" &&
                error.response ?
                  error.response.status || null :
                  null,
              responseData:
                error &&
                typeof error === "object" &&
                error.response ?
                  error.response.data || null :
                  null,
            },
        );

        throw new HttpsError(
            "internal",
            "Google Play subscription verification failed.",
        );
      }
    },
);

/**
 * Empfängt Google-Play-Entwicklerbenachrichtigungen in Echtzeit.
 *
 * RTDN enthält nur den Hinweis auf eine Statusänderung.
 * Der aktuelle Abozustand wird deshalb anschließend über
 * purchases.subscriptionsv2.get direkt bei Google Play geladen.
 */
exports.googlePlayRtdn = onMessagePublished(
    {
      topic: "filalog-google-play-rtdn",
      region: "europe-west1",
      serviceAccount:
      "filalog-play-billing@filament-manager-7d123.iam.gserviceaccount.com",
    },
    async (event) => {
      const message = event.data &&
      event.data.message ?
        event.data.message :
        null;

      const notification =
      message &&
      message.json &&
      typeof message.json === "object" ?
        message.json :
        null;

      if (!notification) {
        logger.warn(
            "Google Play RTDN ignored: invalid payload",
            {
              messageId:
              message && message.messageId ?
                message.messageId :
                null,
            },
        );

        return;
      }

      if (
        notification.packageName !==
      GOOGLE_PLAY_PACKAGE_NAME
      ) {
        logger.warn(
            "Google Play RTDN ignored: unexpected package",
            {
              packageName:
              notification.packageName || null,
            },
        );

        return;
      }

      if (
        notification.testNotification &&
      typeof notification.testNotification === "object"
      ) {
        logger.info(
            "Google Play RTDN test notification received",
            {
              messageId:
              message && message.messageId ?
                message.messageId :
                null,
            },
        );

        return;
      }

      const subscriptionNotification =
      notification.subscriptionNotification &&
      typeof notification.subscriptionNotification === "object" ?
        notification.subscriptionNotification :
        null;

      if (!subscriptionNotification) {
        logger.info(
            "Google Play RTDN ignored: not a subscription notification",
            {
              messageId:
              message && message.messageId ?
                message.messageId :
                null,
            },
        );

        return;
      }

      const purchaseToken =
      typeof subscriptionNotification.purchaseToken === "string" ?
        subscriptionNotification.purchaseToken.trim() :
        "";

      const notificationType =
      Number.isInteger(
          subscriptionNotification.notificationType,
      ) ?
        subscriptionNotification.notificationType :
        null;

      if (
        purchaseToken.length === 0 ||
      purchaseToken.length > 4096
      ) {
        logger.warn(
            "Google Play RTDN ignored: invalid purchase token",
            {
              notificationType,
            },
        );

        return;
      }

      const purchaseTokenHash = crypto
          .createHash("sha256")
          .update(purchaseToken, "utf8")
          .digest("hex");

      const googlePlaySubscriptionReference = db
          .collection("googlePlaySubscriptions")
          .doc(purchaseTokenHash);

      const mappingSnapshot =
      await googlePlaySubscriptionReference.get();

      if (!mappingSnapshot.exists) {
        logger.warn(
            "Google Play RTDN subscription mapping not found",
            {
              purchaseTokenHash,
              notificationType,
            },
        );

        return;
      }

      const mappingData =
      mappingSnapshot.data();

      const uid =
      mappingData &&
      typeof mappingData.uid === "string" ?
        mappingData.uid :
        null;

      if (!uid) {
        logger.error(
            "Google Play RTDN mapping has no Firebase UID",
            {
              purchaseTokenHash,
              notificationType,
            },
        );

        return;
      }

      const response =
      await androidPublisher.purchases.subscriptionsv2.get({
        packageName: GOOGLE_PLAY_PACKAGE_NAME,
        token: purchaseToken,
      });

      const subscription = response.data;

      const lineItems =
      Array.isArray(subscription.lineItems) ?
        subscription.lineItems :
        [];

      const premiumLineItem =
      lineItems.find(
          (lineItem) =>
            lineItem &&
            lineItem.productId === GOOGLE_PLAY_PRODUCT_ID,
      );

      if (!premiumLineItem) {
        throw new Error(
            "RTDN purchase does not belong to FilaLog Premium",
        );
      }

      const subscriptionState =
      typeof subscription.subscriptionState === "string" ?
        subscription.subscriptionState :
        "";

      const expiryTime =
      typeof premiumLineItem.expiryTime === "string" ?
        premiumLineItem.expiryTime :
        null;

      const offerDetails =
      premiumLineItem.offerDetails &&
      typeof premiumLineItem.offerDetails === "object" ?
        premiumLineItem.offerDetails :
        null;

      const basePlanId =
      offerDetails &&
      typeof offerDetails.basePlanId === "string" ?
        offerDetails.basePlanId :
        null;

      if (
        basePlanId !== GOOGLE_PLAY_MONTHLY_BASE_PLAN_ID &&
      basePlanId !== GOOGLE_PLAY_YEARLY_BASE_PLAN_ID
      ) {
        throw new Error(
            "RTDN contains unsupported Google Play base plan",
        );
      }

      const planType =
      basePlanId === GOOGLE_PLAY_MONTHLY_BASE_PLAN_ID ?
        "monthly" :
        "yearly";

      const expiryTimestamp =
      expiryTime ?
        Date.parse(expiryTime) :
        Number.NaN;

      const premiumActive =
      GOOGLE_PLAY_ENTITLED_STATES.has(
          subscriptionState,
      ) &&
      Number.isFinite(expiryTimestamp) &&
      expiryTimestamp > Date.now();

      const userAccessReference =
      getUserAccessReference(uid);

      await db.runTransaction(
          async (transaction) => {
            const accessSnapshot =
            await transaction.get(
                userAccessReference,
            );

            const accessData =
            accessSnapshot.exists ?
              accessSnapshot.data() :
              null;

            const currentProvider =
            accessData &&
            typeof accessData.premiumProvider === "string" ?
              accessData.premiumProvider :
              null;

            transaction.set(
                googlePlaySubscriptionReference,
                {
                  uid,
                  productId:
                  GOOGLE_PLAY_PRODUCT_ID,
                  basePlanId,
                  subscriptionState,
                  expiryTime,
                  acknowledgementState:
                  subscription.acknowledgementState || null,
                  lastNotificationType:
                  notificationType,
                  lastRtdnMessageId:
                  message && message.messageId ?
                    message.messageId :
                    null,
                  updatedAt:
                  FieldValue.serverTimestamp(),
                },
                {
                  merge: true,
                },
            );

            const googlePlayData = {
              googlePlayProductId:
              GOOGLE_PLAY_PRODUCT_ID,

              googlePlayBasePlanId:
              basePlanId,

              googlePlaySubscriptionState:
              subscriptionState,

              googlePlayExpiryTime:
              expiryTime,

              googlePlayAcknowledgementState:
              subscription.acknowledgementState || null,

              googlePlayPurchaseTokenHash:
              purchaseTokenHash,

              googlePlayLastNotificationType:
              notificationType,

              googlePlayUpdatedAt:
              FieldValue.serverTimestamp(),
            };

            if (
              currentProvider === "google_play" ||
            currentProvider === null
            ) {
              googlePlayData.premiumActive =
              premiumActive;

              googlePlayData.premiumProvider =
              "google_play";

              googlePlayData.premiumPlan =
              planType;
            }

            transaction.set(
                userAccessReference,
                googlePlayData,
                {
                  merge: true,
                },
            );
          },
      );

      logger.info(
          "Google Play RTDN subscription processed",
          {
            uid,
            notificationType,
            subscriptionState,
            basePlanId,
            expiryTime,
            premiumActive,
          },
      );
    },
);

/**
 * Initialisiert den 7-Tage-Test für einen angemeldeten Benutzer.
 *
 * Ein vorhandener Teststatus wird niemals überschrieben.
 * Ein übergebener Gast-Teststart darf nicht nach der Erstellung
 * des Firebase-Kontos liegen.
 */
exports.initializeUserTrial = onCall(
    {
      region: "europe-west1",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Authentication required.",
        );
      }

      const uid = request.auth.uid;

      const userRecord =
        await getAuth().getUser(uid);

      const creationTime =
        userRecord.metadata.creationTime;

      if (!creationTime) {
        throw new HttpsError(
            "failed-precondition",
            "Account creation time is unavailable.",
        );
      }

      const accountCreationDate =
        new Date(creationTime);

      const requestedTrialStart =
        request.data &&
        typeof request.data.trialStart === "string" ?
          new Date(request.data.trialStart) :
          null;

      let trialStart =
        accountCreationDate;

      if (
        requestedTrialStart &&
      !Number.isNaN(
          requestedTrialStart.getTime(),
      ) &&
      requestedTrialStart.getTime() <=
        accountCreationDate.getTime()
      ) {
        trialStart =
          requestedTrialStart;
      }

      const reference =
        getUserAccessReference(uid);

      await db.runTransaction(
          async (transaction) => {
            const snapshot =
              await transaction.get(reference);

            const existingData =
              snapshot.exists ?
                snapshot.data() :
                null;

            if (
              existingData &&
            (
              existingData.trialStart != null ||
              existingData.trialUsed === true
            )
            ) {
              return;
            }

            transaction.set(
                reference,
                {
                  trialStart:
                    trialStart.toISOString(),
                  trialUsed: true,
                },
                {
                  merge: true,
                },
            );
          },
      );

      return {
        initialized: true,
      };
    },
);

/**
 * Erstellt eine interne Übersicht über die vorhandenen
 * FilaLog-Nutzungs- und Abo-Daten.
 *
 * Diese Funktion ist vorerst ausschließlich für die
 * serverseitige Entwicklung vorgesehen.
 */
const MONITORING_START_AT = new Date("2026-09-25T01:30:00+02:00");

exports.getMonitoringOverview = onCall(
    {
      region: "europe-west1",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Authentication required.",
        );
      }

      const monitoringAdminUids = new Set([
        "6ifAvEdTTQUv3Ej16940ir3sRip1",
      ]);

      if (!monitoringAdminUids.has(request.auth.uid)) {
        throw new HttpsError(
            "permission-denied",
            "Monitoring access denied.",
        );
      }

      const authResult =
        await getAuth().listUsers(1000);

      const appDataSnapshot =
      await db
          .collectionGroup("appData")
          .get();

      const guestSnapshot =
          await db
              .collection("guestAnalytics")
              .get();

      const registeredActivitySnapshot =
              await db
                  .collectionGroup("monitoring")
                  .get();

      const purchaseSnapshot =
              await db
                  .collection("purchaseAnalytics")
                  .where("purchasedAt", ">=", MONITORING_START_AT)
                  .get();

      let totalRegistrations = 0;
      let registrationsToday = 0;
      let registrations7Days = 0;
      let registrations30Days = 0;

      let registeredUsersWithFilaments = 0;
      let activeRegisteredToday = 0;
      let activeRegistered7Days = 0;
      let activeRegistered30Days = 0;

      let trialUsers = 0;
      let premiumUsers = 0;
      let manualPremiumUsers = 0;
      let paidPremiumUsers = 0;
      let newPaidPremiumUsers = 0;
      let paddleLiveUsers = 0;
      let paddleSandboxUsers = 0;
      let paddleActiveUsers = 0;
      let paddleCanceledUsers = 0;
      let paddlePausedUsers = 0;
      let paddleScheduledCancelUsers = 0;

      let googlePlayUsers = 0;
      let googlePlayMonthlyUsers = 0;
      let googlePlayYearlyUsers = 0;

      let googlePlayPurchases = 0;
      let googlePlayRevenueCents = 0;

      let googlePlayPurchasesToday = 0;
      let googlePlayPurchases7Days = 0;
      let googlePlayPurchases30Days = 0;

      let googlePlayRevenueTodayCents = 0;
      let googlePlayRevenue7DaysCents = 0;
      let googlePlayRevenue30DaysCents = 0;

      let paddlePurchases = 0;
      let paddleRevenueCents = 0;

      let paddlePurchasesToday = 0;
      let paddlePurchases7Days = 0;
      let paddlePurchases30Days = 0;

      let paddleRevenueTodayCents = 0;
      let paddleRevenue7DaysCents = 0;
      let paddleRevenue30DaysCents = 0;

      let guestStarts = 0;
      let uniqueGuests = 0;
      let guestsToday = 0;
      let guests7Days = 0;
      let guests30Days = 0;

      let guestAppStarts = 0;
      let activeGuestsToday = 0;
      let activeGuests7Days = 0;
      let activeGuests30Days = 0;

      let androidGuests = 0;
      let webGuests = 0;
      let otherPlatformGuests = 0;

      const now = Date.now();

      const startOfToday = new Date();
      startOfToday.setHours(0, 0, 0, 0);

      const sevenDaysAgo =
    now - (7 * 24 * 60 * 60 * 1000);

      const thirtyDaysAgo =
    now - (30 * 24 * 60 * 60 * 1000);

      const recentRegistrations = [];
      const registeredUserUids = new Set();

      for (const user of authResult.users) {
        const creationTime =
      user.metadata &&
      typeof user.metadata.creationTime === "string" ?
        Date.parse(user.metadata.creationTime) :
        NaN;

        if (!Number.isFinite(creationTime)) {
          continue;
        }

        registeredUserUids.add(user.uid);

        if (creationTime < MONITORING_START_AT.getTime()) {
          continue;
        }

        totalRegistrations += 1;

        recentRegistrations.push({
          uid: user.uid,
          createdAt: new Date(creationTime).toISOString(),
        });

        if (creationTime >= startOfToday.getTime()) {
          registrationsToday += 1;
        }

        if (creationTime >= sevenDaysAgo) {
          registrations7Days += 1;
        }

        if (creationTime >= thirtyDaysAgo) {
          registrations30Days += 1;
        }
      }

      recentRegistrations.sort(
          (a, b) =>
            Date.parse(b.createdAt) -
          Date.parse(a.createdAt),
      );

      const latestRegistrations =
        recentRegistrations.slice(0, 10);

      for (const document of appDataSnapshot.docs) {
        if (document.id !== "main") {
          continue;
        }

        const data = document.data();

        const filaments = data.filaments;
        const userUid = document.ref.parent.parent ?
  document.ref.parent.parent.id : null;

        if (
          userUid &&
          registeredUserUids.has(userUid) &&
          Array.isArray(filaments) &&
          filaments.length > 0
        ) {
          registeredUsersWithFilaments += 1;
        }

        const trialStart =
    typeof data.trialStart === "string" ?
      Date.parse(data.trialStart) :
      NaN;

        if (
          Number.isFinite(trialStart) &&
  trialStart >= MONITORING_START_AT.getTime()
        ) {
          trialUsers += 1;
        }

        if (data.premiumActive === true) {
          premiumUsers += 1;

          const hasActivePaddleSubscription =
            data.premiumProvider === "paddle" &&
            data.paddleEnvironment === "live" &&
            data.paddleSubscriptionStatus === "active";

          const hasActiveGooglePlaySubscription =
            data.premiumProvider === "google_play" &&
            GOOGLE_PLAY_ENTITLED_STATES.has(
                data.googlePlaySubscriptionState,
            );

          if (
            hasActivePaddleSubscription ||
            hasActiveGooglePlaySubscription
          ) {
            paidPremiumUsers += 1;
          } else {
            manualPremiumUsers += 1;
          }
        }

        if (
          data.premiumProvider === "paddle" &&
          data.paddleEnvironment === "live"
        ) {
          paddleLiveUsers += 1;

          if (data.paddleSubscriptionStatus === "active") {
            paddleActiveUsers += 1;
          }

          if (data.paddleSubscriptionStatus === "canceled") {
            paddleCanceledUsers += 1;
          }

          if (data.paddleSubscriptionStatus === "paused") {
            paddlePausedUsers += 1;
          }

          if (data.paddleScheduledAction === "cancel") {
            paddleScheduledCancelUsers += 1;
          }
        }

        if (
          data.premiumProvider === "paddle" &&
          data.paddleEnvironment === "sandbox"
        ) {
          paddleSandboxUsers += 1;
        }

        if (data.premiumProvider === "google_play") {
          googlePlayUsers += 1;

          if (data.premiumPlan === "monthly") {
            googlePlayMonthlyUsers += 1;
          }

          if (data.premiumPlan === "yearly") {
            googlePlayYearlyUsers += 1;
          }
        }
      }

      for (const document of guestSnapshot.docs) {
        const data = document.data();

        const firstStartedAt =
          data.firstStartedAt &&
          typeof data.firstStartedAt.toMillis === "function" ?
            data.firstStartedAt.toMillis() :
            null;

        if (
          firstStartedAt === null ||
          firstStartedAt < MONITORING_START_AT.getTime()
        ) {
          continue;
        }

        uniqueGuests += 1;

        if (
          typeof data.startCount === "number" &&
          Number.isFinite(data.startCount)
        ) {
          guestStarts += data.startCount;
        }

        if (
          typeof data.appStartCount === "number" &&
          Number.isFinite(data.appStartCount)
        ) {
          guestAppStarts += data.appStartCount;
        }

        if (data.platform === "android") {
          androidGuests += 1;
        } else if (data.platform === "web") {
          webGuests += 1;
        } else {
          otherPlatformGuests += 1;
        }

        if (firstStartedAt >= startOfToday.getTime()) {
          guestsToday += 1;
        }

        if (firstStartedAt >= sevenDaysAgo) {
          guests7Days += 1;
        }

        if (firstStartedAt >= thirtyDaysAgo) {
          guests30Days += 1;
        }

        const lastActiveAt =
          data.lastActiveAt &&
          typeof data.lastActiveAt.toMillis === "function" ?
            data.lastActiveAt.toMillis() :
            null;

        if (lastActiveAt !== null) {
          if (lastActiveAt >= startOfToday.getTime()) {
            activeGuestsToday += 1;
          }

          if (lastActiveAt >= sevenDaysAgo) {
            activeGuests7Days += 1;
          }

          if (lastActiveAt >= thirtyDaysAgo) {
            activeGuests30Days += 1;
          }
        }
      }

      for (const document of registeredActivitySnapshot.docs) {
        if (document.id !== "activity") {
          continue;
        }

        const monitoringCollection = document.ref.parent;
        const userReference = monitoringCollection.parent;

        if (
          !userReference ||
          userReference.parent.id !== "users" ||
          !registeredUserUids.has(userReference.id)
        ) {
          continue;
        }

        const data = document.data();

        const lastActiveAt =
          data.lastActiveAt &&
          typeof data.lastActiveAt.toMillis === "function" ?
            data.lastActiveAt.toMillis() :
            null;

        if (lastActiveAt === null) {
          continue;
        }

        if (lastActiveAt >= startOfToday.getTime()) {
          activeRegisteredToday += 1;
        }

        if (lastActiveAt >= sevenDaysAgo) {
          activeRegistered7Days += 1;
        }

        if (lastActiveAt >= thirtyDaysAgo) {
          activeRegistered30Days += 1;
        }
      }

      const recentPurchases = [];
      const newPaidPremiumUids = new Set();

      for (const document of purchaseSnapshot.docs) {
        const data = document.data();

        const isPaddlePurchase =
            data.provider === "paddle" &&
            data.environment === "live" &&
            data.currency === PADDLE_CURRENCY_CODE;

        const isGooglePlayPurchase =
            data.provider === "google_play" &&
            data.currency === GOOGLE_PLAY_CURRENCY_CODE;

        if (
          (!isPaddlePurchase && !isGooglePlayPurchase) ||
          typeof data.amount !== "number" ||
          !Number.isFinite(data.amount)
        ) {
          continue;
        }

        if (
          typeof data.uid === "string" &&
          data.uid.length > 0
        ) {
          newPaidPremiumUids.add(data.uid);
        }

        if (isPaddlePurchase) {
          paddlePurchases += 1;
          paddleRevenueCents += data.amount;
        }

        if (isGooglePlayPurchase) {
          googlePlayPurchases += 1;
          googlePlayRevenueCents += data.amount;
        }

        const purchasedAt =
      data.purchasedAt &&
      typeof data.purchasedAt.toMillis === "function" ?
        data.purchasedAt.toMillis() :
        null;

        if (purchasedAt === null) {
          continue;
        }

        recentPurchases.push({
          uid:
            typeof data.uid === "string" ?
              data.uid :
              null,
          provider: data.provider,
          plan:
            typeof data.plan === "string" ?
              data.plan :
              null,
          amount: data.amount,
          currency: data.currency,
          purchasedAt:
            new Date(purchasedAt).toISOString(),
        });

        if (purchasedAt >= startOfToday.getTime()) {
          if (isPaddlePurchase) {
            paddlePurchasesToday += 1;
            paddleRevenueTodayCents += data.amount;
          }

          if (isGooglePlayPurchase) {
            googlePlayPurchasesToday += 1;
            googlePlayRevenueTodayCents += data.amount;
          }
        }

        if (purchasedAt >= sevenDaysAgo) {
          if (isPaddlePurchase) {
            paddlePurchases7Days += 1;
            paddleRevenue7DaysCents += data.amount;
          }

          if (isGooglePlayPurchase) {
            googlePlayPurchases7Days += 1;
            googlePlayRevenue7DaysCents += data.amount;
          }
        }

        if (purchasedAt >= thirtyDaysAgo) {
          if (isPaddlePurchase) {
            paddlePurchases30Days += 1;
            paddleRevenue30DaysCents += data.amount;
          }

          if (isGooglePlayPurchase) {
            googlePlayPurchases30Days += 1;
            googlePlayRevenue30DaysCents += data.amount;
          }
        }
      }

      newPaidPremiumUsers = newPaidPremiumUids.size;

      recentPurchases.sort(
          (a, b) =>
            Date.parse(b.purchasedAt) -
          Date.parse(a.purchasedAt),
      );

      const latestPurchases =
        recentPurchases.slice(0, 10);

      const registrationToPaidConversion =
        totalRegistrations > 0 ?
          (newPaidPremiumUsers / totalRegistrations) * 100 :
          0;

      const trialToPaidConversion =
    trialUsers > 0 ?
      (newPaidPremiumUsers / trialUsers) * 100 :
      0;

      return {
        generatedAt:
        new Date().toISOString(),

        registrations: {
          total:
  authResult.users.length,
          today:
            registrationsToday,
          last7Days:
            registrations7Days,
          last30Days:
            registrations30Days,
          withFilaments:
            registeredUsersWithFilaments,
          activeToday:
            activeRegisteredToday,
          active7Days:
            activeRegistered7Days,
          active30Days:
            activeRegistered30Days,
          recent:
            latestRegistrations,
        },

        trials:
        trialUsers,

        guests: {
          unique:
            uniqueGuests,
          starts:
            guestStarts,
          today:
            guestsToday,
          last7Days:
            guests7Days,
          last30Days:
            guests30Days,

          appStarts:
            guestAppStarts,

          activeToday:
            activeGuestsToday,
          active7Days:
            activeGuests7Days,
          active30Days:
            activeGuests30Days,

          platforms: {
            android:
              androidGuests,
            web:
              webGuests,
            other:
              otherPlatformGuests,
          },
        },

        premium: {
          active:
            premiumUsers,
          manual:
            manualPremiumUsers,
          paid:
            paidPremiumUsers,

          conversion: {
            registrationToPaidPercent:
              registrationToPaidConversion,
            trialToPaidPercent:
              trialToPaidConversion,
          },

          paddle: {
            live:
              paddleLiveUsers,
            sandbox:
              paddleSandboxUsers,
            active:
              paddleActiveUsers,
            canceled:
              paddleCanceledUsers,
            paused:
              paddlePausedUsers,
            scheduledCancel:
              paddleScheduledCancelUsers,
            purchases:
              paddlePurchases,
            revenueCents:
              paddleRevenueCents,

            today: {
              purchases:
                paddlePurchasesToday,
              revenueCents:
                paddleRevenueTodayCents,
            },

            last7Days: {
              purchases:
                paddlePurchases7Days,
              revenueCents:
                paddleRevenue7DaysCents,
            },

            last30Days: {
              purchases:
                paddlePurchases30Days,
              revenueCents:
                paddleRevenue30DaysCents,
            },

            recentPurchases:
              latestPurchases,
          },

          googlePlay: {
            total:
              googlePlayUsers,
            monthly:
              googlePlayMonthlyUsers,
            yearly:
              googlePlayYearlyUsers,
            purchases:
              googlePlayPurchases,
            revenueCents:
              googlePlayRevenueCents,

            today: {
              purchases:
                googlePlayPurchasesToday,
              revenueCents:
                googlePlayRevenueTodayCents,
            },

            last7Days: {
              purchases:
                googlePlayPurchases7Days,
              revenueCents:
                googlePlayRevenue7DaysCents,
            },

            last30Days: {
              purchases:
                googlePlayPurchases30Days,
              revenueCents:
                googlePlayRevenue30DaysCents,
            },
          },
        },
      };
    },
);

/**
 * Aktiviert FilaLog Premium nach einem gültigen Paddle-Jahreskauf.
 *
 * @param {string} uid Firebase User-ID.
 * @param {object} event Verifiziertes Paddle transaction.completed Event.
 * @param {string} environment Paddle-Umgebung.
 * @return {Promise<void>}
 */
async function activatePaddleYearlyPremium(
    uid,
    event,
    environment,
) {
  if (
    typeof uid !== "string" ||
    uid.length === 0 ||
    !event ||
    !event.data ||
    (
      environment !== "live" &&
      environment !== "sandbox"
    )
  ) {
    throw new Error(
        "Invalid Paddle premium activation data",
    );
  }

  const data = event.data;

  const customerId =
      typeof data.customerId === "string" ?
        data.customerId :
        null;

  const subscriptionId =
      typeof data.subscriptionId === "string" ?
        data.subscriptionId :
        null;

  const transactionId =
      typeof data.id === "string" ?
        data.id :
        null;

  if (
    !customerId ||
    !subscriptionId ||
    !transactionId
  ) {
    throw new Error(
        "Missing Paddle identifiers for premium activation",
    );
  }

  const reference =
      getUserAccessReference(uid);

  await reference.set(
      {
        premiumActive: true,
        premiumProvider: "paddle",
        premiumPlan: "yearly",
        paddleEnvironment: environment,

        paddleCustomerId:
            customerId,

        paddleSubscriptionId:
            subscriptionId,

        paddleTransactionId:
            transactionId,

        paddleSubscriptionStatus:
            "active",

        paddleUpdatedAt:
            FieldValue.serverTimestamp(),
      },
      {
        merge: true,
      },
  );

  logger.info(
      "FilaLog Paddle premium activated",
      {
        uid,
        subscriptionId,
        transactionId,
      },
  );
}

/**
 * Speichert den aktiven Paddle-Abozeitraum eines Benutzers.
 *
  * @param {string} uid Firebase User-ID.
 * @param {object} event Verifiziertes Paddle subscription.activated Event.
 * @param {string} environment Paddle-Umgebung.
 * @return {Promise<void>}
 */
async function updatePaddleActiveSubscription(
    uid,
    event,
    environment,
) {
  if (
    typeof uid !== "string" ||
    uid.length === 0 ||
    !event ||
    !event.data ||
    (
      environment !== "live" &&
      environment !== "sandbox"
    )
  ) {
    throw new Error(
        "Invalid Paddle subscription data",
    );
  }

  const data = event.data;

  const subscriptionId =
      typeof data.id === "string" ?
        data.id :
        null;

  const customerId =
      typeof data.customerId === "string" ?
        data.customerId :
        null;

  const billingPeriod =
      data.currentBillingPeriod &&
      typeof data.currentBillingPeriod === "object" ?
        data.currentBillingPeriod :
        null;

  const periodStartsAt =
      billingPeriod &&
      typeof billingPeriod.startsAt === "string" ?
        billingPeriod.startsAt :
        null;

  const periodEndsAt =
      billingPeriod &&
      typeof billingPeriod.endsAt === "string" ?
        billingPeriod.endsAt :
        null;

  const nextBilledAt =
      typeof data.nextBilledAt === "string" ?
        data.nextBilledAt :
        null;

  const occurredAt =
      typeof event.occurredAt === "string" ?
        event.occurredAt :
        null;

  if (
    !subscriptionId ||
    !customerId ||
    !periodStartsAt ||
    !periodEndsAt
  ) {
    throw new Error(
        "Missing Paddle subscription period data",
    );
  }

  const reference =
  getUserAccessReference(uid);

  await db.runTransaction(
      async (transaction) => {
        const snapshot =
        await transaction.get(reference);

        const existingData =
        snapshot.exists ?
          snapshot.data() :
          null;

        const existingEnvironment =
          existingData &&
          typeof existingData.paddleEnvironment === "string" ?
            existingData.paddleEnvironment :
            null;

        if (
          existingEnvironment === "live" &&
          environment === "sandbox"
        ) {
          logger.info(
              "Sandbox Paddle lifecycle event ignored for live subscription",
              {
                uid,
                subscriptionId,
                eventType: event.eventType,
              },
          );

          return;
        }

        const sameEnvironment =
          existingEnvironment === environment;

        const previousOccurredAt =
          sameEnvironment &&
          existingData &&
          typeof existingData
              .paddleLastEventOccurredAt === "string" ?
            existingData
                .paddleLastEventOccurredAt :
            null;

        if (
          previousOccurredAt &&
      occurredAt &&
      Date.parse(previousOccurredAt) >
        Date.parse(occurredAt)
        ) {
          logger.info(
              "Older Paddle subscription event ignored",
              {
                uid,
                subscriptionId,
                previousOccurredAt,
                occurredAt,
              },
          );

          return;
        }

        transaction.set(
            reference,
            {
              premiumActive: true,
              premiumProvider: "paddle",
              premiumPlan: "yearly",
              paddleEnvironment: environment,

              paddleCustomerId:
              customerId,

              paddleSubscriptionId:
              subscriptionId,

              paddleSubscriptionStatus:
              "active",

              paddleCurrentPeriodStart:
              periodStartsAt,

              paddleCurrentPeriodEnd:
              periodEndsAt,

              paddleNextBilledAt:
              nextBilledAt,

              paddleLastWebhookEvent:
              event.eventType,

              paddleLastWebhookEventId:
              event.eventId,

              paddleLastEventOccurredAt:
              occurredAt,

              paddleUpdatedAt:
              FieldValue.serverTimestamp(),
            },
            {
              merge: true,
            },
        );
      },
  );

  logger.info(
      "FilaLog Paddle subscription activated",
      {
        uid,
        subscriptionId,
        periodEndsAt,
      },
  );
}

/**
 * Speichert den neuesten Paddle Subscription-Lifecycle-Stand.
 *
 * Ältere Webhook-Events dürfen einen bereits neueren
 * Subscription-Stand nicht überschreiben.
 *
  * @param {string} uid Firebase User-ID.
 * @param {object} event Verifiziertes Paddle Subscription-Event.
 * @param {string} environment Paddle-Umgebung.
 * @return {Promise<void>}
 */
async function updatePaddleSubscriptionLifecycle(
    uid,
    event,
    environment,
) {
  if (
    typeof uid !== "string" ||
    uid.length === 0 ||
    !event ||
    !event.data ||
    (
      environment !== "live" &&
      environment !== "sandbox"
    )
  ) {
    throw new Error(
        "Invalid Paddle subscription lifecycle data",
    );
  }

  const data = event.data;

  const subscriptionId =
    typeof data.id === "string" ?
      data.id :
      null;

  const status =
    typeof data.status === "string" ?
      data.status :
      null;

  const rawScheduledChange =
      data.scheduledChange &&
      typeof data.scheduledChange === "object" ?
        data.scheduledChange :
        null;

  const scheduledChange =
      rawScheduledChange ?
        {
          action:
              typeof rawScheduledChange.action === "string" ?
                rawScheduledChange.action :
                null,
          effectiveAt:
              typeof rawScheduledChange.effectiveAt === "string" ?
                rawScheduledChange.effectiveAt :
                null,
          resumeAt:
              typeof rawScheduledChange.resumeAt === "string" ?
                rawScheduledChange.resumeAt :
                null,
        } :
        null;

  const currentBillingPeriod =
        data.currentBillingPeriod &&
        typeof data.currentBillingPeriod === "object" ?
          data.currentBillingPeriod :
          null;

  const periodStartsAt =
        currentBillingPeriod &&
        typeof currentBillingPeriod.startsAt === "string" ?
          currentBillingPeriod.startsAt :
          null;

  const periodEndsAt =
        currentBillingPeriod &&
        typeof currentBillingPeriod.endsAt === "string" ?
          currentBillingPeriod.endsAt :
          null;

  const nextBilledAt =
        typeof data.nextBilledAt === "string" ?
          data.nextBilledAt :
          null;

  const occurredAt =
    typeof event.occurredAt === "string" ?
      event.occurredAt :
      null;

  const scheduledAction =
      scheduledChange &&
      typeof scheduledChange.action === "string" ?
        scheduledChange.action :
        null;

  if (
    !subscriptionId ||
  !status ||
  !occurredAt
  ) {
    throw new Error(
        "Missing Paddle subscription lifecycle data",
    );
  }

  const reference =
    getUserAccessReference(uid);

  await db.runTransaction(
      async (transaction) => {
        const snapshot =
          await transaction.get(reference);

        const existingData =
          snapshot.exists ?
            snapshot.data() :
            null;

        const existingEnvironment =
          existingData &&
          typeof existingData.paddleEnvironment === "string" ?
            existingData.paddleEnvironment :
            null;

        if (
          existingEnvironment === "live" &&
          environment === "sandbox"
        ) {
          logger.info(
              "Sandbox Paddle lifecycle event ignored for live subscription",
              {
                uid,
                subscriptionId,
                eventType: event.eventType,
              },
          );

          return;
        }

        const sameEnvironment =
          existingEnvironment === environment;

        const previousOccurredAt =
          sameEnvironment &&
          existingData &&
          typeof existingData
              .paddleLastEventOccurredAt === "string" ?
            existingData
                .paddleLastEventOccurredAt :
            null;

        const previousEventType =
            sameEnvironment &&
            existingData &&
            typeof existingData
                .paddleLastWebhookEvent === "string" ?
              existingData
                  .paddleLastWebhookEvent :
              null;

        if (
          previousOccurredAt &&
            Date.parse(previousOccurredAt) ===
              Date.parse(occurredAt) &&
            previousEventType ===
              "subscription.canceled" &&
            event.eventType ===
              "subscription.updated"
        ) {
          logger.info(
              "Equal-time Paddle update ignored after canceled",
              {
                uid,
                subscriptionId,
                previousEventType,
                eventType: event.eventType,
                occurredAt,
              },
          );

          return;
        }

        if (
          previousOccurredAt &&
        Date.parse(previousOccurredAt) >
          Date.parse(occurredAt)
        ) {
          logger.info(
              "Older Paddle lifecycle event ignored",
              {
                uid,
                subscriptionId,
                eventType: event.eventType,
                previousOccurredAt,
                occurredAt,
              },
          );

          return;
        }

        if (
          event.eventType === "subscription.canceled"
        ) {
          transaction.set(
              reference,
              {
                premiumActive: false,
              },
              {
                merge: true,
              },
          );
        }

        if (
          event.eventType === "subscription.resumed"
        ) {
          transaction.set(
              reference,
              {
                premiumActive: true,
              },
              {
                merge: true,
              },
          );
        }

        if (
          event.eventType === "subscription.paused"
        ) {
          transaction.set(
              reference,
              {
                premiumActive: false,
              },
              {
                merge: true,
              },
          );
        }

        transaction.set(
            reference,
            {
              paddleEnvironment:
              environment,

              paddleSubscriptionId:
                subscriptionId,

              paddleSubscriptionStatus:
                status,

              paddleCurrentPeriodStart:
                periodStartsAt,

              paddleCurrentPeriodEnd:
                periodEndsAt,

              paddleNextBilledAt:
                nextBilledAt,

              paddleScheduledChange:
                scheduledChange,

              paddleScheduledAction:
                scheduledAction,

              paddleLastWebhookEvent:
                event.eventType,

              paddleLastWebhookEventId:
                event.eventId,

              paddleLastEventOccurredAt:
                occurredAt,

              paddleUpdatedAt:
                FieldValue.serverTimestamp(),
            },
            {
              merge: true,
            },
        );
      },
  );
}

/**
 * Holt ein OAuth-Access-Token von der PayPal-Live-API.
 *
 * @return {Promise<string>} Gültiges PayPal Access Token.
 */
async function getPayPalAccessToken() {
  const clientId = paypalClientId.value();
  const clientSecret = paypalClientSecret.value();

  if (!clientId || !clientSecret) {
    throw new Error(
        "PayPal client credentials are missing",
    );
  }

  const credentials = Buffer.from(
      `${clientId}:${clientSecret}`,
  ).toString("base64");

  const apiResponse = await fetch(
      `${PAYPAL_API_BASE_URL}/v1/oauth2/token`,
      {
        method: "POST",
        headers: {
          "Authorization": `Basic ${credentials}`,
          "Content-Type":
              "application/x-www-form-urlencoded",
        },
        body: "grant_type=client_credentials",
      },
  );

  if (!apiResponse.ok) {
    const responseText =
        await apiResponse.text();

    logger.error(
        "Failed to obtain PayPal access token",
        {
          status: apiResponse.status,
          response: responseText,
        },
    );

    throw new Error(
        "PayPal access token request failed",
    );
  }

  const data = await apiResponse.json();

  if (
    !data ||
    typeof data.access_token !== "string" ||
    data.access_token.length === 0
  ) {
    throw new Error(
        "PayPal access token missing",
    );
  }

  return data.access_token;
}

/**
 * Führt einen authentifizierten Request an die PayPal-Live-API aus.
 *
 * @param {string} path API-Pfad.
 * @param {object} options Fetch-Optionen.
 * @return {Promise<object>} PayPal JSON-Antwort.
 */
async function payPalRequest(
    path,
    options = {},
) {
  const accessToken =
      await getPayPalAccessToken();

  const headers = {
    "Authorization": `Bearer ${accessToken}`,
    "Content-Type": "application/json",
    ...(options.headers || {}),
  };

  const apiResponse = await fetch(
      `${PAYPAL_API_BASE_URL}${path}`,
      {
        ...options,
        headers,
      },
  );

  const responseText =
      await apiResponse.text();

  let data = null;

  if (responseText) {
    try {
      data = JSON.parse(responseText);
    } catch (_) {
      data = {
        rawResponse: responseText,
      };
    }
  }

  if (!apiResponse.ok) {
    logger.error(
        "PayPal API request failed",
        {
          path,
          status: apiResponse.status,
          response: data,
        },
    );

    throw new Error(
        `PayPal API request failed: ${apiResponse.status}`,
    );
  }

  return data || {};
}

/**
 * Liest einen erforderlichen HTTP-Header aus dem Request.
 *
 * @param {object} request Eingehender HTTP-Request.
 * @param {string} headerName Name des benötigten Headers.
 * @return {string} Header-Wert.
 */
function getRequiredHeader(
    request,
    headerName,
) {
  const value =
      request.get(headerName);

  if (!value) {
    throw new Error(
        `Missing PayPal header: ${headerName}`,
    );
  }

  return value;
}

/**
 * Verifiziert einen eingehenden PayPal-Webhook.
 *
 * @param {object} request Eingehender HTTP-Request.
 * @param {object} webhookEvent PayPal-WebHook-Event.
 * @return {Promise<boolean>} True bei gültiger Signatur.
 */
async function verifyPayPalWebhook(
    request,
    webhookEvent,
) {
  const transmissionId =
      getRequiredHeader(
          request,
          "paypal-transmission-id",
      );

  const transmissionTime =
      getRequiredHeader(
          request,
          "paypal-transmission-time",
      );

  const transmissionSignature =
      getRequiredHeader(
          request,
          "paypal-transmission-sig",
      );

  const certificateUrl =
      getRequiredHeader(
          request,
          "paypal-cert-url",
      );

  const authenticationAlgorithm =
      getRequiredHeader(
          request,
          "paypal-auth-algo",
      );

  const accessToken =
      await getPayPalAccessToken();

  const verificationResponse =
      await fetch(
          `${PAYPAL_API_BASE_URL}` +
          "/v1/notifications/" +
          "verify-webhook-signature",
          {
            method: "POST",
            headers: {
              "Authorization":
                  `Bearer ${accessToken}`,
              "Content-Type":
                  "application/json",
            },
            body: JSON.stringify({
              auth_algo:
                  authenticationAlgorithm,
              cert_url:
                  certificateUrl,
              transmission_id:
                  transmissionId,
              transmission_sig:
                  transmissionSignature,
              transmission_time:
                  transmissionTime,
              webhook_id:
                  paypalWebhookId.value(),
              webhook_event:
                  webhookEvent,
            }),
          },
      );

  if (!verificationResponse.ok) {
    const responseText =
        await verificationResponse.text();

    logger.error(
        "PayPal webhook verification request failed",
        {
          status:
              verificationResponse.status,
          response:
              responseText,
        },
    );

    return false;
  }

  const verificationData =
      await verificationResponse.json();

  return verificationData.verification_status ===
      "SUCCESS";
}

/**
 * Prüft, ob eine übergebene Plan-ID zu FilaLog gehört.
 *
 * @param {string} planId PayPal Plan-ID.
 * @return {boolean} True bei erlaubtem FilaLog-Plan.
 */
function isSupportedPlanId(planId) {
  return planId ===
          PAYPAL_MONTHLY_PLAN_ID ||
      planId ===
          PAYPAL_YEARLY_PLAN_ID;
}

/**
 * Ermittelt den internen Plannamen anhand der PayPal Plan-ID.
 *
 * @param {string} planId PayPal Plan-ID.
 * @return {string|null} monthly, yearly oder null.
 */
function getPlanTypeFromId(planId) {
  if (planId === PAYPAL_MONTHLY_PLAN_ID) {
    return "monthly";
  }

  if (planId === PAYPAL_YEARLY_PLAN_ID) {
    return "yearly";
  }

  return null;
}

/**
 * Lädt ein PayPal-Abonnement.
 *
 * @param {string} subscriptionId PayPal Subscription-ID.
 * @return {Promise<object>} Subscription-Daten.
 */
async function getPayPalSubscription(
    subscriptionId,
) {
  return payPalRequest(
      `/v1/billing/subscriptions/${subscriptionId}`,
      {
        method: "GET",
      },
  );
}

/**
 * Sucht die Firebase-UID anhand einer gespeicherten Subscription-ID.
 *
 * @param {string} subscriptionId PayPal Subscription-ID.
 * @return {Promise<string|null>} UID oder null.
 */
async function findUidBySubscriptionId(
    subscriptionId,
) {
  const snapshot = await db
      .collectionGroup("appData")
      .where(
          "paypalSubscriptionId",
          "==",
          subscriptionId,
      )
      .limit(1)
      .get();

  if (snapshot.empty) {
    return null;
  }

  const document =
      snapshot.docs[0];

  const userDocument =
      document.ref.parent.parent;

  if (!userDocument) {
    return null;
  }

  return userDocument.id;
}

/**
 * Ermittelt die Firebase-UID für ein Subscription-Webhook.
 *
 * @param {object} resource PayPal Webhook-Resource.
 * @return {Promise<string|null>} Firebase UID oder null.
 */
async function resolveUidForSubscription(
    resource,
) {
  if (
    resource &&
    typeof resource.custom_id === "string" &&
    resource.custom_id.length > 0
  ) {
    return resource.custom_id;
  }

  const subscriptionId =
      resource &&
      typeof resource.id === "string" ?
        resource.id :
        null;

  if (!subscriptionId) {
    return null;
  }

  const mappedUid =
      await findUidBySubscriptionId(
          subscriptionId,
      );

  if (mappedUid) {
    return mappedUid;
  }

  try {
    const subscription =
        await getPayPalSubscription(
            subscriptionId,
        );

    if (
      typeof subscription.custom_id === "string" &&
      subscription.custom_id.length > 0
    ) {
      return subscription.custom_id;
    }
  } catch (error) {
    logger.warn(
        "Could not resolve PayPal subscription owner",
        {
          subscriptionId,
          message:
              error instanceof Error ?
                error.message :
                "Unknown error",
        },
    );
  }

  return null;
}

/**
 * Verarbeitet ein PayPal Subscription-Event.
 *
 * @param {object} webhookEvent PayPal Webhook-Event.
 * @return {Promise<void>}
 */
async function processSubscriptionEvent(
    webhookEvent,
) {
  const resource =
      webhookEvent.resource || {};

  const eventType =
      webhookEvent.event_type;

  const subscriptionId =
      typeof resource.id === "string" ?
        resource.id :
        null;

  if (!subscriptionId) {
    throw new Error(
        "PayPal subscription ID missing",
    );
  }

  const uid =
      await resolveUidForSubscription(
          resource,
      );

  if (!uid) {
    throw new Error(
        "Firebase user for PayPal subscription not found",
    );
  }

  let planId =
      typeof resource.plan_id === "string" ?
        resource.plan_id :
        null;

  if (!planId) {
    const subscription =
        await getPayPalSubscription(
            subscriptionId,
        );

    planId =
        typeof subscription.plan_id === "string" ?
          subscription.plan_id :
          null;
  }

  if (!planId || !isSupportedPlanId(planId)) {
    throw new Error(
        "Unsupported PayPal subscription plan",
    );
  }

  const reference =
      getUserAccessReference(uid);

  const updateData = {
    paypalSubscriptionId:
        subscriptionId,
    paypalPlanId:
        planId,
    paypalPlanType:
        getPlanTypeFromId(planId),
    paypalLastWebhookEvent:
        eventType,
    paypalLastWebhookEventId:
        webhookEvent.id,
    paypalUpdatedAt:
        FieldValue.serverTimestamp(),
  };

  if (
    eventType ===
    "BILLING.SUBSCRIPTION.ACTIVATED"
  ) {
    updateData.premiumActive = true;
    updateData.paypalSubscriptionStatus =
        "ACTIVE";
    updateData.paypalPaymentFailed = false;
  } else if (
    eventType ===
    "BILLING.SUBSCRIPTION.CANCELLED"
  ) {
    updateData.premiumActive = false;
    updateData.paypalSubscriptionStatus =
        "CANCELLED";
  } else if (
    eventType ===
    "BILLING.SUBSCRIPTION.EXPIRED"
  ) {
    updateData.premiumActive = false;
    updateData.paypalSubscriptionStatus =
        "EXPIRED";
  } else if (
    eventType ===
    "BILLING.SUBSCRIPTION.SUSPENDED"
  ) {
    updateData.premiumActive = false;
    updateData.paypalSubscriptionStatus =
        "SUSPENDED";
  } else if (
    eventType ===
    "BILLING.SUBSCRIPTION.PAYMENT.FAILED"
  ) {
    updateData.paypalPaymentFailed = true;
    updateData.paypalSubscriptionStatus =
        typeof resource.status === "string" ?
          resource.status :
          "PAYMENT_FAILED";
  }

  await reference.set(
      updateData,
      {
        merge: true,
      },
  );

  logger.info(
      "FilaLog premium status updated",
      {
        uid,
        eventType,
        subscriptionId,
        planId,
        premiumActive:
            updateData.premiumActive,
      },
  );
}

/**
 * Reserviert ein PayPal Webhook-Event zur einmaligen Verarbeitung.
 *
 * @param {string} eventId PayPal Event-ID.
 * @param {string} eventType PayPal Event-Typ.
 * @return {Promise<boolean>} True bei neuer Reservierung.
 */
async function reserveWebhookEvent(
    eventId,
    eventType,
) {
  const reference = db
      .collection("paypalWebhookEvents")
      .doc(eventId);

  try {
    await reference.create({
      eventType,
      processingStatus: "PROCESSING",
      createdAt:
          FieldValue.serverTimestamp(),
    });

    return true;
  } catch (error) {
    if (
      error &&
      (
        error.code === 6 ||
        error.code === "already-exists"
      )
    ) {
      return false;
    }

    throw error;
  }
}

/**
 * Markiert ein erfolgreich verarbeitetes Webhook-Event.
 *
 * @param {string} eventId PayPal Event-ID.
 * @return {Promise<void>}
 */
async function completeWebhookEvent(
    eventId,
) {
  await db
      .collection("paypalWebhookEvents")
      .doc(eventId)
      .set(
          {
            processingStatus: "COMPLETED",
            completedAt:
                FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
      );
}

/**
 * Entfernt eine fehlgeschlagene Webhook-Reservierung.
 *
 * Dadurch darf PayPal das Event später erneut zustellen.
 *
 * @param {string} eventId PayPal Event-ID.
 * @return {Promise<void>}
 */
async function releaseWebhookEvent(
    eventId,
) {
  await db
      .collection("paypalWebhookEvents")
      .doc(eventId)
      .delete();
}

/**
 * Erstellt ein PayPal Live-Abonnement für einen
 * angemeldeten Firebase-Benutzer.
 */
exports.createPayPalSubscription = onCall(
    {
      region: "europe-west1",
      secrets: [
        paypalClientId,
        paypalClientSecret,
      ],
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "You must be signed in.",
        );
      }

      const planType =
          request.data &&
          typeof request.data.planType === "string" ?
            request.data.planType :
            null;

      const planId =
          planType ?
            PAYPAL_PLAN_IDS[planType] :
            null;

      if (!planId) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid FilaLog subscription plan.",
        );
      }

      const uid =
          request.auth.uid;

      try {
        const subscription =
            await payPalRequest(
                "/v1/billing/subscriptions",
                {
                  method: "POST",
                  headers: {
                    "PayPal-Request-Id":
                        `${uid}-${Date.now()}`,
                  },
                  body: JSON.stringify({
                    plan_id: planId,
                    custom_id: uid,
                    application_context: {
                      brand_name: "FilaLog",
                      user_action:
                          "SUBSCRIBE_NOW",
                      return_url:
                          "https://filament-manager-7d123.web.app",
                      cancel_url:
                          "https://filament-manager-7d123.web.app",
                    },
                  }),
                },
            );

        if (
          !subscription ||
          typeof subscription.id !== "string"
        ) {
          throw new Error(
              "PayPal subscription ID missing",
          );
        }

        const links =
            Array.isArray(subscription.links) ?
              subscription.links :
              [];

        const approvalLink =
            links.find(
                (link) =>
                  link &&
                  link.rel === "approve" &&
                  typeof link.href === "string",
            );

        if (!approvalLink) {
          throw new Error(
              "PayPal approval URL missing",
          );
        }

        await getUserAccessReference(uid).set(
            {
              paypalSubscriptionId:
                  subscription.id,
              paypalPlanId:
                  planId,
              paypalPlanType:
                  planType,
              paypalSubscriptionStatus:
                  subscription.status ||
                  "APPROVAL_PENDING",
              paypalPaymentFailed:
                  false,
              paypalUpdatedAt:
                  FieldValue.serverTimestamp(),
            },
            {
              merge: true,
            },
        );

        logger.info(
            "PayPal subscription created",
            {
              uid,
              planType,
              planId,
              subscriptionId:
                  subscription.id,
            },
        );

        return {
          subscriptionId:
              subscription.id,
          approvalUrl:
              approvalLink.href,
          planType,
        };
      } catch (error) {
        logger.error(
            "Creating PayPal subscription failed",
            {
              uid,
              planType,
              message:
                  error instanceof Error ?
                    error.message :
                    "Unknown error",
            },
        );

        throw new HttpsError(
            "internal",
            "Could not create PayPal subscription.",
        );
      }
    },
);

/**
 * Empfängt und verifiziert PayPal Live-Webhooks.
 */
exports.paypalWebhook = onRequest(
    {
      region: "europe-west1",
      secrets: [
        paypalWebhookId,
        paypalClientId,
        paypalClientSecret,
      ],
    },
    async (request, response) => {
      if (request.method !== "POST") {
        response.status(405).json({
          error: "Method Not Allowed",
        });
        return;
      }

      const requestBody =
          request.body;

      if (
        !requestBody ||
        typeof requestBody !== "object" ||
        typeof requestBody.id !== "string" ||
        typeof requestBody.event_type !== "string"
      ) {
        response.status(400).json({
          error:
              "Invalid PayPal webhook payload",
        });
        return;
      }

      const eventId =
          requestBody.id;

      const eventType =
          requestBody.event_type;

      let eventReserved = false;

      try {
        const verified =
            await verifyPayPalWebhook(
                request,
                requestBody,
            );

        if (!verified) {
          logger.warn(
              "Rejected unverified PayPal webhook",
              {
                eventId,
                eventType,
              },
          );

          response.status(401).json({
            error:
                "Invalid PayPal webhook signature",
          });
          return;
        }

        if (
          !SUPPORTED_EVENT_TYPES.has(
              eventType,
          )
        ) {
          logger.info(
              "Ignored unsupported PayPal webhook event",
              {
                eventId,
                eventType,
              },
          );

          response.status(200).json({
            received: true,
            ignored: true,
          });
          return;
        }

        eventReserved =
            await reserveWebhookEvent(
                eventId,
                eventType,
            );

        if (!eventReserved) {
          logger.info(
              "Duplicate PayPal webhook ignored",
              {
                eventId,
                eventType,
              },
          );

          response.status(200).json({
            received: true,
            duplicate: true,
          });
          return;
        }

        if (
          SUBSCRIPTION_EVENT_TYPES.has(
              eventType,
          )
        ) {
          await processSubscriptionEvent(
              requestBody,
          );
        } else {
          logger.info(
              "Verified PayPal payment event received",
              {
                eventId,
                eventType,
              },
          );
        }

        await completeWebhookEvent(
            eventId,
        );

        logger.info(
            "Verified PayPal webhook processed",
            {
              eventId,
              eventType,
            },
        );

        response.status(200).json({
          received: true,
          verified: true,
        });
      } catch (error) {
        if (eventReserved) {
          try {
            await releaseWebhookEvent(
                eventId,
            );
          } catch (releaseError) {
            logger.error(
                "Could not release failed webhook event",
                {
                  eventId,
                  message:
                      releaseError instanceof Error ?
                        releaseError.message :
                        "Unknown error",
                },
            );
          }
        }

        logger.error(
            "PayPal webhook processing failed",
            {
              eventId,
              eventType,
              message:
                  error instanceof Error ?
                    error.message :
                    "Unknown error",
            },
        );

        response.status(500).json({
          error:
              "Webhook processing failed",
        });
      }
    },
);

/**
 * Erstellt eine sichere, einmalig verwendbare Referenz für einen
 * Paddle-Checkout.
 *
 * Die Firebase-UID wird ausschließlich aus request.auth übernommen
 * und nicht vom Client übergeben.
 */
exports.createPaddleCheckoutReference = onCall(
    {
      region: "europe-west1",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "You must be signed in.",
        );
      }

      const uid = request.auth.uid;

      const reference = db
          .collection("paddleCheckoutReferences")
          .doc();

      await reference.set({
        uid,
        used: false,
        createdAt: FieldValue.serverTimestamp(),
      });

      logger.info(
          "Paddle checkout reference created",
          {
            uid,
            checkoutReference: reference.id,
          },
      );

      return {
        checkoutReference: reference.id,
      };
    },
);

/**
 * Prüft, ob ein Paddle transaction.completed Event exakt
 * zum erlaubten FilaLog Web-Jahresabo gehört.
 *
 * @param {object} event Paddle Webhook-Event.
 * @param {string} environment Paddle-Umgebung.
 * @return {boolean} True bei gültigem FilaLog Jahresabo.
 */
function isValidPaddleYearlyTransaction(
    event,
    environment,
) {
  if (
    !event ||
  !event.data ||
  event.eventType !== "transaction.completed"
  ) {
    return false;
  }

  const data = event.data;

  if (data.status !== "completed") {
    return false;
  }

  if (data.currencyCode !== PADDLE_CURRENCY_CODE) {
    return false;
  }

  const items =
    Array.isArray(data.items) ?
      data.items :
      [];

  if (items.length !== 1) {
    return false;
  }

  const item = items[0];

  if (
    !item ||
  item.quantity !== 1 ||
  !item.price
  ) {
    return false;
  }

  const price = item.price;

  const expectedPriceId =
    environment === "live" ?
      PADDLE_LIVE_YEARLY_PRICE_ID :
      PADDLE_SANDBOX_YEARLY_PRICE_ID;

  const expectedProductId =
    environment === "live" ?
      PADDLE_LIVE_PRODUCT_ID :
      PADDLE_SANDBOX_PRODUCT_ID;

  if (
    price.id !== expectedPriceId ||
  price.productId !== expectedProductId
  ) {
    return false;
  }

  if (
    !price.unitPrice ||
  price.unitPrice.amount !== PADDLE_YEARLY_AMOUNT ||
  price.unitPrice.currencyCode !== PADDLE_CURRENCY_CODE
  ) {
    return false;
  }

  if (
    !price.billingCycle ||
  price.billingCycle.interval !== "year" ||
  price.billingCycle.frequency !== 1
  ) {
    return false;
  }

  return true;
}

/**
 * Löst eine Paddle Checkout-Referenz serverseitig in die zugehörige
 * Firebase-UID auf.
 *
 * @param {string} checkoutReference Sichere Checkout-Referenz.
 * @return {Promise<string|null>} Firebase-UID oder null.
 */
async function resolvePaddleCheckoutReference(
    checkoutReference,
) {
  if (
    typeof checkoutReference !== "string" ||
    checkoutReference.length === 0
  ) {
    return null;
  }

  const reference = db
      .collection("paddleCheckoutReferences")
      .doc(checkoutReference);

  const snapshot = await reference.get();

  if (!snapshot.exists) {
    return null;
  }

  const data = snapshot.data();

  if (
    !data ||
    typeof data.uid !== "string" ||
    data.uid.length === 0
  ) {
    return null;
  }

  return data.uid;
}

/**
 * Verbraucht eine Paddle Checkout-Referenz atomar.
 *
 * Eine Referenz darf nur einmal für einen erfolgreichen
 * transaction.completed Vorgang verwendet werden.
 *
 * @param {string} checkoutReference Sichere Checkout-Referenz.
 * @param {string} eventId Paddle Event-ID.
 * @param {string} transactionId Paddle Transaction-ID.
 * @param {string} subscriptionId Paddle Subscription-ID.
 * @return {Promise<string|null>} Firebase-UID oder null.
 */
async function consumePaddleCheckoutReference(
    checkoutReference,
    eventId,
    transactionId,
    subscriptionId,
) {
  if (
    typeof checkoutReference !== "string" ||
    checkoutReference.length === 0 ||
    typeof eventId !== "string" ||
    eventId.length === 0 ||
    typeof transactionId !== "string" ||
    transactionId.length === 0 ||
    typeof subscriptionId !== "string" ||
    subscriptionId.length === 0
  ) {
    return null;
  }

  const reference = db
      .collection("paddleCheckoutReferences")
      .doc(checkoutReference);

  return db.runTransaction(
      async (transaction) => {
        const snapshot =
            await transaction.get(reference);

        if (!snapshot.exists) {
          return null;
        }

        const data = snapshot.data();

        if (
          !data ||
          typeof data.uid !== "string" ||
          data.uid.length === 0 ||
          data.used === true
        ) {
          return null;
        }

        transaction.update(
            reference,
            {
              used: true,
              usedAt:
                  FieldValue.serverTimestamp(),
              paddleEventId: eventId,
              paddleTransactionId:
                  transactionId,
              paddleSubscriptionId:
                  subscriptionId,
            },
        );

        return data.uid;
      },
  );
}

/**
 * Speichert einen erfolgreich verifizierten Paddle-Kauf
 * für die interne FilaLog-Kauf- und Umsatzstatistik.
 *
 * Die Paddle Transaction-ID wird als Dokument-ID verwendet,
 * damit derselbe Kauf nicht mehrfach gezählt werden kann.
 *
 * @param {string} uid Firebase User-ID.
 * @param {object} event Verifiziertes Paddle transaction.completed Event.
 * @param {string} environment Paddle-Umgebung.
 * @return {Promise<void>}
 */
async function recordPaddlePurchase(
    uid,
    event,
    environment,
) {
  if (
    typeof uid !== "string" ||
  uid.length === 0 ||
  !event ||
  !event.data ||
  (
    environment !== "live" &&
    environment !== "sandbox"
  )
  ) {
    throw new Error(
        "Invalid Paddle purchase analytics data",
    );
  }

  const data = event.data;

  const transactionId =
  typeof data.id === "string" ?
    data.id :
    null;

  const subscriptionId =
  typeof data.subscriptionId === "string" ?
    data.subscriptionId :
    null;

  if (
    !transactionId ||
  !subscriptionId
  ) {
    throw new Error(
        "Missing Paddle purchase identifiers",
    );
  }

  const reference = db
      .collection("purchaseAnalytics")
      .doc(`paddle_${transactionId}`);

  await reference.set(
      {
        uid,
        provider: "paddle",
        environment,
        plan: "yearly",
        amount: Number(PADDLE_YEARLY_AMOUNT),
        currency: PADDLE_CURRENCY_CODE,
        transactionId,
        subscriptionId,
        purchasedAt:
        FieldValue.serverTimestamp(),
      },
      {
        merge: true,
      },
  );
}

/**
 * Speichert die dauerhafte Zuordnung eines Paddle-Abos
 * zu einem FilaLog-Benutzer.
 *
 * @param {string} subscriptionId Paddle Subscription-ID.
 * @param {string} uid Firebase User-ID.
 * @param {string} customerId Paddle Customer-ID.
 * @return {Promise<void>}
 */
async function savePaddleSubscriptionMapping(
    subscriptionId,
    uid,
    customerId,
) {
  if (
    typeof subscriptionId !== "string" ||
  subscriptionId.length === 0 ||
  typeof uid !== "string" ||
  uid.length === 0 ||
  typeof customerId !== "string" ||
  customerId.length === 0
  ) {
    throw new Error(
        "Invalid Paddle subscription mapping data",
    );
  }

  const reference = db
      .collection("paddleSubscriptions")
      .doc(subscriptionId);

  await reference.set(
      {
        uid,
        customerId,
        subscriptionId,
        updatedAt:
          FieldValue.serverTimestamp(),
      },
      {
        merge: true,
      },
  );
}

/**
 * Ermittelt die Firebase-UID anhand einer Paddle Subscription-ID.
 *
 * @param {string} subscriptionId Paddle Subscription-ID.
 * @return {Promise<string|null>} Firebase-UID oder null.
 */
async function resolvePaddleSubscriptionUid(
    subscriptionId,
) {
  if (
    typeof subscriptionId !== "string" ||
  subscriptionId.length === 0
  ) {
    return null;
  }

  const reference = db
      .collection("paddleSubscriptions")
      .doc(subscriptionId);

  const snapshot = await reference.get();

  if (!snapshot.exists) {
    return null;
  }

  const data = snapshot.data();

  if (
    !data ||
  typeof data.uid !== "string" ||
  data.uid.length === 0
  ) {
    return null;
  }

  return data.uid;
}

/**
 * Reserviert ein Paddle Webhook-Event zur einmaligen Verarbeitung.
 *
 * @param {string} eventId Paddle Event-ID.
 * @param {string} eventType Paddle Event-Typ.
 * @param {string} environment Paddle-Umgebung.
 * @return {Promise<boolean>} True bei neuer Reservierung.
 */
async function reservePaddleWebhookEvent(
    eventId,
    eventType,
    environment,
) {
  const reference = db
      .collection("paddleWebhookEvents")
      .doc(`${environment}_${eventId}`);

  try {
    await reference.create({
      eventId,
      eventType,
      environment,
      processingStatus: "PROCESSING",
      createdAt:
        FieldValue.serverTimestamp(),
    });

    return true;
  } catch (error) {
    if (
      error &&
    (
      error.code === 6 ||
      error.code === "already-exists"
    )
    ) {
      return false;
    }

    throw error;
  }
}

/**
* Markiert ein erfolgreich verarbeitetes Paddle Webhook-Event.
*
* @param {string} eventId Paddle Event-ID.
* @param {string} environment Paddle-Umgebung.
* @return {Promise<void>}
*/
async function completePaddleWebhookEvent(
    eventId,
    environment,
) {
  await db
      .collection("paddleWebhookEvents")
      .doc(`${environment}_${eventId}`)
      .set(
          {
            processingStatus: "COMPLETED",
            completedAt:
              FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
      );
}

/**
* Entfernt eine fehlgeschlagene Paddle Webhook-Reservierung.
*
* Dadurch darf Paddle das Event später erneut zustellen.
*
* @param {string} eventId Paddle Event-ID.
* @param {string} environment Paddle-Umgebung.
* @return {Promise<void>}
*/
async function releasePaddleWebhookEvent(
    eventId,
    environment,
) {
  await db
      .collection("paddleWebhookEvents")
      .doc(`${environment}_${eventId}`)
      .delete();
}

/**
 * Empfängt und verifiziert Paddle Sandbox- und Live-Webhooks.
 */
exports.paddleWebhook = onRequest(
    {
      region: "europe-west1",
      secrets: [
        paddleSandboxApiKey,
        paddleSandboxWebhookSecret,
        paddleLiveApiKey,
        paddleLiveWebhookSecret,
      ],
    },
    async (request, response) => {
      if (request.method !== "POST") {
        response.status(405).json({
          error: "Method Not Allowed",
        });
        return;
      }

      const signature =
        request.get("Paddle-Signature");

      if (!signature) {
        logger.warn(
            "Paddle webhook rejected: missing signature",
        );

        response.status(400).json({
          error: "Missing Paddle-Signature header",
        });
        return;
      }

      if (!request.rawBody) {
        logger.error(
            "Paddle webhook rejected: raw body unavailable",
        );

        response.status(400).json({
          error: "Raw request body unavailable",
        });
        return;
      }

      const rawBody =
        request.rawBody.toString("utf8");

      const paddleLive = new Paddle(
          paddleLiveApiKey.value(),
          {
            environment: Environment.production,
          },
      );

      const paddleSandbox = new Paddle(
          paddleSandboxApiKey.value(),
          {
            environment: Environment.sandbox,
          },
      );

      let event;
      let paddleEnvironment;

      try {
        event = await paddleLive.webhooks.unmarshal(
            rawBody,
            paddleLiveWebhookSecret.value(),
            signature,
        );

        paddleEnvironment = "live";
      } catch (liveError) {
        try {
          event = await paddleSandbox.webhooks.unmarshal(
              rawBody,
              paddleSandboxWebhookSecret.value(),
              signature,
          );

          paddleEnvironment = "sandbox";
        } catch (sandboxError) {
          logger.warn(
              "Paddle webhook signature verification failed",
              {
                liveMessage:
                  liveError instanceof Error ?
                    liveError.message :
                    String(liveError),
                sandboxMessage:
                  sandboxError instanceof Error ?
                    sandboxError.message :
                    String(sandboxError),
              },
          );

          response.status(401).json({
            error: "Invalid webhook signature",
          });
          return;
        }
      }

      const eventId =
          typeof event.eventId === "string" ?
            event.eventId :
            null;

      const eventType =
          typeof event.eventType === "string" ?
            event.eventType :
            null;

      if (!eventId || !eventType) {
        logger.error(
            "Verified Paddle webhook missing event metadata",
        );

        response.status(400).json({
          error: "Invalid Paddle webhook event",
        });
        return;
      }

      let eventReserved = false;

      try {
        eventReserved =
    await reservePaddleWebhookEvent(
        eventId,
        eventType,
        paddleEnvironment,
    );

        if (!eventReserved) {
          logger.info(
              "Duplicate Paddle webhook ignored",
              {
                eventId,
                eventType,
              },
          );

          response.status(200).json({
            received: true,
            duplicate: true,
          });
          return;
        }

        if (
          eventType === "transaction.completed" &&
          !isValidPaddleYearlyTransaction(
              event,
              paddleEnvironment,
          )
        ) {
          logger.warn(
              "Invalid Paddle yearly transaction ignored",
              {
                eventId,
                eventType,
              },
          );

          await completePaddleWebhookEvent(
              eventId,
              paddleEnvironment,
          );

          response.status(200).json({
            received: true,
            ignored: true,
            reason: "invalid_transaction",
          });
          return;
        }

        const customData =
            event.data &&
            event.data.customData &&
            typeof event.data.customData === "object" ?
              event.data.customData :
              null;

        const checkoutReference =
            customData &&
            typeof customData.checkoutReference === "string" ?
              customData.checkoutReference :
              null;

        let uid = null;

        if (
          eventType === "transaction.completed"
        ) {
          const transactionId =
              event.data &&
              typeof event.data.id === "string" ?
                event.data.id :
                null;

          const subscriptionId =
              event.data &&
              typeof event.data.subscriptionId === "string" ?
                event.data.subscriptionId :
                null;

          if (checkoutReference) {
            uid =
                await consumePaddleCheckoutReference(
                    checkoutReference,
                    eventId,
                    transactionId,
                    subscriptionId,
                );
          }
        } else if (checkoutReference) {
          uid =
              await resolvePaddleCheckoutReference(
                  checkoutReference,
              );
        }

        if (
          uid === null &&
          eventType === "transaction.completed" &&
          event.data &&
          typeof event.data.subscriptionId === "string"
        ) {
          uid =
              await resolvePaddleSubscriptionUid(
                  event.data.subscriptionId,
              );
        }

        if (
          uid === null &&
          eventType.startsWith("subscription.") &&
          event.data &&
          typeof event.data.id === "string"
        ) {
          uid =
              await resolvePaddleSubscriptionUid(
                  event.data.id,
              );
        }

        if (
          uid !== null &&
          paddleEnvironment === "sandbox"
        ) {
          const accessSnapshot =
            await getUserAccessReference(uid).get();

          const accessData =
            accessSnapshot.exists ?
              accessSnapshot.data() :
              null;

          if (
            accessData &&
            accessData.paddleEnvironment === "live"
          ) {
            logger.info(
                "Sandbox Paddle event ignored for live subscription",
                {
                  uid,
                  eventId,
                  eventType,
                },
            );

            await completePaddleWebhookEvent(
                eventId,
                paddleEnvironment,
            );

            response.status(200).json({
              received: true,
              ignored: true,
              reason: "live_subscription_exists",
            });

            return;
          }
        }

        if (
          eventType === "transaction.completed" &&
          uid !== null
        ) {
          await activatePaddleYearlyPremium(
              uid,
              event,
              paddleEnvironment,
          );

          await recordPaddlePurchase(
              uid,
              event,
              paddleEnvironment,
          );
          const paddleCustomerId =
          event.data &&
          typeof event.data.customerId === "string" ?
            event.data.customerId :
            null;

          const paddleSubscriptionId =
          event.data &&
          typeof event.data.subscriptionId === "string" ?
            event.data.subscriptionId :
            null;

          if (
            paddleCustomerId &&
        paddleSubscriptionId
          ) {
            await savePaddleSubscriptionMapping(
                paddleSubscriptionId,
                uid,
                paddleCustomerId,
            );
          }
        }

        if (
          eventType === "subscription.activated" &&
          uid !== null
        ) {
          await updatePaddleActiveSubscription(
              uid,
              event,
              paddleEnvironment,
          );
        }

        if (
          eventType.startsWith("subscription.") &&
          eventType !== "subscription.activated" &&
          uid !== null
        ) {
          await updatePaddleSubscriptionLifecycle(
              uid,
              event,
              paddleEnvironment,
          );
        }

        logger.info(
            "Verified Paddle webhook received",
            {
              eventId,
              eventType,
              checkoutReference,
              uidResolved: uid !== null,
            },
        );

        if (
          eventType === "subscription.activated"
        ) {
          const subscriptionData =
              event.data || {};

          logger.info(
              "Paddle subscription activated data",
              {
                status:
                    subscriptionData.status || null,
                customerId:
                    subscriptionData.customerId || null,
                subscriptionId:
                    subscriptionData.id || null,
                currentBillingPeriod:
                    subscriptionData.currentBillingPeriod || null,
                nextBilledAt:
                    subscriptionData.nextBilledAt || null,
                scheduledChange:
                    subscriptionData.scheduledChange || null,
                occurredAt:
                    event.occurredAt || null,
              },
          );
        }

        await completePaddleWebhookEvent(
            eventId,
            paddleEnvironment,
        );

        logger.info(
            "Verified Paddle webhook processed",
            {
              eventId,
              eventType,
            },
        );

        response.status(200).json({
          received: true,
          verified: true,
        });
      } catch (error) {
        if (eventReserved) {
          try {
            await releasePaddleWebhookEvent(
                eventId,
                paddleEnvironment,
            );
          } catch (releaseError) {
            logger.error(
                "Could not release failed Paddle webhook event",
                {
                  eventId,
                  message:
                      releaseError instanceof Error ?
                        releaseError.message :
                        "Unknown error",
                },
            );
          }
        }

        logger.error(
            "Paddle webhook processing failed",
            {
              eventId,
              eventType,
              message:
                  error instanceof Error ?
                    error.message :
                    "Unknown error",
            },
        );

        response.status(500).json({
          error: "Webhook processing failed",
        });
      }
    },
);
