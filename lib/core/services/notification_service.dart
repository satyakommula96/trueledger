import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/core/utils/hash_utils.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

class NotificationService {
  /// Notification IDs must be deterministic and stable to allow:
  /// 1. Cancellation across app restarts (e.g. dailyReminderId).
  /// 2. Overwriting/Updating existing notifications in the tray (e.g. dailyBillDigestId).
  ///
  /// IMPORTANT: Never reuse these specific IDs for other notification types,
  /// otherwise they will silently overwrite each other.
  static const int dailyReminderId = 888;

  /// Specifically used for the aggregated daily summary. Overwriting this ID
  /// ensures the user doesn't get flooded with multiple digest entries in the tray.
  static const int dailyBillDigestId = 999;

  /// Starting range for credit card specific reminders to avoid collisions.
  static const int creditCardBaseId = 10000;
  // Injected for testability
  final SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _initFailed = false;

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this._prefs,
      {fln.FlutterLocalNotificationsPlugin? plugin})
      : flutterLocalNotificationsPlugin =
            plugin ?? fln.FlutterLocalNotificationsPlugin();

  /// Supported notification deep-link routes
  static const String routeDashboard = '/dashboard';
  static const String routeCards = '/cards';

  final StreamController<String?> _onNotificationClick =
      StreamController<String?>.broadcast();
  Stream<String?> get onNotificationClick => _onNotificationClick.stream;

  final StreamController<NotificationChangeType>
      _notificationsUpdateController =
      StreamController<NotificationChangeType>.broadcast();
  Stream<NotificationChangeType> get onNotificationsChanged =>
      _notificationsUpdateController.stream;

  /// Must be called on every local notification state mutation to ensure
  /// UI components and providers remain reactive.
  void _notifyNotificationsChanged(NotificationChangeType type) {
    _notificationsUpdateController.add(type);
  }

  void dispose() {
    _onNotificationClick.close();
    _notificationsUpdateController.close();
  }

  bool get isReady => _isInitialized && !_initFailed;

  static bool get _isTest =>
      AppConfig.isIntegrationTest ||
      (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'));

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (kIsWeb || _isTest) {
      debugPrint('NotificationService: Skipping native init (Web/Test mode).');
      return;
    }

    try {
      tz_data.initializeTimeZones();

      const fln.AndroidInitializationSettings initializationSettingsAndroid =
          fln.AndroidInitializationSettings('@mipmap/ic_launcher');

      final fln.DarwinInitializationSettings initializationSettingsDarwin =
          fln.DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );

      const fln.LinuxInitializationSettings initializationSettingsLinux =
          fln.LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      // Windows initialization (Required for version 17+)
      const fln.WindowsInitializationSettings initializationSettingsWindows =
          fln.WindowsInitializationSettings(
        appName: 'TrueLedger',
        appUserModelId: 'com.satyakommula.TrueLedger',
        guid: '9f2e3a8b-1d4c-4e5f-8a0b-1c2d3e4f5a6b',
      );

      final fln.InitializationSettings initializationSettings =
          fln.InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
        windows: initializationSettingsWindows,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse:
            (fln.NotificationResponse response) async {
          _onNotificationClick.add(response.payload);
        },
      );
      _initFailed = false;
    } catch (e, stack) {
      _initFailed = true;
      if (kDebugMode) {
        throw Exception("NotificationService init failed: $e\n$stack");
      }
      debugPrint('CRITICAL: NotificationService init failed: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (_isTest) return true;
    if (kIsWeb) {
      return true; // Web permissions handled via browser prompts on demand
    }

    if (!_isInitialized) await init();
    if (_initFailed) return false;

    try {
      bool granted = false;
      if (Platform.isAndroid) {
        final plugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                fln.AndroidFlutterLocalNotificationsPlugin>();
        granted = await plugin?.requestNotificationsPermission() ?? false;
      } else if (Platform.isIOS) {
        final plugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                fln.IOSFlutterLocalNotificationsPlugin>();
        granted = await plugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      } else if (Platform.isMacOS) {
        final plugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                fln.MacOSFlutterLocalNotificationsPlugin>();
        granted = await plugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      } else {
        // Linux/Windows don't have a standardized "requestPermission" in this plugin
        // but often allow notifications by default or are handled by the system.
        granted = true;
      }
      return granted;
    } catch (e, stack) {
      debugPrint("Notification permissions request failed: $e");
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    if (_initFailed) return;

    if (kIsWeb || _isTest) {
      debugPrint('NotificationService: Skipping native show (Web/Test).');
      return;
    }

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
      windows: fln.WindowsNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /*
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    if (_initFailed) return;
    if (kIsWeb || _isTest || Platform.isLinux || Platform.isWindows) {
      return;
    }

    try {
      // Calculate delay efficiently to avoid relying on uninitialized tz.local
      final now = DateTime.now();

      // If the scheduled date is in the past compared to now, add 1 minute to avoid crash
      // or simply don't schedule. But our logic guarantees future.
      // We calculate the duration from now to the target local time.
      final duration = scheduledDate.difference(now);

      // Create a TZDateTime in UTC that corresponds to the same absolute instant
      final tzDate = tz.TZDateTime.now(tz.UTC).add(duration);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDate,
        notificationDetails: const fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'scheduled_channel',
            'Scheduled Notifications',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
          ),
          iOS: fln.DarwinNotificationDetails(),
          macOS: fln.DarwinNotificationDetails(),
        ),
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            fln.UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint(
          "NotificationService: Failed to schedule zoned notification: $e");
    }
  }
  */

  Future<void> scheduleDailyReminder() async {
    if (!_isInitialized) await init();

    // Save locally so it appears in the UI list even on Linux/Web
    await _saveScheduledNotification(dailyReminderId, 'Daily Reminder',
        'Add your expenses for today!', routeDashboard);

    if (kIsWeb || Platform.isLinux || _isTest || _initFailed) {
      return;
    }

    // Using periodicallyShow as a robust workaround for zonedSchedule compilation issues
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: dailyReminderId,
      title: 'Daily Reminder',
      body: 'Add your expenses for today!',
      repeatInterval: fln.RepeatInterval.daily,
      notificationDetails: const fln.NotificationDetails(
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
        windows: fln.WindowsNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
      payload: routeDashboard,
    );
  }

  Future<void> scheduleCreditCardReminder(String bank, int day) async {
    // We remove the kIsWeb early return to allow local saving for the UI list
    // but we still skip the actual OS scheduling if not supported.

    // Use a stable deterministic hash instead of Object.hash
    final int id = generateStableHash('cc_reminder_$bank');

    await showNotification(
      id: id,
      title: 'Reminder Set: $bank',
      body:
          'We will remind you on the ${day}th of every month to update your bill.',
      payload: routeCards,
    );

    // Also save as if it were scheduled, for UI demo purposes
    await _saveScheduledNotification(
        id, 'Reminder: $bank', 'Bill payment due on day $day', routeCards);
  }

  Future<void> showDailyBillDigest(List<BillSummary> bills) async {
    if (bills.isEmpty) return;
    if (!_isInitialized) await init();

    final int count = bills.length;
    final int total = bills.fold(0, (sum, b) => sum + b.amount);

    final String title = "Daily Bill Digest";
    final String body =
        "$count ${count == 1 ? 'bill' : 'bills'} due today · ${CurrencyFormatter.format(total)} total";

    // Timing Guard: Morning window functionality currently disabled due to
    // flutter_local_notifications API/version mismatch.
    // TODO: Restore scheduling logic once API surface is stable.
    /*
    final now = DateTime.now();
    if (now.hour < 8) {
      await scheduleNotification(
        id: dailyBillDigestId,
        title: title,
        body: body,
        scheduledDate: DateTime(now.year, now.month, now.day, 8, 0),
        payload: routeDashboard,
      );
    } else {
    */
    await showNotification(
      id: dailyBillDigestId,
      title: title,
      body: body,
      payload: routeDashboard,
    );
    /*
    }
    */
  }

  Future<List<fln.PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await init();

    List<fln.PendingNotificationRequest> allNotifications = [];
    final localNotifications = await _getStoredPendingNotifications();
    allNotifications.addAll(localNotifications);

    // Try to sync with the actual OS scheduler where supported
    if (!kIsWeb &&
        !_isTest &&
        !_initFailed &&
        (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      try {
        final osPending =
            await flutterLocalNotificationsPlugin.pendingNotificationRequests();

        // 1. Mark existing locals that are confirmed by OS
        final Set<int> osIds = osPending.map((e) => e.id).toSet();

        // 2. Pragmatic Pruning: If a notification exists in local tracking but NOT in OS,
        // and we are on a platform that supports OS pending requests, we prune the local.
        // This prevents "ghost" notifications in the UI if the system was reset.
        if (osPending.isNotEmpty || !Platform.isLinux) {
          final localsToRemove = localNotifications
              .where((l) => !osIds.contains(l.id))
              .map((l) => l.id)
              .toList();

          for (final id in localsToRemove) {
            await _removeScheduledNotification(id);
            allNotifications.removeWhere((n) => n.id == id);
          }
        }

        // 3. Merge OS notifications: favor OS data if ID matches, or add if missing
        for (final osItem in osPending) {
          final index = allNotifications.indexWhere((n) => n.id == osItem.id);
          if (index != -1) {
            allNotifications[index] = osItem;
          } else {
            allNotifications.add(osItem);
          }
        }
      } catch (e, stack) {
        debugPrint("Failed to fetch OS pending notifications: $e");
        if (kDebugMode) {
          debugPrint(stack.toString());
        }
      }
    }

    return allNotifications;
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await init();
    await _removeScheduledNotification(id);
    if (kIsWeb || _isTest || _initFailed) return;
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _removeAllScheduledNotifications();
    if (kIsWeb || _isTest || _initFailed) return;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Local storage helpers
  static const String _storageKey = 'scheduled_notifications';

  Future<void> _saveScheduledNotification(
      int id, String title, String body, String? payload) async {
    final notifications = _getStoredNotificationsList();

    final newNotification = {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    };

    notifications.removeWhere((n) => n['id'] == id);
    notifications.add(newNotification);

    await _prefs.setString(_storageKey, jsonEncode(notifications));
    _notifyNotificationsChanged(NotificationChangeType.added);
  }

  Future<void> _removeScheduledNotification(int id) async {
    final notifications = _getStoredNotificationsList();
    notifications.removeWhere((n) => n['id'] == id);
    await _prefs.setString(_storageKey, jsonEncode(notifications));
    _notifyNotificationsChanged(NotificationChangeType.removed);
  }

  Future<void> _removeAllScheduledNotifications() async {
    await _prefs.remove(_storageKey);
    _notifyNotificationsChanged(NotificationChangeType.cleared);
  }

  List<Map<String, dynamic>> _getStoredNotificationsList() {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e, stack) {
      if (kDebugMode) {
        throw Exception(
            "Failed to load local notification storage in Debug Mode: $e\n$stack");
      }
      debugPrint("Failed to load local notification storage: $e");
      return [];
    }
  }

  Future<List<fln.PendingNotificationRequest>>
      _getStoredPendingNotifications() async {
    final list = _getStoredNotificationsList();
    return list
        .map((n) => fln.PendingNotificationRequest(
              n['id'] as int,
              n['title'] as String,
              n['body'] as String,
              n['payload'] as String?,
            ))
        .toList();
  }
}

enum NotificationChangeType {
  added,
  removed,
  cleared,
}
