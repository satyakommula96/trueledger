import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/dashboard_bottom_bar.dart';
import 'package:trueledger/core/theme/theme.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('DashboardBottomBar', () {
    testWidgets('renders Accounts label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Accounts'), findsOneWidget);
    });

    testWidgets('renders Cards label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Cards'), findsOneWidget);
    });

    testWidgets('renders Analysis label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Analysis'), findsOneWidget);
    });

    testWidgets('renders More label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('renders all 4 main navigation icons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);
      expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
      expect(find.byIcon(Icons.auto_graph_rounded), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    });
  });
}
