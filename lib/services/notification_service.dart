import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';
import '../models/notification_settings.dart';

/// Service for managing local notifications.
class NotificationService {
  static NotificationService? _instance;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  /// Returns the singleton instance of NotificationService.
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initializes the notification service.
  Future<void> initialize() async {
    tz.initializeTimeZones();
    _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    // For now, just opening the app is sufficient
  }

  void _configureLocalTimeZone() {
    if (kIsWeb) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      return;
    }

    // Get the device timezone name
    final timeZoneName = _getTimeZoneName();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to a common timezone if the exact one isn't found
      tz.setLocalLocation(tz.getLocation('America/New_York'));
    }
  }

  String _getTimeZoneName() {
    // Get timezone from the device
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;

    // Map common offsets to timezone names
    // This is a simplified approach - for production, use a proper timezone detection package
    if (Platform.isIOS || Platform.isMacOS) {
      // Common US/European timezones
      if (hours == -8 || hours == -7) return 'America/Los_Angeles';
      if (hours == -6 || hours == -5) return 'America/Chicago';
      if (hours == -5 || hours == -4) return 'America/New_York';
      if (hours == 0 || hours == 1) return 'Europe/London';
      if (hours == 1 || hours == 2) return 'Europe/Berlin';
    }
    return 'America/New_York'; // Default fallback
  }

  /// Requests notification permissions from the user.
  Future<bool> requestPermissions() async {
    final iOS = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final android = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return iOS ?? android ?? false;
  }

  /// Schedules notifications based on the current settings.
  Future<void> scheduleNotifications({
    required NotificationSettings settings,
    required List<Habit> habits,
  }) async {
    // Cancel all existing notifications first
    await cancelAllNotifications();

    // If globally disabled, don't schedule anything
    if (!settings.globalEnabled) return;

    // Get enabled habits
    final enabledHabits = habits
        .where((h) => settings.enabledHabitIds.contains(h.id))
        .toList();

    if (enabledHabits.isEmpty) return;

    // Build notification body with habit names
    final habitNames = enabledHabits.map((h) => h.name).join(', ');
    final body = 'Time to work on: $habitNames';

    int notificationId = 0;

    // Schedule morning notification
    if (settings.morningEnabled) {
      await _scheduleDailyNotification(
        id: notificationId++,
        title: 'Morning Habit Reminder',
        body: body,
        hour: settings.morningHour,
        minute: settings.morningMinute,
      );
    }

    // Schedule afternoon notification
    if (settings.afternoonEnabled) {
      await _scheduleDailyNotification(
        id: notificationId++,
        title: 'Afternoon Habit Reminder',
        body: body,
        hour: settings.afternoonHour,
        minute: settings.afternoonMinute,
      );
    }

    // Schedule evening notification
    if (settings.eveningEnabled) {
      await _scheduleDailyNotification(
        id: notificationId++,
        title: 'Evening Habit Reminder',
        body: body,
        hour: settings.eveningHour,
        minute: settings.eveningMinute,
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
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
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Shows a test notification immediately.
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
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

    await _notifications.show(
      999,
      'Habit Tracker',
      'Notifications are working!',
      details,
    );
  }
}
