import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/daily_closure_card.dart';
import 'package:trueledger/core/theme/theme.dart';

void main() {
  final semantic = AppTheme.darkColors;

  group('DailyClosureCard Widget Tests', () {
    testWidgets('renders when forceShow is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DailyClosureCard(
            transactionCount: 3,
            todaySpend: 500,
            dailyBudget: 1000,
            semantic: semantic,
            forceShow: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("DAY CLOSURE"), findsOneWidget);
      expect(find.text("Day closed ✓"), findsOneWidget);
      expect(find.text("You logged 3 expenses today."), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DailyClosureCard(
            transactionCount: 0,
            todaySpend: 0,
            dailyBudget: 1000,
            semantic: semantic,
            forceShow: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("DAY CLOSURE"), findsOneWidget);
      expect(find.text("No expenses today."), findsOneWidget);
      expect(find.text("That's okay. See you tomorrow."), findsOneWidget);
    });
  });
}
