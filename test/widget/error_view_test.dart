import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/presentation/components/error_view.dart';

void main() {
  group('AppErrorView', () {
    testWidgets('should display error message and title', (tester) async {
      const errorMessage = 'Something went wrong';
      const customTitle = 'Custom Error Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: errorMessage,
              title: customTitle,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('should display default title if none provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
    });

    testWidgets('should call onRetry when button is pressed', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: 'Error',
              onRetry: () {
                retryCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });
  });
}
