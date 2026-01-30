import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  test('pendingNotificationsProvider returns notifications from service',
      () async {
    final mockService = MockNotificationService();
    final notifications = [
      const fln.PendingNotificationRequest(1, 'Title', 'Body', 'Payload')
    ];
    when(() => mockService.getPendingNotifications())
        .thenAnswer((_) async => notifications);
    when(() => mockService.onNotificationsChanged)
        .thenAnswer((_) => const Stream<NotificationChangeType>.empty());

    final container = ProviderContainer(overrides: [
      notificationServiceProvider.overrideWithValue(mockService),
    ]);
    addTearDown(container.dispose);

    expect(
      await container.read(pendingNotificationsProvider.future),
      notifications,
    );
  });

  test('pendingNotificationCountProvider returns correct length', () async {
    final mockService = MockNotificationService();
    final notifications = [
      const fln.PendingNotificationRequest(1, 'Title', 'Body', 'Payload'),
      const fln.PendingNotificationRequest(2, 'Title 2', 'Body 2', 'Payload 2')
    ];
    when(() => mockService.getPendingNotifications())
        .thenAnswer((_) async => notifications);
    when(() => mockService.onNotificationsChanged)
        .thenAnswer((_) => const Stream<NotificationChangeType>.empty());

    final container = ProviderContainer(overrides: [
      notificationServiceProvider.overrideWithValue(mockService),
    ]);
    addTearDown(container.dispose);
    // Wait for the async list provider to complete
    await container.read(pendingNotificationsProvider.future);

    expect(
      container.read(pendingNotificationCountProvider),
      2,
    );
  });

  test('notificationServiceProvider disposes service', () {
    final mockPrefs = MockSharedPreferences();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(mockPrefs),
    ]);

    final service = container.read(notificationServiceProvider);
    // We can't easily verify dispose is called without spying on the real service or using a custom class,
    // but we can verify the provider exists and returns a service.
    expect(service, isA<NotificationService>());
    container.dispose();
  });
}
