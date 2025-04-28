const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Cloud Function that triggers when a new announcement is created
 * and sends a notification to all users
 */
exports.sendAnnouncementNotification = functions.firestore
  .document('announcements/{announcementId}')
  .onCreate(async (snapshot, context) => {
    try {
      // Get the announcement data
      const announcementData = snapshot.data();
      const authorName = announcementData.author;
      const title = announcementData.title;

      if (!authorName || !title) {
        console.error('Missing required fields for notification');
        return null;
      }

      // Create a notification message
      const message = {
        notification: {
          title: 'New Announcement',
          body: `${authorName} has published a new announcement with the title ${title}`
        },
        topic: 'announcements', // Send to all devices subscribed to the 'announcements' topic
      };

      // Send the message
      const response = await admin.messaging().send(message);
      console.log('Successfully sent notification:', response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('Error sending notification:', error);
      return { error: error.message };
    }
  }); 