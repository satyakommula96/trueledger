import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

// Mocks
class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUpAll(() {
    // Required for some animations
    Animate.restartOnHotReload = true;
  });

  setUp(() {
    mockRepo = MockFinancialRepository();
    // Initialize static notifier for test
    CurrencyFormatter.currencyNotifier.value = '₹';
  });

  testWidgets('Dashboard renders loading state then data',
      (WidgetTester tester) async {
    // 1. Setup Data
    SharedPreferences.setMockInitialValues({'is_private_mode': false});
    final prefs = await SharedPreferences.getInstance();

    final summary = MonthlySummary(
      totalIncome: 5000,
      totalFixed: 1000,
      totalVariable: 500,
      totalSubscriptions: 200,
      totalInvestments: 500,
      netWorth: 10000,
    );

    // 2. Stub the repository
    when(() => mockRepo.getMonthlySummary()).thenAnswer((_) async => summary);
    when(() => mockRepo.getCategorySpending())
        .thenAnswer((_) => Future.value(<Map<String, dynamic>>[]));
    when(() => mockRepo.getBudgets())
        .thenAnswer((_) => Future.value(<Budget>[]));
    when(() => mockRepo.getSavingGoals())
        .thenAnswer((_) => Future.value(<SavingGoal>[]));
    when(() => mockRepo.getSpendingTrend())
        .thenAnswer((_) => Future.value(<Map<String, dynamic>>[]));
    when(() => mockRepo.getUpcomingBills())
        .thenAnswer((_) => Future.value(<Map<String, dynamic>>[]));
    when(() => mockRepo.getTodaySpend()).thenAnswer((_) async => 0);
    when(() => mockRepo.getWeeklySummary())
        .thenAnswer((_) async => {'thisWeek': 0, 'lastWeek': 0});
    when(() => mockRepo.getActiveStreak()).thenAnswer((_) async => 0);
    when(() => mockRepo.getTodayTransactionCount()).thenAnswer((_) async => 0);

    // 3. Build Widget with Override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Dashboard(),
        ),
      ),
    );

    // 4. Initial state (AsyncLoading) should show ProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 5. Allow AsyncValue to resolve
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify basic structure exists
    expect(find.byType(Dashboard), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });
}
