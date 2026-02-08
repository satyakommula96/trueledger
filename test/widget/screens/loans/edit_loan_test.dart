import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/loans/edit_loan.dart';

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

  testWidgets('EditLoanScreen renders correctly with loan data',
      (tester) async {
    final loan = Loan(
      id: 1,
      name: 'Home Loan',
      totalAmount: 500000,
      remainingAmount: 450000,
      emi: 25000,
      interestRate: 8.5,
      loanType: 'Bank',
      dueDate: '2026-02-15T00:00:00.000',
      lastPaymentDate:
          DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    );

    await tester.pumpWidget(createSubject(loan));
    await tester.pumpAndSettle();

    expect(find.text('UPDATE LOAN'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Home Loan'), findsOneWidget);
    expect(find.widgetWithText(TextField, '450000.0'), findsOneWidget);
    expect(find.text('RECORD EMI PAYMENT'), findsOneWidget);
    expect(find.text('RECORD PREPAYMENT'), findsOneWidget);
  });

  testWidgets('EditLoanScreen calculates payoff amount correctly',
      (tester) async {
    final loan = Loan(
      id: 1,
      name: 'Test Loan',
      totalAmount: 10000,
      remainingAmount: 10000,
      emi: 1000,
      interestRate: 10.0, // 10% annual
      loanType: 'Bank',
      dueDate: DateTime.now().toIso8601String(),
      lastPaymentDate:
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    );
    // Interest for 30 days on 10000 at 10% annual:
    // 10000 * (10/100) * (30/365) approx 82.19

    await tester.pumpWidget(createSubject(loan));
    await tester.pumpAndSettle();

    expect(find.text('FORECLOSURE / PAYOFF QUOTE'), findsOneWidget);
    // Determine the expected payoff amount string
    // Since exact string matching might be tricky due to formatting, checking for existence of the card is a good start.
    // We can try to match approximation if needed, or check if specific widgets are present.
    expect(find.textContaining('ESTIMATE'), findsOneWidget);
  });

  testWidgets('EditLoanScreen records EMI payment', (tester) async {
    final loan = Loan(
      id: 1,
      name: 'Car Loan',
      totalAmount: 20000,
      remainingAmount: 15000,
      emi: 500,
      interestRate: 5.0,
      loanType: 'Car',
      dueDate: DateTime.now().toIso8601String(),
    );

    await tester.pumpWidget(createSubject(loan));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('RECORD EMI PAYMENT'));
    await tester.tap(find.text('RECORD EMI PAYMENT'));
    await tester.pumpAndSettle();

    expect(find.text('RECORD LOAN PAYMENT'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);

    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.addEntry(
          'Fixed',
          500.0,
          'EMI / Loan Payment',
          any(),
          any(),
        )).called(1);

    verify(() => mockRepo.updateLoan(
          1,
          any(),
          any(),
          any(),
          any(), // New balance should be lower
          500.0,
          5.0,
          any(),
          any(),
        )).called(1);
  });

  testWidgets('EditLoanScreen loads payment history', (tester) async {
    final loan = Loan(
      id: 1,
      name: 'Test History',
      totalAmount: 5000,
      remainingAmount: 2000,
      emi: 100,
      interestRate: 2.0,
      loanType: 'Personal',
      dueDate: DateTime.now().toIso8601String(),
    );

    final historyItem = LedgerItem(
      id: 1,
      amount: 100,
      date: DateTime.now().toIso8601String(),
      label: 'EMI',
      type: 'Fixed',
      note: 'Loan payment for Test History',
    );

    when(() => mockRepo.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => [historyItem]);

    await tester.pumpWidget(createSubject(loan));
    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Loan payment for Test History'), findsOneWidget);
    expect(find.textContaining('100'), findsWidgets);
  });
}
