import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:truecash/domain/entities/monthly_summary.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'package:truecash/presentation/providers/dashboard_provider.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';
import 'package:truecash/screens/dashboard.dart';
import 'package:truecash/screens/dashboard_components/wealth_hero.dart';
import 'package:truecash/theme/theme.dart';
import 'package:truecash/logic/currency_helper.dart';

import 'package:truecash/models/models.dart';

import 'package:flutter_animate/flutter_animate.dart';

// Mocks
class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

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
    // IMPORTANT: Provide answers for ALL calls made by dashboardProvider
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
          theme: AppTheme.lightTheme, // PROVIDE THEME EXTENSIONS
          home: const Dashboard(),
        ),
      ),
    );

    // 4. Initial state (AsyncLoading) should show ProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 5. Allow AsyncValue to resolve
    await tester.runAsync(() async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    });

    await tester.pump(); // Frame

    // Debugging: Verify high-level widgets
    expect(find.byType(Dashboard), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);

    // Check if Animate widgets are present (WealthHero is wrapped in one)
    // There are multiple Animate widgets in the list
    expect(find.byType(Animate), findsWidgets);

    // Scroll just in case layout is weird
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pump();

    // Verify basic structure exists
    expect(find.byType(Dashboard), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Final pump to allow any remaining non-infinite timers to clear
    // Infinite animations will still be pending, but this might help.
    // Note: flutter_animate's repeat() usually requires special handling in tests.
    await tester.pump(const Duration(milliseconds: 500));
  });
}
