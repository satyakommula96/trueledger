import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/upcoming_bills.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool('is_private_mode')).thenReturn(false);
    when(() => mockPrefs.getString('currency')).thenReturn('USD');
    CurrencyFormatter.currencyNotifier.value = 'USD';
  });

  Widget createWidgetUnderTest({
    required List<Map<String, dynamic>> bills,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: UpcomingBills(
            bills: bills,
            semantic: AppTheme.darkColors,
          ),
        ),
      ),
    );
  }

  testWidgets('renders empty state', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(bills: []));
    expect(find.text('All bills are clear'), findsOneWidget);
  });

  testWidgets('renders bills', (WidgetTester tester) async {
    final bills = [
      {
        'type': 'Credit Card',
        'title': 'HDFC VISA',
        'amount': 1500,
        'due': DateTime.now().add(const Duration(days: 2)).toIso8601String()
      },
      {
        'type': 'Loan',
        'title': 'Home Loan',
        'amount': 2500,
        'due': DateTime.now().add(const Duration(days: 5)).toIso8601String()
      },
    ];

    await tester.pumpWidget(createWidgetUnderTest(bills: bills));
    await tester.pumpAndSettle();

    expect(find.text('CREDIT CARD'), findsOneWidget);
    expect(find.text('HDFC VISA'), findsOneWidget);
    expect(find.textContaining('1.5K'), findsNothing); // Compact not used
    expect(find.textContaining('\$1,500'), findsOneWidget);

    expect(find.text('LOAN'), findsOneWidget);
    expect(find.text('Home Loan'), findsOneWidget);
    expect(find.textContaining('2.5K'), findsNothing); // Compact not used
    expect(find.textContaining('\$2,500'), findsOneWidget);
  });
}
