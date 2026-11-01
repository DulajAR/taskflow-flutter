import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        'taskflow_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for upcoming TaskFlow tasks',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);
  }

  static Future<void> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestNotificationsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules a task reminder based on task.reminderMinutes:
  /// 0  = at due time
  /// 10 = 10 minutes before
  /// 30 = 30 minutes before
  /// -1 = no reminder
  static Future<void> scheduleTaskReminder(Task task) async {
    if (task.id == null ||
        task.dueDate == null ||
        task.isCompleted ||
        task.reminderMinutes < 0) {
      return;
    }

    final dueDate = task.dueDate!;
    final reminderDate = dueDate.subtract(
      Duration(minutes: task.reminderMinutes),
    );

    // Do not schedule reminders for a time that has already passed.
    if (!reminderDate.isAfter(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    final String body = task.reminderMinutes == 0
        ? 'Your task "${task.title}" is due now.'
        : 'Your task "${task.title}" is due in '
              '${task.reminderMinutes} minutes.';

    await _notifications.zonedSchedule(
      id: task.id!,
      title: 'Task Reminder',
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: task.id.toString(),
    );
  }

  /// Cancels the scheduled reminder for a task.
  static Future<void> cancelTaskReminder(int taskId) async {
    await _notifications.cancel(id: taskId);
  }

  /// Displays an immediate test notification.
  static Future<void> showTestNotification() async {
    await _notifications.show(
      id: 999999,
      title: 'TaskFlow Notifications',
      body: 'Great! Your notification system is working.',
      notificationDetails: _notificationDetails,
    );
  }

  /// Cancels all scheduled notifications.
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Returns all currently pending notification requests.
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return _notifications.pendingNotificationRequests();
  }
}
