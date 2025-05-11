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
      const targetAudience = announcementData.targetAudience || [];
      const isGlobal = announcementData.isGlobal || false;

      if (!authorName || !title) {
        console.error('Missing required fields for notification');
        return null;
      }

      console.log('--------- ANNOUNCEMENT NOTIFICATION FUNCTION TRIGGERED ---------');
      console.log('Announcement ID:', context.params.announcementId);
      console.log('Title:', title);
      console.log('Author:', authorName);
      console.log('Target Audience:', targetAudience);
      console.log('Is Global:', isGlobal);

      // Create a notification message with basic information
      const baseMessage = {
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
        data: {
          type: 'announcement',
          announcement_id: context.params.announcementId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      };

      const sendPromises = [];

      // If it's a global announcement, send to everyone subscribed to 'announcements' topic
      if (isGlobal) {
        console.log('Sending global announcement notification');
        const globalMessage = {
          ...baseMessage,
          topic: 'announcements'
        };
        sendPromises.push(admin.messaging().send(globalMessage));
      }

      // For each target audience (department or year or combination), send to specific topic
      if (targetAudience && targetAudience.length > 0) {
        console.log('Sending targeted notifications to:', targetAudience);
        
        for (const audience of targetAudience) {
          // Create a valid FCM topic name (alphanumeric and underscores only)
          const topicName = `announcement_${audience.replace(/[^a-zA-Z0-9_]/g, '_')}`;
          
          console.log('Sending to topic:', topicName);
          
          const targetedMessage = {
            ...baseMessage,
            topic: topicName
          };
          
          // Send targeted notification
          sendPromises.push(admin.messaging().send(targetedMessage));
        }
      }

      // Wait for all notifications to be sent
      const responses = await Promise.all(sendPromises);
      console.log('Successfully sent notifications:', responses);
      return { success: true, messageIds: responses };
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
        console.log('Looking for user with ID:', studentId);
        
        // First, check for user by exact ID match
        const usersSnapshot = await admin.firestore()
          .collection('users')
          .where('id', '==', studentId)
          .get();
          
        if (usersSnapshot.empty) {
          console.log('No user found with ID field match. Trying uid field...');
          
          // Try searching by uid field
          const usersByUidSnapshot = await admin.firestore()
            .collection('users')
            .where('uid', '==', studentId)
            .get();
            
          if (usersByUidSnapshot.empty) {
            console.log('No user found with uid field match either');
            
            // Try searching by email as last resort
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
              console.log('User found by email search');
            } else {
              console.log('No email available for fallback search');
              return null;
            }
          } else {
            userDoc = usersByUidSnapshot.docs[0];
            console.log('User found by uid field search');
          }
        } else {
          userDoc = usersSnapshot.docs[0];
          console.log('User found by id field search');
        }
      } catch (error) {
        console.error('Error fetching user document:', error);
        return null;
      }
      
      const userData = userDoc.data();
      console.log('User data found:', JSON.stringify(userData));
      
      // Debug user identifiers with more details
      console.log('User identifiers check:', {
        id: userData.id,
        uid: userData.uid,
        user_uid: userData.user_uid,
        email: userData.email,
        docId: userDoc.id  // Document ID itself might be useful
      });

      // Get FCM token with more robust logic
      let fcmToken = userData.fcm_token;
      
      // If no fcm_token in user document, check if it has a different field name
      if (!fcmToken) {
        console.log('No fcm_token found, checking alternative field names');
        fcmToken = userData.fcmToken || userData.token;
        
        if (fcmToken) {
          console.log('Found token in alternative field');
        }
      }
      
      if (!fcmToken) {
        console.log('No FCM token found for user:', studentId);
        
        // Check for any recent device tokens linked to this user
        try {
          console.log('Checking for devices collection for tokens...');
          const devicesSnapshot = await admin.firestore()
            .collection('devices')
            .where('userId', '==', userDoc.id)
            .orderBy('lastActive', 'desc')
            .limit(1)
            .get();
            
          if (!devicesSnapshot.empty) {
            const deviceData = devicesSnapshot.docs[0].data();
            fcmToken = deviceData.token;
            console.log('Found token in devices collection:', fcmToken ? 'Yes' : 'No');
          }
        } catch (err) {
          console.log('Error checking devices collection:', err);
        }
        
        if (!fcmToken) {
          console.log('No valid token found in any location. Cannot send notification.');
          
          // Still store the notification even if we can't send it
          // Add specific flag to indicate notification couldn't be delivered
          const notificationData = {
            user_id: studentId,
            title: title,
            body: body,
            type: 'training',
            status: status,
            request_id: context.params.requestId,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
            delivery_failed: true,
            reason: 'No FCM token available'
          };
          
          const userUid = userData.uid || userData.user_uid || userData.id || userDoc.id;
          if (userUid) {
            notificationData.user_uid = userUid;
          }
          
          await admin.firestore().collection('notifications').add(notificationData);
          return { success: false, error: 'No FCM token available' };
        }
      }
      
      console.log('Using FCM token:', fcmToken);
      
      // Create notification content with improved message
      let title, body;
      if (status.toLowerCase() === 'done') {
        title = 'Training Request Approved';
        body = `Congratulations! ${trainingScore} days have been added to your training record.`;
      } else {
        title = 'Training Request Rejected';
        body = 'Your training request was not approved. Please check the details or contact training unit.';
      }
      
      // Add data to track notification in database - with proper field validation
      const notificationData = {
        user_id: studentId,
        title: title,
        body: body,
        type: 'training',
        status: status,
        request_id: context.params.requestId,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        read: false
      };
      
      // Store multiple user identifiers to ensure proper association
      // Document ID is the most reliable identifier
      notificationData.docId = userDoc.id;
      
      // Store userID fields based on availability
      const userUid = userData.uid || userData.user_uid || userData.id;
      if (userUid) {
        notificationData.user_uid = userUid;
      }
      
      // Store email for additional linking capability
      if (userData.email) {
        notificationData.user_email = userData.email;
      }
      
      // Log notification data for debugging
      console.log('Storing notification with data:', notificationData);
      
      await admin.firestore().collection('notifications').add(notificationData);
      
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