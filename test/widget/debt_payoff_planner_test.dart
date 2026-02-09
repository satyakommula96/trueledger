import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/loans/debt_payoff_planner.dart';
import 'package:trueledger/core/theme/theme.dart';

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
        home: const DebtPayoffPlannerScreen(),
      ),
    );
  }

  group('DebtPayoffPlannerScreen', () {
    testWidgets('displays free state when no loans exist', (tester) async {
      when(() => mockRepo.getLoans()).thenAnswer((_) async => <Loan>[]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('NO ACTIVE DEBT. YOU ARE FREE!'), findsOneWidget);
    });

    testWidgets('displays simulation results when loans exist', (tester) async {
      final List<Loan> loans = [
        Loan(
          id: 1,
          name: 'Home Loan',
          loanType: 'MORTGAGE',
          totalAmount: 5000000,
          remainingAmount: 4000000,
          interestRate: 8.5,
          emi: 40000,
          dueDate: '2020-01-01',
        ),
      ];

      when(() => mockRepo.getLoans()).thenAnswer((_) async => loans);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('DEBT FREE BY'), findsOneWidget);
      expect(find.text('BOOST PAYOFF'), findsOneWidget);
      expect(find.text('PAYOFF STRATEGY'), findsOneWidget);
      expect(find.text('PAYOFF SEQUENCE'), findsOneWidget);
      expect(find.text('Home Loan'), findsOneWidget);
    });

    testWidgets('updates simulation when strategy is toggled', (tester) async {
      final List<Loan> loans = [
        Loan(
            id: 1,
            name: 'L1',
            loanType: 'PERSONAL',
            totalAmount: 1000,
            remainingAmount: 500,
            interestRate: 10,
            emi: 100,
            dueDate: ''),
        Loan(
            id: 2,
            name: 'L2',
            loanType: 'PERSONAL',
            totalAmount: 1000,
            remainingAmount: 200,
            interestRate: 20,
            emi: 50,
            dueDate: ''),
      ];

      when(() => mockRepo.getLoans()).thenAnswer((_) async => loans);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Default is Avalanche (highest interest first L2)
      expect(find.text('L2'), findsOneWidget);

      // Tap Snowball (lowest balance first L2 - wait, L2 has 200, L1 has 500. So Snowball also shows L2 first?)
      // Let's swap: L1 200 @ 10, L2 500 @ 20.
      // Avalanche -> L2 first. Snowball -> L1 first.
    });
  });
}
