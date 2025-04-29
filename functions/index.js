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
        android: {
          notification: {
            icon: '@mipmap/launcher_icon',
            color: '#000000'
          }
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
          android: {
            notification: {
              icon: '@mipmap/launcher_icon',
              color: '#000000'
            }
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

/**
 * Cloud Function that triggers when a training request document is updated
 * and sends a notification to the student with the appropriate message
 */
exports.sendTrainingNotification = functions.firestore
  .document('requests/{requestId}')
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      
      // Enhanced logging
      console.log('--------- TRAINING NOTIFICATION FUNCTION TRIGGERED ---------');
      console.log('Request ID:', context.params.requestId);
      console.log('Before data:', JSON.stringify(beforeData));
      console.log('After data:', JSON.stringify(afterData));
      console.log('Before status:', beforeData.status);
      console.log('After status:', afterData.status);
      console.log('Document type:', afterData.type);
      
      // Skip if not a training request - more detailed check
      if (!afterData.type || afterData.type.toLowerCase() !== 'training') {
        console.log('Not a training document - type:', afterData.type);
        return null;
      }
      
      // Check if status changed
      if (!beforeData.status || !afterData.status) {
        console.log('Status fields missing');
        return null;
      }
      
      const statusChanged = beforeData.status !== afterData.status;
      const newStatusIsFinal = ['done', 'rejected'].includes(afterData.status.toLowerCase());
      
      console.log('Status changed:', statusChanged);
      console.log('New status is final:', newStatusIsFinal);
      
      if (!statusChanged || !newStatusIsFinal) {
        console.log('Status condition not met for notification');
        return null;
      }
      
      // Continue only if we have required fields
      if (!afterData.student_id) {
        console.log('Student ID missing in document');
        return null;
      }
      
      const studentId = afterData.student_id;
      const trainingScore = afterData.training_score || 0;
      const status = afterData.status;
      
      console.log('Processing for student ID:', studentId);
      console.log('Training score:', trainingScore);
      console.log('Status:', status);
      
      // Get user document with more robust error handling
      let userDoc;
      try {
        const usersSnapshot = await admin.firestore()
          .collection('users')
          .where('id', '==', studentId)
          .get();
          
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
            
            userDoc = userByEmailSnapshot.docs[0];
          } else {
            return null;
          }
        } else {
          userDoc = usersSnapshot.docs[0];
        }
      } catch (error) {
        console.error('Error fetching user document:', error);
        return null;
      }
      
      const userData = userDoc.data();
      console.log('User data found:', JSON.stringify(userData));
      
      const fcmToken = userData.fcm_token;
      
      if (!fcmToken) {
        console.log('No FCM token found for user:', studentId);
        return null;
      }
      
      console.log('Found FCM token:', fcmToken);
      
      // Create notification content with improved message
      let title, body;
      if (status.toLowerCase() === 'done') {
        title = 'Training Request Approved';
        body = `Congratulations! ${trainingScore} days have been added to your training record.`;
      } else {
        title = 'Training Request Rejected';
        body = 'Your training request was not approved. Please check the details or contact administration.';
      }
      
      // Add data to track notification in database
      await admin.firestore().collection('notifications').add({
        user_id: studentId,
        user_uid: userData.uid || userData.user_uid,
        title: title,
        body: body,
        type: 'training',
        status: status,
        request_id: context.params.requestId,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        read: false
      });
      
      // Create and send notification with rich data
      const message = {
        notification: {
          title: title,
          body: body
        },
        android: {
          notification: {
            icon: '@mipmap/launcher_icon',
            color: '#000000'
          }
        },
        data: {
          type: 'training',
          request_type: 'Training',
          status: status,
          score: trainingScore.toString(),
          request_id: context.params.requestId,
          timestamp: Date.now().toString(),
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        token: fcmToken
      };
      
      console.log('Sending notification message:', JSON.stringify(message));
      
      // Send the message
      const response = await admin.messaging().send(message);
      console.log('Successfully sent training notification:', response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('Error sending training notification:', error);
      return { error: error.message };
    }
  }); 