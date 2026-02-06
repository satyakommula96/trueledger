import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/screens/budget/edit_budget.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/budget_usecases.dart';
import 'package:trueledger/core/utils/result.dart';

import 'package:trueledger/core/theme/theme.dart';

class MockUpdateBudgetUseCase extends Mock implements UpdateBudgetUseCase {}

class MockDeleteBudgetUseCase extends Mock implements DeleteBudgetUseCase {}

class MockMarkBudgetAsReviewedUseCase extends Mock
    implements MarkBudgetAsReviewedUseCase {}

void main() {
  late MockUpdateBudgetUseCase mockUpdate;
  late MockDeleteBudgetUseCase mockDelete;
  late MockMarkBudgetAsReviewedUseCase mockMarkReviewed;

  setUp(() {
    mockUpdate = MockUpdateBudgetUseCase();
    mockDelete = MockDeleteBudgetUseCase();
    mockMarkReviewed = MockMarkBudgetAsReviewedUseCase();
  });

  Widget createWidgetUnderTest(Budget budget) {
    return ProviderScope(
      overrides: [
        updateBudgetUseCaseProvider.overrideWithValue(mockUpdate),
        deleteBudgetUseCaseProvider.overrideWithValue(mockDelete),
        markBudgetAsReviewedUseCaseProvider.overrideWithValue(mockMarkReviewed),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: EditBudgetScreen(budget: budget),
      ),
    );
  }

  testWidgets('renders stability badge if budget is stable',
      (WidgetTester tester) async {
    final budget = Budget(
        id: 1, category: 'Food', monthlyLimit: 500, spent: 200, isStable: true);

    await tester.pumpWidget(createWidgetUnderTest(budget));
    await tester.pumpAndSettle();

    expect(find.text('STABLE'), findsOneWidget);
  });

  testWidgets('clicking mark as reviewed calls use case',
      (WidgetTester tester) async {
    final budget =
        Budget(id: 1, category: 'Food', monthlyLimit: 500, spent: 200);

    when(() => mockMarkReviewed.call(any()))
        .thenAnswer((_) async => const Success(null));

    await tester.pumpWidget(createWidgetUnderTest(budget));
    await tester.pumpAndSettle();

    final button = find.text('MARK AS REVIEWED');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();

    verify(() => mockMarkReviewed.call(1)).called(1);
    // Screen should have popped
    expect(find.byType(EditBudgetScreen), findsNothing);
  });
}
