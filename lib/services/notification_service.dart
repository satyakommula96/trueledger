import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    tz_data.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    final fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final fln.LinuxInitializationSettings initializationSettingsLinux =
        fln.LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (fln.NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const fln.AndroidNotificationDetails androidNotificationDetails =
        fln.AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Main channel for notifications',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails notificationDetails = fln.NotificationDetails(
      android: androidNotificationDetails,
      iOS: fln.DarwinNotificationDetails(),
      macOS: fln.DarwinNotificationDetails(),
      linux: fln.LinuxNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleDailyReminder() async {
    if (kIsWeb || Platform.isLinux) {
      // Periodic notifications are not supported on Linux or Web (yet)
      return;
    }

    // Using periodicallyShow as a robust workaround for zonedSchedule compilation issues
    await flutterLocalNotificationsPlugin.periodicallyShow(
      888,
      'Daily Reminder',
      'Add your expenses for today!',
      fln.RepeatInterval.daily,
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
        iOS: fln.DarwinNotificationDetails(),
        macOS: fln.DarwinNotificationDetails(),
        linux: fln.LinuxNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
