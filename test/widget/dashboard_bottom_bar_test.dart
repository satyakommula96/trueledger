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
    testWidgets('renders LOANS label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('LOANS'), findsOneWidget);
    });

    testWidgets('renders CARDS label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('CARDS'), findsOneWidget);
    });

    testWidgets('renders ANALYSIS label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('ANALYSIS'), findsOneWidget);
    });

    testWidgets('renders HISTORY label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('HISTORY'), findsOneWidget);
    });

    testWidgets('renders all navigation icons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Scaffold(
          bottomNavigationBar: DashboardBottomBar(onLoad: () {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
      expect(find.byIcon(Icons.credit_card_outlined), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    });
  });
}
