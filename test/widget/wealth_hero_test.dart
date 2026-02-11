import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/wealth_hero.dart';
import 'package:trueledger/domain/models/monthly_summary.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool('is_private_mode')).thenReturn(false);
    when(() => mockPrefs.getString('currency')).thenReturn('USD');
    // Important: Reset the global state for tests
    CurrencyFormatter.currencyNotifier.value = 'USD';
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('WealthHero', () {
    testWidgets('renders CURRENT BALANCE label', (tester) async {
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
        WealthHero(summary: summary, activeStreak: 0, hasLoggedToday: false),
      ));

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('CURRENT BALANCE'), findsOneWidget);
    });

    testWidgets('renders net worth amount', (tester) async {
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
        WealthHero(summary: summary, activeStreak: 0, hasLoggedToday: false),
      ));

      await tester.pump(const Duration(seconds: 2));

      // 500,000 should be formatted. Let's just check if 500,000 is there.
      expect(find.textContaining('500,000'), findsOneWidget);
    });
  });
}
