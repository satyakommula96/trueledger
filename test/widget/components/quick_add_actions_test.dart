import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/quick_add_actions.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final semantic = AppTheme.darkColors;

  Widget createWidget(QuickAddActions widget) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: widget),
      ),
    );
  }

  group('QuickAddActions Widget Tests', () {
    testWidgets('renders all 4 action buttons', (tester) async {
      await tester.pumpWidget(createWidget(QuickAddActions(
        semantic: semantic,
        onActionComplete: () {},
      )));

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Asset'), findsOneWidget);
      expect(find.text('Liability'), findsOneWidget);
    });

    testWidgets('Income button navigates to AddExpense', (tester) async {
      await tester.pumpWidget(createWidget(QuickAddActions(
        semantic: semantic,
        onActionComplete: () {},
      )));

      await tester.tap(find.text('Income'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AddExpense), findsOneWidget);
    });

    testWidgets('Liability button shows bottom sheet', (tester) async {
      await tester.pumpWidget(createWidget(QuickAddActions(
        semantic: semantic,
        onActionComplete: () {},
      )));

      await tester.tap(find.text('Liability'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ADD LIABILITY'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text('Bank/Personal Loan'), findsOneWidget);
    });
  });
}
