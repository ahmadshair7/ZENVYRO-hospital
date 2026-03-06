import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Conditionally import the native notification helper only on non-web platforms
import 'notification_helper_stub.dart'
    if (dart.library.io) 'notification_helper_native.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request notification permission (FCM - works on all platforms)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Setup local notifications on mobile/desktop only
    if (!kIsWeb) {
      await NotificationHelper.init();

      // Background message handler (mobile only)
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Foreground FCM messages → show as local notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          NotificationHelper.show(
            title: notification.title ?? 'Zencare',
            body: notification.body ?? '',
          );
        }
      });
    }

    // Subscribe to broadcast topic
    try {
      await _fcm.subscribeToTopic('all_staff');
    } catch (_) {}
  }

  /// Call this to trigger a push notification for an app event.
  static Future<void> sendPushNotification({
    required String title,
    required String body,
    String topic = 'all_staff',
  }) async {
    try {
      if (!kIsWeb) {
        await NotificationHelper.show(title: title, body: body);
      }
      // On web: FCM handles background push natively via browser
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }
}
