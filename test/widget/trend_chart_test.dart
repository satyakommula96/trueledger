import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/trend_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trueledger/domain/models/models.dart';
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
    required List<FinancialTrend> trendData,
    bool isPrivate = false,
  }) {
    return wrapWidget(
      Scaffold(
        body: Center(
          child: TrendChart(
            trendData: trendData,
            semantic: AppTheme.darkColors,
            isPrivate: isPrivate,
          ),
        ),
      ),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  }

  testWidgets('renders nothing when data is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(trendData: []));
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('renders LineChart with data', (WidgetTester tester) async {
    final trendData = [
      FinancialTrend(month: '2023-01', spending: 1000, income: 0, total: 1000),
      FinancialTrend(month: '2023-02', spending: 1200, income: 0, total: 1200),
      FinancialTrend(month: '2023-03', spending: 1100, income: 0, total: 1100),
    ];

    await tester.pumpWidget(createWidgetUnderTest(trendData: trendData));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('JAN'), findsOneWidget);
    expect(find.text('FEB'), findsOneWidget);
    expect(find.text('MAR'), findsOneWidget);
  });
}
