import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/trend_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.getString(any())).thenReturn('USD');
  });

  Widget createWidgetUnderTest({
    required List<Map<String, dynamic>> trendData,
    bool isPrivate = false,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: TrendChart(
              trendData: trendData,
              semantic: AppTheme.darkColors,
              isPrivate: isPrivate,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders nothing when data is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(trendData: []));
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('renders LineChart with data', (WidgetTester tester) async {
    final trendData = [
      {'month': '2023-01', 'total': 1000.0},
      {'month': '2023-02', 'total': 1200.0},
      {'month': '2023-03', 'total': 1100.0},
    ];

    await tester.pumpWidget(createWidgetUnderTest(trendData: trendData));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('JAN'), findsOneWidget);
    expect(find.text('FEB'), findsOneWidget);
    expect(find.text('MAR'), findsOneWidget);
    expect(find.text('FCST'), findsOneWidget);
  });
}
