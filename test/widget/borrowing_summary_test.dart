import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/borrowing_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late AppColors semantic;
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    semantic = AppTheme.darkColors;
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    when(() => mockRepo.getLoans()).thenAnswer((_) async => []);
    when(() => mockPrefs.getBool('is_private_mode')).thenReturn(false);
    when(() => mockPrefs.getString('currency'))
        .thenReturn('USD'); // Use USD for predictable formatting
    CurrencyFormatter.currencyNotifier.value = 'USD';
  });

  Widget createWidgetUnderTest({
    required MonthlySummary summary,
    required VoidCallback onLoad,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: BorrowingSummary(
            summary: summary,
            semantic: semantic,
            onLoad: onLoad,
          ),
        ),
      ),
    );
  }

  testWidgets('renders correctly with content', (WidgetTester tester) async {
    final summary = MonthlySummary(
      totalIncome: 5000,
      totalFixed: 1000,
      totalVariable: 1000,
      totalSubscriptions: 500,
      totalInvestments: 500,
      loansTotal: 15000,
    );

    await tester.pumpWidget(createWidgetUnderTest(
      summary: summary,
      onLoad: () {},
    ));

    // Wait for animations to finish
    await tester.pumpAndSettle();

    expect(find.text('BORROWINGS'), findsOneWidget);
    // With USD and compact=true, 15000 should be "$15K"
    expect(find.textContaining('15'), findsOneWidget);
  });

  testWidgets('navigates to loans screen and calls onLoad on return',
      (WidgetTester tester) async {
    final summary = MonthlySummary(
      totalIncome: 5000,
      totalFixed: 1000,
      totalVariable: 1000,
      totalSubscriptions: 500,
      totalInvestments: 500,
      loansTotal: 1000,
    );

    int onLoadCallCount = 0;

    await tester.pumpWidget(createWidgetUnderTest(
      summary: summary,
      onLoad: () => onLoadCallCount++,
    ));

    await tester.pumpAndSettle();

    // Tap on the card
    await tester.tap(find.text('BORROWINGS'));
    await tester.pumpAndSettle();

    // Check if we are on Loans screen
    expect(find.text('BORROWINGS & LOANS'), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(onLoadCallCount, 1);
  });
}
