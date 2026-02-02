import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();

    when(() => mockRepo.getMonthDetails(any())).thenAnswer((_) async => []);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  Widget createWidget(MonthDetailScreen screen) {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: screen,
      ),
    );
  }

  group('MonthDetailScreen Navigation Tests', () {
    testWidgets('FAB passes correct allowedTypes for Income filter',
        (tester) async {
      await tester
          .pumpWidget(createWidget(const MonthDetailScreen(month: '2026-01')));

      // Select Income filter
      await tester.tap(find.text('INCOME'));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify AddExpense is shown with restricted type
      expect(find.byType(AddExpense), findsOneWidget);
      expect(find.text('NEW INCOME'), findsOneWidget);
    });

    testWidgets('FAB passes correct allowedTypes for Expenses filter',
        (tester) async {
      await tester
          .pumpWidget(createWidget(const MonthDetailScreen(month: '2026-01')));

      // Select Expenses filter
      await tester.tap(find.text('EXPENSES'));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddExpense), findsOneWidget);
      expect(find.text('VARIABLE'), findsOneWidget);
      expect(find.text('FIXED'), findsOneWidget);
      expect(find.text('SUBSCRIPTION'), findsOneWidget);
      expect(find.text('INCOME'), findsNothing);
    });
  });
}
