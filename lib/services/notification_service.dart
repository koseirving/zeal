import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/affirmation_model.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    
    // Request notification permissions
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleAffirmationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'affirmation_channel',
      'Daily Affirmations',
      channelDescription: 'Daily motivational affirmations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleDailyAffirmations(List<AffirmationModel> affirmations) async {
    // Cancel existing notifications
    await _notifications.cancelAll();

    // Schedule notifications for the next 7 days
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final scheduleDate = DateTime(
        now.year,
        now.month,
        now.day + i,
        9, // 9 AM
        0,
      );

      if (scheduleDate.isAfter(now) && affirmations.isNotEmpty) {
        final affirmation = affirmations[i % affirmations.length];
        
        await scheduleAffirmationNotification(
          id: i,
          title: 'Daily Affirmation 🌟',
          body: affirmation.text,
          scheduledDate: scheduleDate,
        );
      }
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}