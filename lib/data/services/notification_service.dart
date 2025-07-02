import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:platia/core/utils/log_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_foregroundMessageHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Get initial message if app was launched from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.w('User granted permission');
    } else {
      LogService.w('User declined or has not accepted permission');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    LogService.i('Notification tapped: ${response.payload}');
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    LogService.i('Background message: ${message.messageId}');
  }

  void _foregroundMessageHandler(RemoteMessage message) {
    LogService.i('Foreground message: ${message.messageId}');

    // Show local notification
    _showLocalNotification(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    LogService.i('Message opened app: ${message.messageId}');
    _handleMessage(message);
  }

  void _handleMessage(RemoteMessage message) {
    // Navigate based on message data
    LogService.i('Handling message: ${message.data}');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'platia_channel',
      'Platia Notifications',
      channelDescription: 'Notifications for Platia app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Platia',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  Future<void> scheduleClassReminder({
    required String classId,
    required String className,
    required DateTime classTime,
  }) async {
    final reminderTime = classTime.subtract(const Duration(hours: 1));
    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'class_reminder',
      'Class Reminders',
      channelDescription: 'Reminders for upcoming classes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      classId.hashCode,
      'Ders Hatırlatması',
      '$className dersiniz 1 saat sonra başlayacak',
      tzReminderTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelClassReminder(String classId) async {
    await _localNotifications.cancel(classId.hashCode);
  }
}
