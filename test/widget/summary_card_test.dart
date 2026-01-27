import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/summary_card.dart';
import 'package:trueledger/core/theme/theme.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('SummaryCard', () {
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        SummaryCard(
          label: 'Income',
          value: '₹50,000',
          valueColor: Colors.green,
          semantic: AppTheme.darkColors,
          icon: Icons.payments_rounded,
        ),
      ));

      // Wait for animations to complete
      await tester.pump(const Duration(seconds: 2));

      // Check that the label is rendered (uppercase)
      expect(find.textContaining('INCOME'), findsWidgets);
    });

    testWidgets('renders value correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        SummaryCard(
          label: 'Income',
          value: '₹50,000',
          valueColor: Colors.green,
          semantic: AppTheme.darkColors,
          icon: Icons.payments_rounded,
        ),
      ));

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('₹50,000'), findsOneWidget);
    });

    testWidgets('renders icon correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        SummaryCard(
          label: 'Income',
          value: '₹50,000',
          valueColor: Colors.green,
          semantic: AppTheme.darkColors,
          icon: Icons.payments_rounded,
        ),
      ));

      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(Icons.payments_rounded), findsOneWidget);
    });
  });
}
