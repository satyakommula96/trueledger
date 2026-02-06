import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/result.dart';

import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/models/models.dart';

class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockAddTransactionUseCase mockUseCase;
  late MockNotificationService mockNotificationService;
  late MockFinancialRepository mockRepository;

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
    mockNotificationService = MockNotificationService();
    mockRepository = MockFinancialRepository();

    when(() => mockUseCase.call(any()))
        .thenAnswer((_) async => Success(AddTransactionResult()));

    // Mock category fetching for all types
    when(() => mockRepository.getCategories(any()))
        .thenAnswer((invocation) async {
      final type = invocation.positionalArguments[0] as String;
      switch (type) {
        case 'Variable':
          return [TransactionCategory(id: 1, name: 'Food', type: 'Variable')];
        case 'Fixed':
          return [TransactionCategory(id: 2, name: 'Rent', type: 'Fixed')];
        case 'Income':
          return [TransactionCategory(id: 3, name: 'Salary', type: 'Income')];
        case 'Investment':
          return [
            TransactionCategory(id: 4, name: 'Stocks', type: 'Investment')
          ];
        case 'Subscription':
          return [
            TransactionCategory(id: 5, name: 'OTT', type: 'Subscription')
          ];
        default:
          return [];
      }
    });
  });

  Widget createWidget(AddExpense widget) {
    return ProviderScope(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(mockUseCase),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        financialRepositoryProvider.overrideWithValue(mockRepository),
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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('ENTRY TYPE'), findsNothing);
      expect(find.text('NEW INCOME'), findsOneWidget);
    });

    testWidgets('filters entry types based on allowedTypes', (tester) async {
      await tester.pumpWidget(createWidget(const AddExpense(
        initialType: 'Variable',
        allowedTypes: ['Variable', 'Fixed'],
      )));
      await tester.pumpAndSettle();

      expect(find.text('VARIABLE'), findsOneWidget);
      expect(find.text('FIXED'), findsOneWidget);
      expect(find.text('INCOME'), findsNothing);
    });

    testWidgets('allows changing type and category', (tester) async {
      await tester.pumpWidget(createWidget(const AddExpense()));
      await tester.pumpAndSettle();

      // Change type to Fixed
      await tester.tap(find.text('FIXED'));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Tap Save without entering amount
      final button = find.text('COMMIT TO LEDGER');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });
  });
}
