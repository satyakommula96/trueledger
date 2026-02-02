import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/cards/credit_cards.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepository),
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
      expect(find.text('5.0% UTILIZED'), findsOneWidget);
      expect(find.text('RECORD PAYMENT'), findsOneWidget);
    });

    testWidgets('should show empty state if no cards', (tester) async {
      when(() => mockRepository.getCreditCards()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('NO CARDS REGISTERED.'), findsOneWidget);
    });

    testWidgets('should open pay dialog when Record Payment is pressed',
        (tester) async {
      final card = CreditCard(
        id: 1,
        bank: 'HDFC',
        creditLimit: 100000,
        statementBalance: 5000,
        minDue: 500,
        dueDate: '20-10-2024',
      );

      when(() => mockRepository.getCreditCards())
          .thenAnswer((_) async => [card]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('RECORD PAYMENT'));
      await tester.tap(find.text('RECORD PAYMENT'));
      await tester.pumpAndSettle();

      expect(find.text('Record Payment - HDFC'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
    });
  });
}
