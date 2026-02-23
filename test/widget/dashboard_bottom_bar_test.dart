import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/dashboard_bottom_bar.dart';
import '../helpers/test_wrapper.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return wrapWidget(child);
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

      expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.creditcard_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chart_pie_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.square_grid_2x2_fill), findsOneWidget);
    });
  });
}
