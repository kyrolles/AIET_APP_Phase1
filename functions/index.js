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

/**
 * Cloud Function that triggers when a request document is updated
 * and sends a notification to the student when their invoice request is approved
 */
exports.sendInvoiceNotification = functions.firestore
  .document('requests/{requestId}')
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      
      // Debug logs
      console.log('--------- INVOICE NOTIFICATION FUNCTION TRIGGERED ---------');
      console.log('Request ID:', context.params.requestId);
      console.log('Before data:', JSON.stringify(beforeData));
      console.log('After data:', JSON.stringify(afterData));
      console.log('Before status:', beforeData.status);
      console.log('After status:', afterData.status);
      console.log('Document type:', afterData.type);
      
      // Check if this is a request related to invoices
      if (!afterData.type) {
        console.log('Type field is missing in the document');
        return null;
      }
      
      if (afterData.type !== 'Proof of enrollment' && afterData.type !== 'Tuition Fees') {
        console.log('Not an invoice document - type:', afterData.type);
        return null;
      }
      
      // Check if the status was changed to 'Done'
      if (beforeData.status !== 'Done' && afterData.status === 'Done') {
        console.log('Status changed to Done - proceeding with notification');
        
        if (!afterData.student_id) {
          console.log('Student ID is missing in the document');
          return null;
        }
        
        const studentId = afterData.student_id;
        const requestType = afterData.type;
        
        console.log('Student ID:', studentId);
        console.log('Request type:', requestType);
        
        // Get the student's FCM token from the users collection
        const usersSnapshot = await admin.firestore()
          .collection('users')
          .where('id', '==', studentId)
          .get();
        
        console.log('User documents found:', usersSnapshot.size);
        
        if (usersSnapshot.empty) {
          console.log('No user found with ID:', studentId);
          
          // Try searching by email as fallback
          if (afterData.email) {
            console.log('Trying to find user by email:', afterData.email);
            const userByEmailSnapshot = await admin.firestore()
              .collection('users')
              .where('email', '==', afterData.email)
              .get();
              
            if (userByEmailSnapshot.empty) {
              console.log('No user found with email either:', afterData.email);
              return null;
            }
            
            const user = userByEmailSnapshot.docs[0].data();
            console.log('User found by email:', user.id || user.email);
          } else {
            return null;
          }
        }
        
        const user = usersSnapshot.docs[0].data();
        console.log('User data:', JSON.stringify(user));
        
        const fcmToken = user.fcm_token;
        
        // If no FCM token, exit
        if (!fcmToken) {
          console.log('No FCM token found for user:', studentId);
          return null;
        }
        
        console.log('Found FCM token:', fcmToken);
        
        // Create a notification message
        const message = {
          notification: {
            title: 'Request Approved',
            body: `Your ${requestType} request has been approved and is ready.`
          },
          data: {
            type: 'invoice',
            request_type: requestType,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          token: fcmToken
        };
        
        console.log('Sending notification:', JSON.stringify(message));
        
        // Send the message
        const response = await admin.messaging().send(message);
        console.log('Successfully sent invoice notification:', response);
        return { success: true, messageId: response };
      } else {
        console.log('Status condition not met:', beforeData.status, '->', afterData.status);
      }
      
      return null;
    } catch (error) {
      console.error('Error sending invoice notification:', error);
      return { error: error.message };
    }
  }); 