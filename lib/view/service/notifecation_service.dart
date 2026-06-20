import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Initialize
  static Future<void> initialize() async {
    // Permission maango
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Local notifications setup
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // FCM Token save karo
    await saveUserToken();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );
    });
  }

  // ✅ User ka FCM Token Firestore mein save karo
  static Future<void> saveUserToken() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      debugPrint('Token save error: $e');
    }
  }

  // ✅ Local Notification Show Karo
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medibook_channel',
      'MediBook Notifications',
      channelDescription: 'Doctor Appointment Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // ✅ Notification Firestore mein save karo
  static Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Appointment book hone par doctor ko notify karo
  static Future<void> notifyDoctorOnBooking({
    required String doctorId,
    required String patientName,
    required String date,
    required String reason,
  }) async {
    try {
      // Doctor ka token lo
      final doctorDoc = await _firestore
          .collection('users')
          .doc(doctorId)
          .get();
      final doctorData = doctorDoc.data() as Map<String, dynamic>;
      final doctorName = doctorData['name'] ?? 'Doctor';

      // Firestore mein notification save karo
      await saveNotification(
        userId: doctorId,
        title: '🔔 Nai Appointment!',
        body: '$patientName ne appointment book ki — $date\nReason: $reason',
        type: 'new_appointment',
      );

      debugPrint('Doctor notified: $doctorName');
    } catch (e) {
      debugPrint('Notify doctor error: $e');
    }
  }

  // ✅ Doctor accept/complete kare to patient ko notify karo
  static Future<void> notifyPatientOnStatus({
    required String patientId,
    required String doctorName,
    required String status,
    required String date,
  }) async {
    try {
      String title = '';
      String body = '';

      if (status == 'completed') {
        title = '✅ Appointment Completed!';
        body = 'Dr. $doctorName ne aapki appointment complete kar di — $date';
      } else if (status == 'cancelled') {
        title = '❌ Appointment Cancelled';
        body = 'Dr. $doctorName ne aapki appointment cancel kar di — $date';
      }

      // Firestore mein save karo
      await saveNotification(
        userId: patientId,
        title: title,
        body: body,
        type: status,
      );

      // Local notification show karo (agar same device par ho)
      await showLocalNotification(title: title, body: body);

      debugPrint('Patient notified: $status');
    } catch (e) {
      debugPrint('Notify patient error: $e');
    }
  }
}
