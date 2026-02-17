import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/usecases/get_analysis_data_usecase.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/screens/analysis/analysis_screen.dart';
import '../../../helpers/test_wrapper.dart';

import 'dart:async';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
  });

  // Helper to override the provider
  Widget createSubject({
    required FutureOr<AnalysisData> Function(Ref) override,
  }) {
    return wrapWidget(
      const AnalysisScreen(),
      overrides: [
        analysisProvider.overrideWith(override),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  }

  testWidgets('AnalysisScreen renders loading', (tester) async {
    final completer = Completer<AnalysisData>();
    await tester.pumpWidget(createSubject(
      override: (ref) => completer.future,
    ));
    // Pump a single frame to show loading
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AnalysisScreen renders empty content', (tester) async {
    final emptyData = AnalysisData(
      budgets: [],
      trendData: [],
      categoryData: [],
    );

    await tester.pumpWidget(createSubject(
      override: (ref) => emptyData,
    ));
    await tester.pumpAndSettle();

    expect(find.text('ANALYSIS'), findsOneWidget);
    expect(find.text('ARCHIVE'), findsOneWidget);
    expect(find.text('MOMENTUM'), findsNothing);
    expect(find.text('NO DATA AVAILABLE'), findsOneWidget);
  });

  testWidgets('AnalysisScreen renders data', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockData = AnalysisData(
      budgets: [
        Budget(
            id: 1,
            category: 'Food',
            monthlyLimit: 500,
            spent: 100,
            lastReviewedAt: DateTime.now())
      ],
      trendData: [
        FinancialTrend(
            total: 100, month: '2023-01', income: 150, spending: 100),
        FinancialTrend(
            total: 200, month: '2023-02', income: 250, spending: 200),
      ],
      categoryData: [CategorySpending(category: 'Food', total: 100)],
    );

    await tester.pumpWidget(createSubject(
      override: (ref) => mockData,
    ));
    // Multiple pumps to finish animations
    for (int i = 0; i < 5; i++) {
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    expect(find.text('ANALYSIS'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    expect(find.text('MOMENTUM'), findsOneWidget);
  });
}
