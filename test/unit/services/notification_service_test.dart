import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/services/notification_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NotificationService notificationService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    notificationService = NotificationService(mockPrefs);
  });

  group('NotificationService', () {
    test('routes constants are correct', () {
      expect(NotificationService.routeDashboard, '/dashboard');
      expect(NotificationService.routeCards, '/cards');
    });

    test('dailyReminderId and creditCardBaseId are correct', () {
      expect(NotificationService.dailyReminderId, 888);
      expect(NotificationService.creditCardBaseId, 10000);
    });

    test('getPendingNotifications returns empty list if no prefs', () async {
      when(() => mockPrefs.getString('scheduled_notifications'))
          .thenReturn(null);
      final notifications = await notificationService.getPendingNotifications();
      expect(notifications, isEmpty);
    });

    test('getPendingNotifications returns parsed list', () async {
      const jsonStr =
          '[{"id": 1, "title": "Test", "body": "Body", "payload": "payload"}]';
      when(() => mockPrefs.getString('scheduled_notifications'))
          .thenReturn(jsonStr);

      final notifications = await notificationService.getPendingNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.id, 1);
      expect(notifications.first.title, "Test");
      expect(notifications.first.body, "Body");
      expect(notifications.first.payload, "payload");
    });

    test('getPendingNotifications handles corrupt json', () async {
      when(() => mockPrefs.getString('scheduled_notifications'))
          .thenReturn("{corrupt json");
      final notifications = await notificationService.getPendingNotifications();
      expect(notifications, isEmpty);
    });

    test('stream emits correct types upon mutation', () async {
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);

      final events = <NotificationChangeType>[];
      final subscription =
          notificationService.onNotificationsChanged.listen(events.add);

      // Trigger "added" via a public method
      await notificationService.scheduleDailyReminder();
      await Future.delayed(Duration.zero);

      // Trigger "removed" via a public method
      await notificationService
          .cancelNotification(NotificationService.dailyReminderId);
      await Future.delayed(Duration.zero);

      // Trigger "cleared" via a public method
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      await notificationService.cancelAllNotifications();
      await Future.delayed(Duration.zero);

      expect(events, [
        NotificationChangeType.added,
        NotificationChangeType.removed,
        NotificationChangeType.cleared,
      ]);

      await subscription.cancel();
    });
  });
}
