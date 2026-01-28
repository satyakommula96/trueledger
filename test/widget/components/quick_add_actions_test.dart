import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/quick_add_actions.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';

void main() {
  final semantic = AppTheme.darkColors;

  Widget createWidget(QuickAddActions widget) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: widget),
    );
  }

  group('QuickAddActions Widget Tests', () {
    testWidgets('renders all 4 action buttons', (tester) async {
      await tester.pumpWidget(createWidget(QuickAddActions(
        semantic: semantic,
        onActionComplete: () {},
      )));

      expect(find.text('INCOME'), findsOneWidget);
      expect(find.text('EXPENSE'), findsOneWidget);
      expect(find.text('ASSET'), findsOneWidget);
      expect(find.text('LIABILITY'), findsOneWidget);
    });

    testWidgets('Income button navigates to AddExpense', (tester) async {
      await tester.pumpWidget(createWidget(QuickAddActions(
        semantic: semantic,
        onActionComplete: () {},
      )));

      await tester.tap(find.text('INCOME'));
      await tester.pumpAndSettle();

      expect(find.byType(AddExpense), findsOneWidget);
    });

    testWidgets('Liability button shows bottom sheet', (tester) async {
      await tester.pumpWidget(createWidget(QuickAddActions(
        semantic: semantic,
        onActionComplete: () {},
      )));

      await tester.tap(find.text('LIABILITY'));
      await tester.pumpAndSettle();

      expect(find.text('ADD LIABILITY'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text('Bank/Personal Loan'), findsOneWidget);
    });
  });
}
