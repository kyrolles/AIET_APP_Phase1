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
  .document('student_affairs_requests/{requestId}')
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
      
      // Check if this is a request related to invoices or other student affairs documents
      if (!afterData.type) {
        console.log('Type field is missing in the document');
        return null;
      }
      
      // Add the new types to the list of valid document types
      const validDocumentTypes = [
        'Proof of enrollment', 
        'Tuition Fees',
        'Grades Report',
        'Academic Content'
      ];
      
      if (!validDocumentTypes.includes(afterData.type)) {
        console.log('Not a supported document type:', afterData.type);
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
        const studentName = afterData.student_name || '';
        
        console.log('Student ID:', studentId);
        console.log('Student Name:', studentName);
        console.log('Request type:', requestType);
        
        // Create notification content
        const title = 'Request Approved';
        const body = `Your ${requestType} request has been approved and is ready.`;
        
        // Store notification in Firestore even before attempting to send
        const notificationData = {
          user_id: studentId,
          title: title,
          body: body,
          type: 'invoice',
          request_type: requestType,
          request_id: context.params.requestId,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          read: false
        };
        
        // Add the notification to Firestore
        try {
          await admin.firestore().collection('notifications').add(notificationData);
          console.log('Notification stored in database for user:', studentId);
        } catch (storeError) {
          console.error('Error storing notification in database:', storeError);
        }
        
        // Get the student's FCM token from the users collection
        let userDoc = null;
        let fcmToken = null;
        
        try {
          console.log('Searching for user with ID:', studentId);
          
          // Try finding user by id field
          const usersSnapshot = await admin.firestore()
            .collection('users')
            .where('id', '==', studentId)
            .get();
          
          console.log('User documents found by ID:', usersSnapshot.size);
          
          if (!usersSnapshot.empty) {
            userDoc = usersSnapshot.docs[0];
            const userData = userDoc.data();
            fcmToken = userData.fcm_token;
            console.log('Found user by ID with FCM token:', fcmToken ? 'Yes' : 'No');
          } else {
            // Try searching by uid field
            console.log('No user found with ID field, trying uid field...');
            const usersByUidSnapshot = await admin.firestore()
              .collection('users')
              .where('uid', '==', studentId)
              .get();
              
            if (!usersByUidSnapshot.empty) {
              userDoc = usersByUidSnapshot.docs[0];
              const userData = userDoc.data();
              fcmToken = userData.fcm_token;
              console.log('Found user by uid with FCM token:', fcmToken ? 'Yes' : 'No');
            } else if (afterData.email) {
              // Try searching by email as fallback
              console.log('Trying to find user by email if available');
              const userByEmailSnapshot = await admin.firestore()
                .collection('users')
                .where('email', '==', afterData.email)
                .get();
                
              if (!userByEmailSnapshot.empty) {
                userDoc = userByEmailSnapshot.docs[0];
                const userData = userDoc.data();
                fcmToken = userData.fcm_token;
                console.log('Found user by email with FCM token:', fcmToken ? 'Yes' : 'No');
              }
            }
          }
          
          // Check for token in alternative fields if not found
          if (userDoc && !fcmToken) {
            const userData = userDoc.data();
            fcmToken = userData.fcmToken || userData.token;
            console.log('Checked alternative token fields:', fcmToken ? 'Found token' : 'No token');
          }
          
          // Still no token? Check if there's a devices collection
          if (!fcmToken) {
            console.log('No FCM token found in user document, checking devices collection...');
            try {
              const userId = userDoc ? userDoc.id : studentId;
              const devicesSnapshot = await admin.firestore()
                .collection('devices')
                .where('userId', '==', userId)
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
          }
        } catch (userLookupError) {
          console.error('Error during user lookup:', userLookupError);
        }
        
        // If no FCM token, log and return
        if (!fcmToken) {
          console.log('No valid FCM token found for user:', studentId);
          
          // Update the notification to indicate delivery failure
          try {
            const notificationsSnapshot = await admin.firestore()
              .collection('notifications')
              .where('user_id', '==', studentId)
              .where('request_id', '==', context.params.requestId)
              .orderBy('created_at', 'desc')
              .limit(1)
              .get();
            
            if (!notificationsSnapshot.empty) {
              await notificationsSnapshot.docs[0].ref.update({
                delivery_failed: true,
                delivery_error: 'No FCM token found'
              });
            }
          } catch (updateError) {
            console.error('Error updating notification with delivery status:', updateError);
          }
          
          return { success: false, error: 'No FCM token available for user' };
        }
        
        console.log('Found FCM token:', fcmToken);
        
        // Create a notification message
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
            type: 'invoice',
            request_type: requestType,
            request_id: context.params.requestId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            timestamp: Date.now().toString()
          },
          token: fcmToken
        };
        
        console.log('Sending notification:', JSON.stringify(message));
        
        // Send the message with error handling
        try {
          const response = await admin.messaging().send(message);
          console.log('Successfully sent invoice notification:', response);
          
          // Update the notification to indicate successful delivery
          try {
            // Simplified query - just find by request_id without sorting
            const notificationsSnapshot = await admin.firestore()
              .collection('notifications')
              .where('request_id', '==', context.params.requestId)
              .limit(1)
              .get();
            
            if (!notificationsSnapshot.empty) {
              await notificationsSnapshot.docs[0].ref.update({
                delivery_success: true,
                message_id: response
              });
            }
          } catch (updateError) {
            console.error('Error updating notification with delivery status:', updateError);
          }
          
          return { success: true, messageId: response };
        } catch (fcmError) {
          console.error('Error sending invoice notification:', fcmError);
          
          // Handle invalid token error
          if (fcmError.code === 'messaging/registration-token-not-registered' && userDoc) {
            try {
              // Remove the invalid token from the user document
              console.log('Removing invalid FCM token from user document');
              await userDoc.ref.update({
                fcm_token: admin.firestore.FieldValue.delete()
              });
              
              // Add to failed notifications collection for tracking and analysis
              await admin.firestore().collection('failed_notifications').add({
                user_id: studentId,
                error_code: fcmError.code,
                error_message: fcmError.message,
                token: fcmToken,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                request_type: requestType,
                request_id: context.params.requestId
              });
            } catch (removeTokenError) {
              console.error('Error removing invalid token:', removeTokenError);
            }
          }
          
          // Update the notification to indicate delivery failure
          try {
            // Simplified query - find by request_id without sorting
            const notificationsSnapshot = await admin.firestore()
              .collection('notifications')
              .where('request_id', '==', context.params.requestId)
              .limit(1)
              .get();
            
            if (!notificationsSnapshot.empty) {
              await notificationsSnapshot.docs[0].ref.update({
                delivery_failed: true,
                delivery_error: fcmError.message
              });
            }
          } catch (updateError) {
            console.error('Error updating notification with delivery status:', updateError);
          }
          
          return { error: fcmError.message };
        }
      } else {
        console.log('Status condition not met:', beforeData.status, '->', afterData.status);
      }
      
      return null;
    } catch (error) {
      console.error('Error in invoice notification function:', error);
      return { error: error.message };
    }
  });

/**
 * Cloud Function that triggers when a training request document is updated
 * and sends a notification to the student with the appropriate message
 */
exports.sendTrainingNotification = functions.firestore
  .document('student_affairs_requests/{requestId}')
  .onUpdate((change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    // Quick check - if not a training document, exit early without processing
    if (!afterData.type || afterData.type.toLowerCase() !== 'training') {
      console.log('Not a training request document, exiting early');
      return null;
    }
    
    // Continue only if status changed to 'done' or 'rejected'
    if (!beforeData.status || !afterData.status || 
        beforeData.status === afterData.status ||
        !['done', 'rejected'].includes(afterData.status.toLowerCase())) {
      console.log('Status condition not met for training notification');
      return null;
    }
    
    // Now proceed with the full function
    return (async () => {
      try {
        // Enhanced logging
        console.log('--------- TRAINING NOTIFICATION FUNCTION TRIGGERED ---------');
        console.log('Request ID:', context.params.requestId);
        console.log('Before data:', JSON.stringify(beforeData));
        console.log('After data:', JSON.stringify(afterData));
        console.log('Before status:', beforeData.status);
        console.log('After status:', afterData.status);
        console.log('Document type:', afterData.type);
        
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
    })();
  }); 