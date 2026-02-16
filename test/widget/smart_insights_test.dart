import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/smart_insights.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import '../helpers/test_wrapper.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn('USD');
  });

  Widget createWidgetUnderTest({
    required List<AIInsight> insights,
    required int score,
  }) {
    return wrapWidget(
      Scaffold(
        body: SmartInsightsCard(
          insights: insights,
          score: score,
          semantic: AppTheme.darkColors,
        ),
      ),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  }

  testWidgets('renders score card even when insights are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(insights: [], score: 85));
    await tester.pumpAndSettle();
    expect(find.text('INTELLIGENT INSIGHTS'), findsOneWidget);
    expect(find.text('EXCELLENT'), findsOneWidget);
  });

  testWidgets('renders insights and score card', (WidgetTester tester) async {
    final insights = [
      AIInsight(
        id: '1',
        title: 'WEALTH PROJECTION',
        body: 'Your wealth will double in 10 years.',
        value: 'Forecast',
        type: InsightType.prediction,
        priority: InsightPriority.high,
        currencyValue: 1000000,
        group: InsightGroup.behavioral,
      ),
      AIInsight(
        id: '2',
        title: 'SAVINGS POTENTIAL',
        body: 'You can save more by reducing dining out.',
        value: 'Advice',
        type: InsightType.info,
        priority: InsightPriority.medium,
        group: InsightGroup.trend,
      ),
    ];

    await tester
        .pumpWidget(createWidgetUnderTest(insights: insights, score: 85));
    await tester.pumpAndSettle();

    expect(find.text('INTELLIGENT INSIGHTS'), findsOneWidget);
    expect(find.text('EXCELLENT'), findsOneWidget); // Score Card
    expect(find.text('WEALTH PROJECTION'), findsOneWidget);
    expect(find.text('SAVINGS POTENTIAL'), findsOneWidget);
  });
}
