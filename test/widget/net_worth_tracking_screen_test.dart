import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_tracking_screen.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/core/constants/widget_keys.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import '../helpers/currency_test_helpers.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();

    // Default mock for SharedPreferences
    when(() => mockPrefs.getBool(any())).thenReturn(false);

    // Standardize currency for tests
    CurrencyFormatter.currencyNotifier.value = '₹';
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const NetWorthTrackingScreen(),
      ),
    );
  }

  void setupEmptyData() {
    when(() => mockRepo.getAllValues('investments'))
        .thenAnswer((_) async => []);
    when(() => mockRepo.getAllValues('retirement_contributions'))
        .thenAnswer((_) async => []);
    when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
    when(() => mockRepo.getLoans()).thenAnswer((_) async => []);
  }

  group('NetWorthTrackingScreen', () {
    testWidgets('displays loading indicator initially',
        (WidgetTester tester) async {
      setupEmptyData();

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays list sections correctly using keys',
        (WidgetTester tester) async {
      setupEmptyData();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify structural presence via keys instead of text
      expect(find.byKey(WidgetKeys.dashboardNetWorthValue), findsOneWidget);
      expect(find.byKey(WidgetKeys.dashboardAssetsButton), findsOneWidget);
      expect(find.byKey(WidgetKeys.analysisTrendChart), findsOneWidget);
    });

    testWidgets('calculates and displays negative net worth correctly',
        (WidgetTester tester) async {
      // Assets: 100k + 50k + 200k = 350k
      // Liabilities: 10k + 500k = 510k
      // Net Worth: 350k - 510k = -160k

      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Stock A', 'amount': 100000, 'active': 1},
          {'id': 2, 'name': 'Stock B', 'amount': 50000, 'active': 1},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions')).thenAnswer(
        (_) async => [
          {'id': 1, 'type': 'EPF', 'amount': 200000},
        ],
      );
      when(() => mockRepo.getCreditCards()).thenAnswer(
        (_) async => [
          CreditCard(
            id: 1,
            bank: 'HDFC',
            creditLimit: 100000,
            statementBalance: 10000,
            currentBalance: 10000,
            minDue: 1000,
            dueDate: '15-03-2024',
            statementDate: 'Day 1',
          ),
        ],
      );
      when(() => mockRepo.getLoans()).thenAnswer(
        (_) async => [
          Loan(
            id: 1,
            name: 'Home Loan',
            loanType: 'Home',
            totalAmount: 1000000,
            remainingAmount: 500000,
            emi: 25000,
            interestRate: 8.5,
            dueDate: '5th',
            date: DateTime.now().toIso8601String(),
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Robust assertion: check the specific widget by key and look for formatted value
      final netWorthFinder = find.byKey(WidgetKeys.dashboardNetWorthValue);
      expect(netWorthFinder, findsOneWidget);

      // Use helper to verify formatted amount
      expect(findFormattedAmount(-160000), findsOneWidget);
    });

    testWidgets('calculates and displays positive net worth correctly',
        (WidgetTester tester) async {
      // Net Worth: 800k - 150k = 650k
      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Stock A', 'amount': 500000, 'active': 1},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions')).thenAnswer(
        (_) async => [
          {'id': 1, 'type': 'EPF', 'amount': 300000},
        ],
      );
      when(() => mockRepo.getCreditCards()).thenAnswer(
        (_) async => [
          CreditCard(
            id: 1,
            bank: 'HDFC',
            creditLimit: 200000,
            statementBalance: 50000,
            currentBalance: 50000,
            minDue: 5000,
            dueDate: '15-03-2024',
            statementDate: 'Day 1',
          ),
        ],
      );
      when(() => mockRepo.getLoans()).thenAnswer(
        (_) async => [
          Loan(
            id: 1,
            name: 'Personal Loan',
            loanType: 'Bank',
            totalAmount: 200000,
            remainingAmount: 100000,
            emi: 10000,
            interestRate: 12.0,
            dueDate: '10th',
            date: DateTime.now().toIso8601String(),
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(findFormattedAmount(650000), findsOneWidget);
    });

    testWidgets('navigates to assets details when assets card is tapped',
        (WidgetTester tester) async {
      setupEmptyData();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Use key for navigation trigger instead of vulnerable text
      await tester.tap(find.byKey(WidgetKeys.dashboardAssetsButton));
      await tester.pumpAndSettle();

      expect(find.byType(NetWorthDetailsScreen), findsOneWidget);
    });

    testWidgets('excludes inactive investments from calculations',
        (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Active Stock', 'amount': 100000, 'active': 1},
          {'id': 2, 'name': 'Inactive Stock', 'amount': 50000, 'active': 0},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Sum should only be 100,000 (compact formatting might apply in some cases,
      // but here we check the full formatted version)
      expect(findFormattedAmount(100000), findsAtLeastNWidgets(1));
    });
  });
}
