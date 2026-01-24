import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';
import 'package:truecash/presentation/screens/dashboard.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/core/utils/currency_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    CurrencyHelper.currencyNotifier.value = '₹';
  });

  testWidgets('Dashboard renders loading state then data',
      (WidgetTester tester) async {
    // 1. Setup Data
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

    // 3. Build Widget with Override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
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
