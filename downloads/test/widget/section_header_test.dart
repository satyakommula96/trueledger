import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/section_header.dart';
import 'package:trueledger/core/theme/theme.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('SectionHeader', () {
    testWidgets('renders title and subtitle correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        SectionHeader(
          title: 'Financial Overview',
          sub: 'Assets vs Liabilities',
          semantic: AppTheme.darkColors,
        ),
      ));

      expect(find.text('Financial Overview'), findsOneWidget);
      expect(find.text('ASSETS VS LIABILITIES'), findsOneWidget);
    });

    testWidgets('onAdd callback is called when add button is tapped',
        (tester) async {
      bool addTapped = false;
      await tester.pumpWidget(createTestWidget(
        SectionHeader(
          title: 'Test Section',
          sub: 'Subtitle',
          semantic: AppTheme.darkColors,
          onAdd: () => addTapped = true,
        ),
      ));

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(addTapped, isTrue);
    });
  });
}
