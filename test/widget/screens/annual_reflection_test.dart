import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/analysis/annual_reflection_screen.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/usecases/get_annual_reflection_usecase.dart';

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

  testWidgets('AnnualReflectionScreen renders with data',
      (WidgetTester tester) async {
    final reflectionData = AnnualReflectionData(
      year: 2026,
      totalSpendCurrentYear: 50000,
      totalSpendPreviousYear: 45000,
      categoryStability: [
        CategoryStability(
          category: 'Food',
          variance: 10.0,
          currentYearTotal: 11000,
          previousYearTotal: 10000,
        ),
      ],
      topCategory: 'Rent',
      mostExpensiveMonth: 12,
      avgMonthlySpend: 4166,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          annualReflectionProvider(2026)
              .overrideWith((ref) async => reflectionData),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AnnualReflectionScreen(year: 2026),
        ),
      ),
    );

    // Verify Loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Settle
    await tester.pumpAndSettle();

    // Verify Content
    expect(find.text("ANNUAL VOLUME"), findsOneWidget);
    expect(find.text("PEAK SPENDING"), findsOneWidget);
    expect(find.text("TOP CATEGORY"), findsOneWidget);
    expect(find.textContaining("reached"),
        findsOneWidget); // Part of the total spend description
    expect(find.textContaining("FOOD"), findsOneWidget); // Stability section
    expect(find.textContaining("RENT"), findsOneWidget); // Top category
  });

  testWidgets('AnnualReflectionScreen shows error view on failure',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          annualReflectionProvider(2026)
              .overrideWith((ref) async => throw Exception("Failed to load")),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AnnualReflectionScreen(year: 2026),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining("Failed to load"), findsOneWidget);
  });
}
