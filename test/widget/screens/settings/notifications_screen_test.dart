import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/screens/settings/notifications_screen.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();
    // Default empty list
    when(() => mockService.getPendingNotifications())
        .thenAnswer((_) async => []);
    when(() => mockService.onNotificationsChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockService.cancelNotification(any())).thenAnswer((_) async {});
    when(() => mockService.cancelAllNotifications()).thenAnswer((_) async {});
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(mockService),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const NotificationsScreen(),
      ),
    );
  }

  testWidgets('NotificationsScreen renders empty state', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('NOTIFICATIONS'), findsOneWidget);
    expect(find.text('NO SCHEDULED ALERTS'), findsOneWidget);
  });

  testWidgets('NotificationsScreen renders items', (tester) async {
    final notifications = [
      const PendingNotificationRequest(
        1,
        'Bill Reminder',
        'Pay electricity bill',
        'test',
      ),
    ];
    when(() => mockService.getPendingNotifications())
        .thenAnswer((_) async => notifications);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('BILL REMINDER'), findsOneWidget);
    expect(find.text('Pay electricity bill'), findsOneWidget);
  });

  testWidgets('NotificationsScreen cancels single notification',
      (tester) async {
    final notifications = [
      const PendingNotificationRequest(
        1,
        'Bill Reminder',
        'Pay electricity bill',
        'test',
      ),
    ];
    when(() => mockService.getPendingNotifications())
        .thenAnswer((_) async => notifications);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final cancelBtn = find.byIcon(Icons.close_rounded);
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    expect(find.text('CANCEL NOTIFICATION'), findsOneWidget);
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();

    verify(() => mockService.cancelNotification(1)).called(1);
    expect(find.text('NOTIFICATION "Bill Reminder" CANCELLED'), findsOneWidget);
  });

  testWidgets('NotificationsScreen cancels all', (tester) async {
    final notifications = [
      const PendingNotificationRequest(1, 'A', 'B', 'C'),
    ];
    when(() => mockService.getPendingNotifications())
        .thenAnswer((_) async => notifications);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final deleteDetails = find.byTooltip('Cancel All');
    await tester.tap(deleteDetails);
    await tester.pumpAndSettle();

    expect(find.text('CANCEL ALL NOTIFICATIONS'), findsOneWidget);
    await tester.tap(find.text('YES, CANCEL ALL'));
    await tester.pumpAndSettle();

    verify(() => mockService.cancelAllNotifications()).called(1);
    expect(find.text('ALL NOTIFICATIONS CANCELLED'), findsOneWidget);
  });
}
