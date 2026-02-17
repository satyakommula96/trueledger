import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import '../../helpers/test_wrapper.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    registerFallbackValue([]);
  });

  Widget createWidgetUnderTest() {
    return wrapWidget(
      const ManageCategoriesScreen(),
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  testWidgets('ManageCategoriesScreen renders categories and handles reorder',
      (tester) async {
    final categories = [
      TransactionCategory(id: 1, name: 'Food', type: 'Variable', orderIndex: 0),
      TransactionCategory(
          id: 2, name: 'Bills', type: 'Variable', orderIndex: 1),
    ];

    when(() => mockRepo.getCategories('Variable'))
        .thenAnswer((_) async => categories);
    when(() => mockRepo.reorderCategories(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('FOOD'), findsOneWidget);
    expect(find.text('BILLS'), findsOneWidget);

    // Verify drag handle exists
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(2));

    // Simulate reorder (dragging 'Food' below 'Bills')
    // We drag the first handle down past the second item
    await tester.drag(
        find.byIcon(Icons.drag_indicator_rounded).first, const Offset(0, 200));
    await tester.pumpAndSettle();

    verify(() => mockRepo.reorderCategories(any())).called(1);
  });
}
