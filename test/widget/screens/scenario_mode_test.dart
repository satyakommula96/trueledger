import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/scenario_mode.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/models/models.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
  });

  testWidgets('ScenarioScreen renders and allows interaction',
      (WidgetTester tester) async {
    final dashboardData = DashboardData(
      summary: MonthlySummary(
        totalIncome: 1000,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      ),
      categorySpending: [
        {'category': 'Eating Out', 'total': 1000},
      ],
      budgets: [],
      savingGoals: [],
      trendData: [],
      upcomingBills: [],
      todaySpend: 0,
      thisWeekSpend: 0,
      lastWeekSpend: 0,
      activeStreak: 0,
      todayTransactionCount: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          dashboardProvider.overrideWith((ref) async => dashboardData),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScenarioScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Scenario Mode"), findsOneWidget);
    expect(find.text("Eating Out"), findsOneWidget);

    // Verify initial savings (20% of 1000 = 200 monthly, 2400 yearly)
    expect(find.textContaining("2,400"), findsOneWidget);

    // Slide to 50%
    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pumpAndSettle();

    // After drag, value should change. Check if 50% or so is visible.
    // (Actual drag distance to % mapping depends on screen width, but we can verify it changed)
  });
}
