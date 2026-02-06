import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/usecases/get_analysis_data_usecase.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/screens/analysis/analysis_screen.dart';
import 'package:trueledger/presentation/screens/budget/add_budget.dart';
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
    return ProviderScope(
      overrides: [
        analysisProvider.overrideWith(override),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AnalysisScreen(),
      ),
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
    expect(find.text('YEAR-IN-REVIEW'), findsOneWidget);
    expect(find.text('INSIGHT'), findsNothing);
    expect(find.text('No spending data yet'), findsOneWidget);
  });

  testWidgets('AnalysisScreen renders data', (tester) async {
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
        {'total': 100, 'month': '2023-01', 'income': 150, 'spending': 100},
        {'total': 200, 'month': '2023-02', 'income': 250, 'spending': 200},
      ],
      categoryData: [
        {'category': 'Food', 'total': 100}
      ],
    );

    await tester.pumpWidget(createSubject(
      override: (ref) => mockData,
    ));
    await tester.pumpAndSettle();

    expect(find.text('INSIGHT'), findsOneWidget);
    expect(find.textContaining('Spending is up by', findRichText: true),
        findsOneWidget);
    expect(find.text('MONTHLY TREND'), findsOneWidget);
    expect(find.text('DISTRIBUTION'), findsOneWidget);
    expect(find.text('BUDGETS'), findsOneWidget);
    expect(find.text('FOOD'), findsWidgets);
  });

  testWidgets('AnalysisScreen FAB opens AddBudget', (tester) async {
    final emptyData = AnalysisData(
      budgets: [],
      trendData: [],
      categoryData: [],
    );

    await tester.pumpWidget(createSubject(
      override: (ref) => emptyData,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AddBudgetScreen), findsOneWidget);
  });
}
