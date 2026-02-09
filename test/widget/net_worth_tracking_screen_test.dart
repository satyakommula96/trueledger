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

  group('NetWorthTrackingScreen', () {
    testWidgets('displays loading indicator initially',
        (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays net worth tracking screen with data',
        (WidgetTester tester) async {
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

      expect(find.text('NET WORTH TRACKING'), findsOneWidget);
      expect(find.text('NET WORTH'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('ASSETS'), findsOneWidget);
      expect(find.text('LIABILITIES'), findsOneWidget);
    });

    testWidgets('calculates net worth correctly', (WidgetTester tester) async {
      // Assets: 100k + 50k + 200k = 350k
      // Liabilities: 10k + 500k = 510k
      // Net Worth: 350k - 510k = -160k (negative)

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

      // Net worth should be negative. Formatter produces ₹-1,60,000 for -160000
      expect(find.textContaining('₹-'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays positive net worth correctly',
        (WidgetTester tester) async {
      // Assets: 500k + 300k = 800k
      // Liabilities: 50k + 100k = 150k
      // Net Worth: 800k - 150k = 650k (positive)

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

      expect(find.text('NET WORTH'), findsOneWidget);
      // Should show positive amount
      expect(find.textContaining('₹6'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles empty data gracefully', (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('NET WORTH TRACKING'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      // Net worth should be 0
      expect(find.text('₹0'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays trend chart section', (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Stock A', 'amount': 100000, 'active': 1},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('TREND'), findsOneWidget);
      expect(find.text('12-MONTH OVERVIEW'), findsOneWidget);
    });

    testWidgets('displays insight card with growth information',
        (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Stock A', 'amount': 100000, 'active': 1},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('INSIGHT'), findsOneWidget);
      // Should show some growth message. We check for the RichText content
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('navigates to assets details when assets card is tapped',
        (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Stock A', 'amount': 100000, 'active': 1},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the ASSETS text/card
      await tester.tap(find.text('ASSETS'));
      await tester.pumpAndSettle();

      // Should navigate to NetWorthDetailsScreen
      expect(find.text('ASSETS BREAKUP'), findsOneWidget);
    });

    testWidgets(
        'navigates to liabilities details when liabilities card is tapped',
        (WidgetTester tester) async {
      when(() => mockRepo.getAllValues('investments')).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Stock A', 'amount': 100000, 'active': 1},
        ],
      );
      when(() => mockRepo.getAllValues('retirement_contributions'))
          .thenAnswer((_) async => []);
      when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);
      when(() => mockRepo.getLoans()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the LIABILITIES text/card
      await tester.tap(find.text('LIABILITIES'));
      await tester.pumpAndSettle();

      // Should navigate to NetWorthDetailsScreen
      expect(find.text('LIABILITIES BREAKUP'), findsOneWidget);
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

      // Assets should only include active investments (100k)
      // The inactive 50k should not be counted
      expect(find.text('₹1,00,000'), findsAtLeastNWidgets(1));
    });
  });
}
