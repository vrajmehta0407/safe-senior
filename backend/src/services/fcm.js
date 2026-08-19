'use strict';

/**
 * fcm.js — Firebase Cloud Messaging wrapper for Safe Senior.
 *
 * Behaviour:
 *  - If FCM_SERVICE_ACCOUNT_PATH or FCM_SERVICE_ACCOUNT_JSON is set in .env,
 *    initialises firebase-admin and enables real push delivery.
 *  - If neither is set, all send calls are no-ops that log a warning.
 *    The server starts and runs normally without Firebase credentials.
 *
 * Usage:
 *   const { sendBroadcast, sendToUser } = require('./fcm');
 *   await sendBroadcast({ title: 'Alert', body: 'Check your messages' });
 *
 * To enable real FCM:
 *   1. Create a Firebase project at https://console.firebase.google.com
 *   2. Generate a service account key (Project Settings → Service Accounts)
 *   3. Set FCM_SERVICE_ACCOUNT_PATH=/path/to/key.json in .env
 *      OR paste the JSON as FCM_SERVICE_ACCOUNT_JSON in .env
 *   4. In the Flutter app, initialise FlutterFire and subscribe devices to
 *      the 'all-users' topic:
 *        FirebaseMessaging.instance.subscribeToTopic('all-users');
 */

let _admin = null;   // null = uninitialised, false = init failed/skipped
let _fcmReady = false;

/**
 * Lazily initialise firebase-admin the first time it is needed.
 * Returns true if FCM is available, false if credentials are missing.
 */
function _init() {
  if (_admin !== null) return _fcmReady;

  const accountPath = process.env.FCM_SERVICE_ACCOUNT_PATH;
  const accountJson = process.env.FCM_SERVICE_ACCOUNT_JSON;

  if (!accountPath && !accountJson) {
    console.warn(
      '[fcm] No FCM credentials configured ' +
      '(FCM_SERVICE_ACCOUNT_PATH / FCM_SERVICE_ACCOUNT_JSON not set). ' +
      'Push notifications will be skipped. ' +
      'See backend/.env.example for setup instructions.'
    );
    _admin = false;
    _fcmReady = false;
    return false;
  }

  try {
    const admin = require('firebase-admin');

    let credential;
    if (accountPath) {
      // eslint-disable-next-line import/no-dynamic-require
      const serviceAccount = require(accountPath);
      credential = admin.credential.cert(serviceAccount);
    } else {
      const serviceAccount = JSON.parse(accountJson);
      credential = admin.credential.cert(serviceAccount);
    }

    if (!admin.apps.length) {
      admin.initializeApp({ credential });
    }

    _admin = admin;
    _fcmReady = true;
    console.log('[fcm] Firebase Admin SDK initialised. Push notifications enabled.');
    return true;
  } catch (err) {
    console.error('[fcm] Failed to initialise Firebase Admin SDK:', err.message);
    _admin = false;
    _fcmReady = false;
    return false;
  }
}

/**
 * Send a broadcast push notification to ALL users via the 'all-users' FCM topic.
 *
 * Flutter devices must subscribe to this topic on startup:
 *   FirebaseMessaging.instance.subscribeToTopic('all-users');
 *
 * @param {object} opts
 * @param {string} opts.title   - Notification title (max 120 chars)
 * @param {string} opts.body    - Notification body  (max 500 chars)
 * @param {object} [opts.data]  - Optional key/value string data payload
 * @returns {Promise<{ sent: boolean, messageId?: string, reason?: string, error?: string }>}
 */
async function sendBroadcast({ title, body, data = {} }) {
  if (!_init()) {
    return { sent: false, reason: 'FCM not configured' };
  }

  try {
    const message = {
      topic: 'all-users',
      notification: { title, body },
      data: { ...data, _source: 'safe-senior-admin' },
      android: {
        priority: 'high',
        notification: { channelId: 'safe_senior_alerts', sound: 'default' },
      },
      apns: {
        payload: { aps: { sound: 'default', badge: 1 } },
      },
    };

    const messageId = await _admin.messaging().send(message);
    console.log(`[fcm] Broadcast sent. messageId=${messageId}`);
    return { sent: true, messageId };
  } catch (err) {
    console.error('[fcm] sendBroadcast failed:', err.message);
    return { sent: false, error: err.message };
  }
}

/**
 * Send a push notification to a single device via its FCM registration token.
 *
 * @param {string} token        - The device FCM registration token
 * @param {object} opts
 * @param {string} opts.title
 * @param {string} opts.body
 * @param {object} [opts.data]
 * @returns {Promise<{ sent: boolean, messageId?: string }>}
 */
async function sendToUser(token, { title, body, data = {} }) {
  if (!_init()) {
    return { sent: false, reason: 'FCM not configured' };
  }
  if (!token) {
    return { sent: false, reason: 'No FCM token provided' };
  }

  try {
    const message = {
      token,
      notification: { title, body },
      data: { ...data, _source: 'safe-senior-admin' },
      android: {
        priority: 'high',
        notification: { channelId: 'safe_senior_alerts', sound: 'default' },
      },
      apns: {
        payload: { aps: { sound: 'default', badge: 1 } },
      },
    };

    const messageId = await _admin.messaging().send(message);
    return { sent: true, messageId };
  } catch (err) {
    console.error('[fcm] sendToUser failed:', err.message);
    return { sent: false, error: err.message };
  }
}

/**
 * Returns whether FCM is configured and ready to send.
 * Safe to call at any time — triggers lazy initialisation.
 */
function isFcmReady() {
  _init();
  return _fcmReady;
}

module.exports = { sendBroadcast, sendToUser, isFcmReady };
