import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/startup/intro_screen.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockSharedPreferences mockPrefs;
  late DashboardData mockDashboardData;
  late MockNotificationService mockNotifications;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockNotifications = MockNotificationService();
    mockDashboardData = DashboardData(
      summary: MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
      ),
      categorySpending: [],
      budgets: [],
      savingGoals: [],
      trendData: [],
      upcomingBills: [],
    );
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockNotifications.requestPermissions())
        .thenAnswer((_) async => {});
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        dashboardProvider.overrideWith((ref) => mockDashboardData),
        notificationServiceProvider.overrideWithValue(mockNotifications),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const IntroScreen(),
      ),
    );
  }

  testWidgets('IntroScreen pages through to name and finishes', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Check first page
    expect(find.text('Track Your Wealth'), findsOneWidget);

    // Skip to the last page (Name page is at index 3, total 4 pages)
    // Page 0: Wealth
    // Page 1: Budget
    // Page 2: Privacy
    // Page 3: Name

    // Tap Next 3 times
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
    }

    // Should be on name page
    expect(find.text('What should we call you?'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byType(TextField), 'Satya');
    await tester.pumpAndSettle();

    // Tap Get Started
    await tester.tap(find.text('GET STARTED'));
    // Verify preference saves
    verify(() => mockPrefs.setBool('intro_seen', true)).called(1);
    verify(() => mockPrefs.setString('user_name', 'Satya')).called(1);

    // Pump repeatedly to allow navigation to finish
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Should navigate to Dashboard
    expect(find.byType(Dashboard), findsOneWidget);
  });

  testWidgets('IntroScreen skip works', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SKIP'));

    // Verify preference saves
    verify(() => mockPrefs.setBool('intro_seen', true)).called(1);
    // user_name should not be set if skipped without entering anything
    verifyNever(() => mockPrefs.setString('user_name', any()));

    // Pump repeatedly to allow navigation to finish
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.byType(Dashboard), findsOneWidget);
  });
}
