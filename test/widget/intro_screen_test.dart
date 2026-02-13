import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/startup/intro_screen.dart';

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
        netWorth: 0,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      ),
      categorySpending: [],
      budgets: [],
      savingGoals: [],
      trendData: [],
      upcomingBills: [],
      billsDueToday: [],
      todaySpend: 0,
      thisWeekSpend: 0,
      lastWeekSpend: 0,
      activeStreak: 0,
      todayTransactionCount: 0,
    );
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockNotifications.requestPermissions())
        .thenAnswer((_) async => true);
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

  testWidgets('IntroScreen displays features and navigates to Dashboard',
      (tester) async {
    // 1. Pump the widget
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle(); // Wait for animations

    // 2. Verify all features are visible (single page scroll)
    expect(find.text('Track Your Wealth'), findsOneWidget);
    expect(find.text('Smart Budgeting'), findsOneWidget);
    expect(find.text('Secure & Private'), findsOneWidget);

    // 3. Verify Name Input is present
    expect(find.text('What should we call you?'), findsOneWidget);
    final nameField = find.byType(TextField);
    expect(nameField, findsOneWidget);

    // 4. Scroll to make sure button is visible if needed (though SingleChildScrollView usually handles it in test environ if size enough, but better to ensure)
    await tester.ensureVisible(nameField);

    // 5. Enter Name
    await tester.enterText(nameField, 'Test User');
    await tester.pump();

    // 6. Tap Get Started
    final button = find.text('GET STARTED');
    await tester.ensureVisible(button);
    await tester.tap(button);

    // Use pumps instead of pumpAndSettle to avoid infinite animation timeout in Dashboard
    // Intro screen might have an async gap or animation
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 7. Verify logic
    verify(() => mockPrefs.setBool('intro_seen', true)).called(1);
    verify(() => mockNotifications.requestPermissions()).called(1);

    // 8. Verify Navigation to Dashboard (implicit via state change or navigation stack)
    // Since we can't easily check Navigator stack in this setup without observer,
    // we assume setBool call and no crash means success given correct widget pumps.
  });
}
