import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/loans/loans.dart';
import 'package:trueledger/presentation/screens/loans/add_loan.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockRepo = MockFinancialRepository();
    when(() => mockRepo.getLoans()).thenAnswer((_) async => []);
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const LoansScreen(),
      ),
    );
  }

  testWidgets('LoansScreen renders empty state', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('BORROWINGS & LOANS'), findsOneWidget);
    expect(find.text('NO ACTIVE BORROWINGS.'), findsOneWidget);
  });

  testWidgets('LoansScreen renders loans', (tester) async {
    final loan = Loan(
      id: 1,
      name: 'Car Loan',
      totalAmount: 20000,
      remainingAmount: 15000,
      emi: 500,
      interestRate: 5.0,
      loanType: 'Bank',
      dueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    );
    when(() => mockRepo.getLoans()).thenAnswer((_) async => [loan]);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('CAR LOAN'), findsOneWidget);
    expect(find.text('BANK'), findsOneWidget);
    expect(find.text('TOTAL BORROWINGS'), findsOneWidget);
    // Currency formatting might vary, checks existence of approximate value or formatted
    // Assuming formatter simple
    // Logic: 15000 remaining
    expect(find.textContaining('15,000'), findsWidgets);
  });

  testWidgets('LoansScreen FAB opens AddLoan', (tester) async {
    when(() => mockRepo.getAllValues(any()))
        .thenAnswer((_) async => []); // For AddLoan categories if needed

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AddLoanScreen), findsOneWidget);
  });
}
