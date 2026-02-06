import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/transactions/monthly_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockRepo.getAvailableYears())
        .thenAnswer((_) async => [2023, 2024]);
    when(() => mockRepo.getMonthlyHistory(any())).thenAnswer((_) async => []);
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const MonthlyHistoryScreen(),
      ),
    );
  }

  testWidgets('MonthlyHistoryScreen renders year selector and empty state',
      (tester) async {
    when(() => mockRepo.getMonthlyHistory(2023)).thenAnswer((_) async => []);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('LEDGER HISTORY'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('NO PERIODS TRACKED.'), findsOneWidget);
  });

  testWidgets('MonthlyHistoryScreen renders history list', (tester) async {
    final List<Map<String, dynamic>> summaries = [
      {
        'month': '2023-01',
        'income': 5000,
        'expenses': 3000,
        'invested': 1000,
        'net': 2000,
      },
      {
        'month': '2023-02',
        'income': 4000,
        'expenses': 4500,
        'invested': 500,
        'net': -500,
      }
    ];

    when(() => mockRepo.getMonthlyHistory(2023))
        .thenAnswer((_) async => summaries);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('JANUARY 2023'), findsOneWidget);
    expect(find.text('SURPLUS PERIOD'), findsOneWidget);
    expect(find.text('FEBRUARY 2023'), findsOneWidget);
    expect(find.text('DEFICIT PERIOD'), findsOneWidget);
  });

  testWidgets('MonthlyHistoryScreen selects year and reloads', (tester) async {
    when(() => mockRepo.getMonthlyHistory(2023)).thenAnswer((_) async => []);
    when(() => mockRepo.getMonthlyHistory(2024)).thenAnswer((_) async => [
          {
            'month': '2024-01',
            'income': 6000,
            'expenses': 3000,
            'invested': 1000,
            'net': 3000,
          }
        ]);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Default selection is 2023 (first in mock list or logic dependent, let's verify)
    // The code sets selectedYear = years.first if not contained. Mock returns [2023, 2024].
    // If current year is not in list, it picks first.

    final year2024 = find.text('2024');
    await tester.tap(year2024);
    await tester.pumpAndSettle();

    verify(() => mockRepo.getMonthlyHistory(2024)).called(1);
    expect(find.text('JANUARY 2024'), findsOneWidget);
  });
}
