import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/loans/edit_loan.dart';
import 'package:trueledger/core/constants/widget_keys.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    // Default mocks
    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => []);
    when(() => mockRepo.updateLoan(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        )).thenAnswer((_) async {});
    when(() => mockRepo.addEntry(
          any(),
          any(),
          any(),
          any(),
          any(),
          paymentMethod: any(named: 'paymentMethod'),
          tags: any(named: 'tags'),
        )).thenAnswer((_) async {});
    when(() => mockRepo.recordLoanAudit(
          loanId: any(named: 'loanId'),
          date: any(named: 'date'),
          openingBalance: any(named: 'openingBalance'),
          interestRate: any(named: 'interestRate'),
          paymentAmount: any(named: 'paymentAmount'),
          daysAccrued: any(named: 'daysAccrued'),
          interestAccrued: any(named: 'interestAccrued'),
          principalApplied: any(named: 'principalApplied'),
          closingBalance: any(named: 'closingBalance'),
          engineVersion: any(named: 'engineVersion'),
          type: any(named: 'type'),
        )).thenAnswer((_) async {});
    when(() => mockRepo.deleteItem(any(), any())).thenAnswer((_) async {});
  });

  Widget createSubject(Loan loan) {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: EditLoanScreen(loan: loan),
      ),
    );
  }

  final testLoan = Loan(
    id: 1,
    name: 'Home Loan',
    totalAmount: 500000,
    remainingAmount: 450000,
    emi: 25000,
    interestRate: 8.5,
    loanType: 'Bank',
    dueDate: '2026-02-15T00:00:00.000',
  );

  testWidgets('EditLoanScreen renders correctly with loan data',
      (tester) async {
    await tester.pumpWidget(createSubject(testLoan));
    await tester.pumpAndSettle();

    expect(find.text('UPDATE LOAN'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Home Loan'), findsOneWidget);
  });

  testWidgets('Delete loan follows confirmation flow', (tester) async {
    await tester.pumpWidget(createSubject(testLoan));
    await tester.pumpAndSettle();

    // 1. Find and tap delete button
    final deleteBtn = find.byKey(WidgetKeys.deleteButton);
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // 2. Verify confirmation dialog appeared
    expect(find.text('DELETE LOAN?'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('DELETE'), findsOneWidget);

    // 3. Verify no deletion happened yet
    verifyNever(() => mockRepo.deleteItem('loans', 1));

    // 4. Tap CANCEL and verify no deletion
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('DELETE LOAN?'), findsNothing);
    verifyNever(() => mockRepo.deleteItem('loans', 1));

    // 5. Open dialog again and tap DELETE
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();

    // 6. Verify deletion occurred
    verify(() => mockRepo.deleteItem('loans', 1)).called(1);
  });
}
