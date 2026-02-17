import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/transactions/transactions_detail.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import '../../helpers/test_wrapper.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepo = MockFinancialRepository();
    CurrencyFormatter.currencyNotifier.value = '₹';
  });

  testWidgets('TransactionsDetailScreen renders transactions',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final items = [
      LedgerItem(
          id: 1,
          type: 'Variable',
          label: 'Food',
          amount: 50,
          date: DateTime(2026, 2, 1)),
      LedgerItem(
          id: 2,
          type: 'Income',
          label: 'Salary',
          amount: 5000,
          date: DateTime(2026, 2, 1)),
    ];

    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => items);

    await tester.pumpWidget(
      wrapWidget(
        TransactionsDetailScreen(
          title: 'Test Range',
          startDate: DateTime(2026, 2, 1),
          endDate: DateTime(2026, 2, 28),
        ),
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      ),
    );

    // Allow multiple pumps for internal state changes and animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('TEST RANGE'), findsOneWidget);
    expect(find.text('FOOD'), findsOneWidget);
    expect(find.text('SALARY'), findsOneWidget);
    expect(find.textContaining('50'), findsWidgets);
    expect(find.textContaining('5'), findsWidgets);
  });

  testWidgets('TransactionsDetailScreen filters by search',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final items = [
      LedgerItem(
          id: 1,
          type: 'Variable',
          label: 'Food',
          amount: 50,
          date: DateTime(2026, 2, 1)),
      LedgerItem(
          id: 2,
          type: 'Income',
          label: 'Salary',
          amount: 5000,
          date: DateTime(2026, 2, 1)),
    ];

    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => items);

    await tester.pumpWidget(
      wrapWidget(
        TransactionsDetailScreen(
          title: 'Test Range',
          startDate: DateTime(2026, 2, 1),
          endDate: DateTime(2026, 2, 28),
        ),
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'food');
    await tester.pumpAndSettle();

    expect(find.text('FOOD'), findsOneWidget);
    expect(find.text('SALARY'), findsNothing);
  });
}
