import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/automation/recurring_transactions.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/constants/widget_keys.dart';
import '../helpers/currency_test_helpers.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const RecurringTransactionsScreen(),
      ),
    );
  }

  group('RecurringTransactionsScreen', () {
    testWidgets('displays empty state when no transactions exist',
        (tester) async {
      when(() => mockRepo.getRecurringTransactions())
          .thenAnswer((_) async => <RecurringTransaction>[]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // We still verify text for descriptive empty states, but keys are preferred for structural elements
      expect(find.text('NO AUTOMATED TRANSACTIONS YET.'), findsOneWidget);
    });

    testWidgets('displays list of recurring transactions', (tester) async {
      final List<RecurringTransaction> transactions = [
        RecurringTransaction(
          id: 1,
          name: 'Rent',
          amount: 15000,
          category: 'Housing',
          type: 'EXPENSE',
          frequency: 'MONTHLY',
          dayOfMonth: 1,
        ),
        RecurringTransaction(
          id: 2,
          name: 'Salary',
          amount: 50000,
          category: 'Income',
          type: 'INCOME',
          frequency: 'MONTHLY',
          dayOfMonth: 1,
        ),
      ];

      when(() => mockRepo.getRecurringTransactions())
          .thenAnswer((_) async => transactions);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify items by their unique keys
      expect(find.byKey(WidgetKeys.recurringItem(1)), findsOneWidget);
      expect(find.byKey(WidgetKeys.recurringItem(2)), findsOneWidget);

      // Verify behavior/data: exact formatted amounts
      expect(findFormattedAmount(15000), findsOneWidget);
      expect(findFormattedAmount(50000), findsOneWidget);

      // Verify labels are present but secondary to keys/amounts
      expect(find.text('RENT'), findsOneWidget);
      expect(find.text('SALARY'), findsOneWidget);
    });

    testWidgets('opens add dialog when FAB is pressed', (tester) async {
      when(() => mockRepo.getRecurringTransactions())
          .thenAnswer((_) async => <RecurringTransaction>[]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Use key for navigation trigger
      await tester.tap(find.byKey(WidgetKeys.addRecurringFab));
      await tester.pumpAndSettle();

      // Verify dialog appearance
      expect(find.text('NEW AUTOMATION'), findsOneWidget);
      expect(find.byKey(WidgetKeys.saveButton), findsOneWidget);
    });

    testWidgets('calls delete when delete icon is pressed', (tester) async {
      final List<RecurringTransaction> transactions = [
        RecurringTransaction(
          id: 1,
          name: 'Rent',
          amount: 15000,
          category: 'Housing',
          type: 'EXPENSE',
          frequency: 'MONTHLY',
          dayOfMonth: 1,
        ),
      ];

      when(() => mockRepo.getRecurringTransactions())
          .thenAnswer((_) async => transactions);
      when(() => mockRepo.deleteItem('recurring_transactions', 1))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Use key for delete action
      await tester.tap(find.byKey(WidgetKeys.deleteButton));
      await tester.pumpAndSettle();

      // Verification of immediate deletion - no confirmation dialog in current design
      verify(() => mockRepo.deleteItem('recurring_transactions', 1)).called(1);
    });
  });
}
