import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/health_meter.dart';

void main() {
  late AppColors semantic;

  setUp(() {
    semantic = AppTheme.darkColors;
  });

  Widget createWidgetUnderTest({
    required int score,
  }) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: HealthMeter(
          score: score,
          semantic: semantic,
        ),
      ),
    );
  }

  testWidgets('renders EXCELLENT for score >= 80', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(score: 85));

    // Wait for animations
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('85'), findsOneWidget);
    expect(find.text('EXCELLENT'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('renders GOOD for score >= 60', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(score: 65));

    // Wait for animations
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('65'), findsOneWidget);
    expect(find.text('GOOD'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
  });

  testWidgets('renders AVERAGE for score >= 40', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(score: 45));

    // Wait for animations
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('45'), findsOneWidget);
    expect(find.text('AVERAGE'), findsOneWidget);
    expect(find.byIcon(Icons.info_rounded), findsOneWidget);
  });

  testWidgets('renders AT RISK for score < 40', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(score: 25));

    // Wait for animations
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('25'), findsOneWidget);
    expect(find.text('AT RISK'), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
  });
}
