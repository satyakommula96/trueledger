import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/dashboard/weekly_reflection.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/components/error_view.dart';

// Mocks
class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepo = MockFinancialRepository();
  });

  testWidgets('WeeklyReflectionScreen renders with data',
      (WidgetTester tester) async {
    // 1. Setup Data
    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => []); // No transactions means 0 spend

    when(() => mockRepo.getBudgets()).thenAnswer((_) async =>
        [Budget(id: 1, category: 'Food', monthlyLimit: 30000, spent: 0)]);

    when(() => mockRepo.getCategorySpendingForRange(any(), any()))
        .thenAnswer((_) async => []);

    final reflectionData = WeeklyReflectionData(
      daysUnderBudget: 7,
      budgetDailyAverage: 1000,
      totalThisWeek: 5000,
      totalLastWeek: 6000,
      topCategory: 'Food',
      largestCategoryIncrease: null,
    );

    // 2. Build Widget with Override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          weeklyReflectionProvider.overrideWith((ref) async => reflectionData),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WeeklyReflectionScreen(),
        ),
      ),
    );

    // 3. Verify Loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 4. Settle
    await tester.pumpAndSettle();

    // 5. Verify Content
    if (find.byType(AppErrorView).evaluate().isNotEmpty) {
      // final errorView = tester.widget<AppErrorView>(find.byType(AppErrorView));
      // debugPrint("FOUND ERROR VIEW: ${errorView.error}");
    }

    expect(find.text("SPENDING CONSISTENCY"), findsOneWidget);
    expect(find.text("VOLUME COMPARISON"), findsOneWidget);
    expect(find.text("GENTLE GOAL"), findsOneWidget);
    expect(find.textContaining("Perfect week"), findsOneWidget);
  });
}
