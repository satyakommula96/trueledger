import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/secure_storage_provider.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/screens/startup/lock_screen.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockIntelligenceService extends Mock implements IntelligenceService {}

class MockNotificationService extends Mock implements NotificationService {}

class MonthlySummaryFake extends Fake implements MonthlySummary {}

void main() {
  late MockSecureStorage mockStorage;
  late MockSharedPreferences mockPrefs;
  late MockFinancialRepository mockRepo;
  late MockIntelligenceService mockIntelligence;
  late MockNotificationService mockNotification;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(InsightSurface.main);
    registerFallbackValue(MonthlySummaryFake());
  });

  setUp(() {
    mockStorage = MockSecureStorage();
    mockPrefs = MockSharedPreferences();
    mockRepo = MockFinancialRepository();
    mockIntelligence = MockIntelligenceService();
    mockNotification = MockNotificationService();

    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => '1234');

    when(() => mockStorage.containsKey(key: 'recovery_key'))
        .thenAnswer((_) async => true);
    when(() => mockStorage.read(key: 'recovery_key'))
        .thenAnswer((_) async => 'RECOVERY-KEY-123');

    when(() => mockIntelligence.generateInsights(
          summary: any(named: 'summary'),
          trendData: any(named: 'trendData'),
          budgets: any(named: 'budgets'),
          categorySpending: any(named: 'categorySpending'),
          requestedSurface: any(named: 'requestedSurface'),
        )).thenReturn([]);

    when(() => mockNotification.init()).thenAnswer((_) async => {});
  });

  Widget createLockScreen() {
    return ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(mockStorage),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        financialRepositoryProvider.overrideWithValue(mockRepo),
        intelligenceServiceProvider.overrideWithValue(mockIntelligence),
        notificationServiceProvider.overrideWithValue(mockNotification),
        dashboardProvider.overrideWith((ref) => DashboardData(
              summary: MonthlySummary(
                  totalIncome: 0,
                  totalFixed: 0,
                  totalVariable: 0,
                  totalSubscriptions: 0,
                  totalInvestments: 0,
                  netWorth: 0,
                  creditCardDebt: 0,
                  loansTotal: 0,
                  totalMonthlyEMI: 0),
              categorySpending: [],
              budgets: [],
              savingGoals: [],
              trendData: [],
              upcomingBills: [],
              todaySpend: 0,
              thisWeekSpend: 0,
              lastWeekSpend: 0,
              activeStreak: 0,
              todayTransactionCount: 0,
            )),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LockScreen(expectedPinLength: 4),
      ),
    );
  }

  testWidgets('Should show PIN dots and react to digit press', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createLockScreen());
    await tester.pumpAndSettle();

    expect(find.text('Enter PIN'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pump();

    expect(find.text('Incorrect PIN'), findsNothing);
  });

  testWidgets('Should navigate to Dashboard on correct PIN', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createLockScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('4'));

    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsNothing);
  });

  testWidgets('Should show error on incorrect PIN', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createLockScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('1'));

    await tester.pumpAndSettle();

    expect(find.text('Incorrect PIN'), findsOneWidget);
  });

  testWidgets('Should handle forgot PIN options', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createLockScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot PIN?'));
    await tester.pumpAndSettle();

    expect(find.text('Trouble logging in?'), findsOneWidget);
    expect(find.text('Use Recovery Key'), findsOneWidget);
    expect(find.text('Reset Application'), findsOneWidget);
  });
}
