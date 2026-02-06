import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/category_model.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/budget/add_budget.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    when(() => mockRepo.getAllValues('variable_expenses'))
        .thenAnswer((_) async => []);

    // Mock for categories
    final categories = [
      TransactionCategory(id: 1, name: 'Dining', type: 'Variable'),
      TransactionCategory(id: 2, name: 'Groceries', type: 'Variable'),
    ];
    // This mock might need adjustment depending on how categoriesProvider is implemented.
    // Usually it calls getAllValues or similar.
    // Assuming categoriesProvider calls getAllValues('variable_expenses') getting transactions,
    // or fetchCategories.
    // Let's assume categoriesProvider fetches distinct categories from repo or a specific method.
    // Checking ManageCategories logic... it uses repo.getCategories(type).
    // But AddBudget uses 'categoriesProvider'. Need to be careful.
    // Let's mock the provider or the repo method it relies on.
    when(() => mockRepo.getCategories('Variable'))
        .thenAnswer((_) async => categories);

    when(() => mockRepo.addBudget(any(), any())).thenAnswer((_) async => {});
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AddBudgetScreen(),
      ),
    );
  }

  testWidgets('AddBudgetScreen renders correctly', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('NEW BUDGET'), findsOneWidget);
    expect(find.text('CATEGORY IDENTIFIER'), findsOneWidget);
    expect(find.text('MONTHLY CEILING'), findsOneWidget);
    expect(find.text('ESTABLISH BUDGET'), findsOneWidget);
  });

  testWidgets('AddBudgetScreen validations work', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ESTABLISH BUDGET'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 500)); // Wait for fade in
    expect(find.text('Category cannot be empty'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Dining');
    await tester
        .pump(const Duration(seconds: 4)); // Wait for first Snackbar to go away
    await tester.tap(find.text('ESTABLISH BUDGET'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Limit cannot be empty'), findsOneWidget);
  });

  testWidgets('AddBudgetScreen submits successfully', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Dining');
    await tester.enterText(find.byType(TextField).last, '500');

    verifyNever(() => mockRepo.addBudget(any(), any()));

    await tester.tap(find.text('ESTABLISH BUDGET'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.addBudget('Dining', 500)).called(1);
    expect(find.byType(AddBudgetScreen), findsNothing); // Should have popped
  });

  testWidgets('AddBudgetScreen chip selection works', (tester) async {
    // Ensure provider returns data
    when(() => mockRepo.getCategories('Variable')).thenAnswer((_) async => [
          TransactionCategory(id: 1, name: 'Dining', type: 'Variable'),
        ]);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Check if chips are rendered
    // Note: The UI uppercases chip labels
    final chip = find.text('DINING');
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();

    // Check if text field is populated
    expect(find.widgetWithText(TextField, 'Dining'), findsOneWidget);
  });
}
