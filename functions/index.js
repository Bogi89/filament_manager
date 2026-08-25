const {initializeApp} = require("firebase-admin/app");
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
  defineSecret,
} = require("firebase-functions/params");

const logger = require("firebase-functions/logger");

initializeApp();

const db = getFirestore();

const paypalWebhookId =
    defineSecret("PAYPAL_WEBHOOK_ID");

const paypalClientId =
    defineSecret("PAYPAL_CLIENT_ID");

const paypalClientSecret =
    defineSecret("PAYPAL_CLIENT_SECRET");

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
