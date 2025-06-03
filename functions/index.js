/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");
const admin = require("firebase-admin");


initializeApp();

exports.onVerificationStatusUpdate = onDocumentUpdated("sellers/{docId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.verificationStatus !== "verified" && after.verificationStatus === "verified") {
        const userId = after.sellerId; // Get user ID from Firestore

        if (userId) {
            try {
                // ✅ Get user's FCM token from Firestore
                const userDoc = await admin.firestore().collection("sellers").doc(userId).get();
                const userData = userDoc.data();
                const fcmToken = userData && userData.fcmToken; // ✅ FIXED: No optional chaining

                if (fcmToken) {
                    const message = {
                        notification: {
                            title: "آپ کا سیلر اکاؤنٹ ویریفائی ہو گیا ✅",
                            body: `آپ کی اسٹور "${after.storeName}" اب ایکٹیو ہے! 🎉`,
                        },
                        token: fcmToken,
                    };

                    // ✅ Send FCM notification
                    await getMessaging().send(message);
                    console.log(`✅ Notification sent to user ${userId} for transaction ${after.transactionId}`);
                } else {
                    console.log(`⚠️ No FCM token found for user ${userId}`);
                }
            } catch (error) {
                console.error("❌ Error sending notification:", error);
            }
        }
    }
});
exports.onOrderStatusUpdate = onDocumentUpdated("orders/{docId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    const prevStatus = before.status;
    const newStatus = after.status;

    if (prevStatus === newStatus) return;

    const validStatuses = ["pending", "processing", "shipped", "delivered", "cancelled"];

    if (validStatuses.includes(newStatus)) {
        const userId = after.userId;
        if (!userId) return;

        try {
            const userDoc = await admin.firestore().collection("users").doc(userId).get();
            const fcmToken = userDoc.data()?.fcmToken;

            if (fcmToken) {
                const shortOrderId = after.orderId.substring(0, 8);
                const message = {
                    notification: {
                        title: `Order ${newStatus.toUpperCase()}`,
                        body: `Your order ${shortOrderId} is now ${newStatus}.`,
                    },
                    token: fcmToken,
                };

                await getMessaging().send(message);
                console.log(`✅ Notification sent to ${userId} for order ${after.orderId}`);
            } else {
                console.log(`⚠️ No FCM token for user ${userId}`);
            }
        } catch (error) {
            console.error("❌ Error sending notification:", error);
        }
    }
});
exports.onProductStatusUpdate = onDocumentUpdated("products/{docId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "Active" && after.status === "Active") {
        const userId = after.sellerId; // Get user ID from Firestore

        if (userId) {
            try {
                // ✅ Get user's FCM token from Firestore
                const userDoc = await admin.firestore().collection("sellers").doc(userId).get();
                const userData = userDoc.data();
                const fcmToken = userData && userData.fcmToken; // ✅ FIXED: No optional chaining

                if (fcmToken) {
                    const message = {
                        notification: {
                            title: "مصنوعات منظور اور فہرست میں شامل ✅",
                            body: `آپ کی مصنوع ${after.name} فعال کر دی گئی ہے! مبارک ہو 🎉`,
                        },                        
                        token: fcmToken,
                    };

                    // ✅ Send FCM notification
                    await getMessaging().send(message);
                    console.log(`✅ Notification sent to user ${userId} for transaction ${after.transactionId}`);
                } else {
                    console.log(`⚠️ No FCM token found for user ${userId}`);
                }
            } catch (error) {
                console.error("❌ Error sending notification:", error);
            }
        }
    }
});
