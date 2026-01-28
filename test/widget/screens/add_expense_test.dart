import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/result.dart';

class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}

void main() {
  late MockAddTransactionUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(AddTransactionParams(
      type: '',
      amount: 0,
      category: '',
      note: '',
      date: '',
    ));
  });

  setUp(() {
    mockUseCase = MockAddTransactionUseCase();
    when(() => mockUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));
  });

  Widget createWidget(AddExpense widget) {
    return ProviderScope(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(mockUseCase),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: widget,
      ),
    );
  }

  group('AddExpense Widget Tests', () {
    testWidgets('renders all entry types when not restricted', (tester) async {
      await tester.pumpWidget(createWidget(const AddExpense()));

      expect(find.text('INCOME'), findsOneWidget);
      expect(find.text('VARIABLE'), findsOneWidget);
      expect(find.text('FIXED'), findsOneWidget);
      expect(find.text('SUBSCRIPTION'), findsOneWidget);
      expect(find.text('INVESTMENT'), findsOneWidget);
    });

    testWidgets('hides entry type selector when allowedTypes has only one item',
        (tester) async {
      await tester.pumpWidget(createWidget(const AddExpense(
        initialType: 'Income',
        allowedTypes: ['Income'],
      )));

      expect(find.text('ENTRY TYPE'), findsNothing);
      expect(find.text('NEW INCOME'), findsOneWidget);
    });

    testWidgets('filters entry types based on allowedTypes', (tester) async {
      await tester.pumpWidget(createWidget(const AddExpense(
        initialType: 'Variable',
        allowedTypes: ['Variable', 'Fixed'],
      )));

      expect(find.text('VARIABLE'), findsOneWidget);
      expect(find.text('FIXED'), findsOneWidget);
      expect(find.text('INCOME'), findsNothing);
    });

    testWidgets('allows changing type and category', (tester) async {
      await tester.pumpWidget(createWidget(const AddExpense()));

      // Change type to Fixed
      await tester.tap(find.text('FIXED'));
      await tester.pump();

      // Category should default to Rent (first in categoryMap['Fixed'])
      expect(find.text('RENT'), findsOneWidget);
    });

    testWidgets('saves entry correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget(const AddExpense()));

      // Enter amount
      await tester.enterText(find.byType(TextField).first, '1000');

      // Enter note
      await tester.enterText(find.byType(TextField).last, 'Test Note');

      // Scroll to button
      final button = find.text('COMMIT TO LEDGER');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => mockUseCase.call(any())).called(1);
    });

    testWidgets('shows error when amount is empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget(const AddExpense()));

      // Tap Save without entering amount
      final button = find.text('COMMIT TO LEDGER');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });
  });
}
