import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/cards/credit_cards.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepository;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepository),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const CreditCardsScreen(),
      ),
    );
  }

  group('CreditCardsScreen', () {
    testWidgets('should show loading then list of cards', (tester) async {
      final cards = [
        CreditCard(
          id: 1,
          bank: 'HDFC',
          creditLimit: 100000,
          statementBalance: 5000,
          currentBalance: 3000,
          minDue: 500,
          dueDate: '20-10-2024',
          statementDate: 'Day 1',
        ),
      ];

      when(() => mockRepository.getCreditCards())
          .thenAnswer((_) async => cards);

      await tester.pumpWidget(createWidgetUnderTest());

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('HDFC'), findsOneWidget);
      // Current balance utilization
      expect(find.text('3.0% UTILIZED'), findsOneWidget);
      expect(find.text('RECORD PAYMENT'), findsOneWidget);
    });

    testWidgets('should show empty state if no cards', (tester) async {
      when(() => mockRepository.getCreditCards()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('NO CARDS REGISTERED'), findsOneWidget);
    });

    testWidgets('should open pay dialog when Record Payment is pressed',
        (tester) async {
      final card = CreditCard(
        id: 1,
        bank: 'HDFC',
        creditLimit: 100000,
        statementBalance: 5000,
        currentBalance: 3000,
        minDue: 500,
        dueDate: '20-10-2024',
      );

      when(() => mockRepository.getCreditCards())
          .thenAnswer((_) async => [card]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Scroll to make the button visible
      await tester.dragUntilVisible(
        find.text('RECORD PAYMENT'),
        find.byType(ListView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('RECORD PAYMENT'));
      await tester.pumpAndSettle();

      // Dialog Title
      expect(find.text('RECORD PAYMENT'), findsWidgets);
      // Bank Name in Dialog
      expect(find.text('HDFC'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
    });

    testWidgets('should not show Record Payment for paid cards',
        (tester) async {
      final card = CreditCard(
        id: 1,
        bank: 'HDFC',
        creditLimit: 100000,
        statementBalance: 0, // Paid off
        currentBalance: 2000, // Still has current balance
        minDue: 0,
        dueDate: '20-10-2024',
      );

      when(() => mockRepository.getCreditCards())
          .thenAnswer((_) async => [card]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show current balance
      expect(find.text('CURRENT BALANCE'), findsOneWidget);
      expect(find.text('2.0% UTILIZED'), findsOneWidget);

      // Should NOT show DUE badge
      expect(find.text('DUE'), findsNothing);

      // Should NOT show Record Payment button
      expect(find.text('RECORD PAYMENT'), findsNothing);
    });
  });
}
