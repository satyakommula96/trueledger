import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/budget/budget_screen.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();

    // Register fallbacks for mocktail
    registerFallbackValue(const Duration(seconds: 1));

    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getDouble(any())).thenReturn(null);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn(null);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

    // Default mocks to avoid unhandled calls
    when(() => mockRepo.getBudgets()).thenAnswer((_) async => <Budget>[]);
    when(() => mockRepo.getSpendingTrend())
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => mockRepo.getCategorySpending())
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => mockRepo.getCategories(any()))
        .thenAnswer((_) async => <TransactionCategory>[]);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BudgetScreen(),
      ),
    );
  }

  group('BudgetScreen', () {
    testWidgets('displays loading state', (tester) async {
      when(() => mockRepo.getBudgets()).thenAnswer((_) => Future.delayed(
            const Duration(milliseconds: 50),
            () => <Budget>[],
          ));

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('displays budgets and spending limits', (tester) async {
      final testBudgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 5000, spent: 2000),
        Budget(id: 2, category: 'Rent', monthlyLimit: 15000, spent: 15000),
      ];

      when(() => mockRepo.getBudgets()).thenAnswer((_) async => testBudgets);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('BUDGETS'), findsOneWidget);
      expect(find.text('Spending Limits'), findsOneWidget);
      expect(find.text('FOOD'), findsOneWidget);
      expect(find.text('RENT'), findsOneWidget);
    });

    testWidgets('navigates to AddBudgetScreen when FAB is pressed',
        (tester) async {
      when(() => mockRepo.getBudgets()).thenAnswer((_) async => <Budget>[]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('CATEGORY IDENTIFIER'), findsOneWidget);
    });
  });
}
