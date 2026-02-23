import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/asset_liability_card.dart';
import 'package:trueledger/domain/models/monthly_summary.dart';
import 'package:trueledger/core/theme/theme.dart';
import '../helpers/test_wrapper.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool('is_private_mode')).thenReturn(false);
  });

  Widget createTestWidget(Widget child) {
    return wrapWidget(
      Scaffold(body: Center(child: child)),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  }

  group('AssetLiabilityCard', () {
    testWidgets('renders ASSETS label', (tester) async {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 20000,
        totalVariable: 30000,
        totalSubscriptions: 5000,
        totalInvestments: 10000,
        netWorth: 500000,
        creditCardDebt: 25000,
        loansTotal: 200000,
        totalMonthlyEMI: 15000,
      );

      await tester.pumpWidget(createTestWidget(
        AssetLiabilityCard(
          summary: summary,
          semantic: AppTheme.darkColors,
          onLoad: () {},
        ),
      ));

      // Wait for animations
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('ASSETS'), findsOneWidget);
    });

    testWidgets('renders LIABILITIES label', (tester) async {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 20000,
        totalVariable: 30000,
        totalSubscriptions: 5000,
        totalInvestments: 10000,
        netWorth: 500000,
        creditCardDebt: 25000,
        loansTotal: 200000,
        totalMonthlyEMI: 15000,
      );

      await tester.pumpWidget(createTestWidget(
        AssetLiabilityCard(
          summary: summary,
          semantic: AppTheme.darkColors,
          onLoad: () {},
        ),
      ));

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('LIABILITIES'), findsOneWidget);
    });

    testWidgets('renders icons', (tester) async {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      await tester.pumpWidget(createTestWidget(
        AssetLiabilityCard(
          summary: summary,
          semantic: AppTheme.darkColors,
          onLoad: () {},
        ),
      ));

      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.doc_text_fill), findsOneWidget);
    });
  });
}
