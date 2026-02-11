/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
setGlobalOptions({maxInstances: 10});

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

export const sendNudge = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be signed in"
    );
  }

  const {friendUserId, senderName} = request.data;
  if (!friendUserId || !senderName) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "friendUserId and senderName required"
    );
  }

  const userDoc = await db.collection("users").doc(friendUserId).get();
  if (!userDoc.exists) {
    return {sent: false, reason: "User not found"};
  }

  const userData = userDoc.data();
  const fcmToken = userData?.fcmToken;
  const notificationsEnabled = userData?.notificationsEnabled === true;

  if (!notificationsEnabled || !fcmToken) {
    return {sent: false, reason: "Recipient has notifications disabled"};
  }

  const message = {
    token: fcmToken,
    notification: {
      title: "Nudge from " + senderName,
      body: "Reminder to check your score",
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  await messaging.send(message);
  return {sent: true};
});


// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
