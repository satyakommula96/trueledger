import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/providers/lifecycle_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/usecases/manage_daily_digest_usecase.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/digest_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';

class MockManageDailyDigestUseCase extends Mock
    implements ManageDailyDigestUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

class _MockLifecycleNotifier extends AppLifecycleNotifier {
  final AppLifecycleState _initialState;
  _MockLifecycleNotifier(this._initialState);

  @override
  AppLifecycleState build() => _initialState;
}

void main() {
  late MockManageDailyDigestUseCase mockUseCase;
  late MockNotificationService mockNotifications;

  setUpAll(() {
    registerFallbackValue(AppRunContext.coldStart);
    registerFallbackValue(<BillSummary>[]);
  });

  setUp(() {
    mockUseCase = MockManageDailyDigestUseCase();
    mockNotifications = MockNotificationService();
  });

  test('DailyDigestCoordinator tracks dashboard changes and triggers UseCase',
      () async {
    final dashboardData = DashboardData(
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

    when(() => mockUseCase.execute(any(), any()))
        .thenAnswer((_) async => const NoAction());

    final container = ProviderContainer(
      overrides: [
        dashboardProvider.overrideWith((ref) => dashboardData),
        appLifecycleProvider.overrideWith(
            () => _MockLifecycleNotifier(AppLifecycleState.paused)),
        manageDailyDigestUseCaseProvider.overrideWithValue(mockUseCase),
        notificationServiceProvider.overrideWithValue(mockNotifications),
      ],
    );
    addTearDown(container.dispose);

    // Initial watch
    container.read(dailyDigestCoordinatorProvider);

    // Give it a microtask to run the whenData callback
    await Future.microtask(() {});

    verify(() => mockUseCase.execute(any(), AppRunContext.background))
        .called(1);
  });

  test('DailyDigestCoordinator triggers ShowDigestAction', () async {
    final bills = [
      BillSummary(id: '1', name: 'Bill 1', amount: 100, type: 'BILL')
    ];
    final dashboardData = DashboardData(
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
      billsDueToday: bills,
      todaySpend: 0,
      thisWeekSpend: 0,
      lastWeekSpend: 0,
      activeStreak: 0,
      todayTransactionCount: 0,
    );

    when(() => mockUseCase.execute(any(), any()))
        .thenAnswer((_) async => ShowDigestAction(bills));
    when(() => mockNotifications.showDailyBillDigest(any()))
        .thenAnswer((_) async => {});

    final container = ProviderContainer(
      overrides: [
        dashboardProvider.overrideWith((ref) => dashboardData),
        appLifecycleProvider.overrideWith(
            () => _MockLifecycleNotifier(AppLifecycleState.paused)),
        manageDailyDigestUseCaseProvider.overrideWithValue(mockUseCase),
        notificationServiceProvider.overrideWithValue(mockNotifications),
      ],
    );
    addTearDown(container.dispose);

    container.read(dailyDigestCoordinatorProvider);
    await Future.microtask(() {});

    verify(() => mockNotifications.showDailyBillDigest(bills)).called(1);
  });
}
