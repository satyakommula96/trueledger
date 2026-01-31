import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockFinancialRepository mockRepository;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockNotificationService = MockNotificationService();

    // Default mock behavior
    registerFallbackValue(0);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: const MaterialApp(
        home: AddCreditCardScreen(),
      ),
    );
  }

  group('AddCreditCardScreen', () {
    testWidgets('should add credit card successfully', (tester) async {
      when(() => mockRepository.addCreditCard(
              any(), any(), any(), any(), any(), any()))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter data using precise predicate finders
      await tester.enterText(
          find.byWidgetPredicate(
              (w) => w is TextField && w.decoration?.labelText == 'Bank Name'),
          'Test Bank');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.labelText == 'Credit Limit'),
          '100000');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.labelText == 'Statement Balance'),
          '5000');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.labelText == 'Minimum Due'),
          '500');

      await tester.pumpAndSettle();

      // Debugging: Verify text was entered
      final bankField = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Bank Name');
      expect((tester.widget(bankField) as TextField).controller?.text,
          'Test Bank');

      final limitField = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Credit Limit');
      expect(
          (tester.widget(limitField) as TextField).controller?.text, '100000');

      await tester.ensureVisible(find.text('ADD CARD'));
      await tester.tap(find.text('ADD CARD'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 500)); // Wait for snackbar

      verify(() => mockRepository.addCreditCard(
            'Test Bank',
            100000,
            5000,
            500,
            any(),
            any(),
          )).called(1);
    });

    testWidgets('should show error if balance exceeds limit', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.byWidgetPredicate(
              (w) => w is TextField && w.decoration?.labelText == 'Bank Name'),
          'Test Bank');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.labelText == 'Credit Limit'),
          '5000');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.labelText == 'Statement Balance'),
          '10000');

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('ADD CARD'));
      await tester.tap(find.text('ADD CARD'));
      await tester.pumpAndSettle();

      expect(find.text('Statement balance cannot exceed credit limit'),
          findsOneWidget);
      verifyNever(() => mockRepository.addCreditCard(
          any(), any(), any(), any(), any(), any()));
    });

    testWidgets('should show date pickers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap on Statement Date
      await tester.tap(find.byType(TextField).at(4));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Close date picker - try both 'Cancel' and 'CANCEL' if needed, or by type
      final cancelFinder = find.text('Cancel');
      if (cancelFinder.evaluate().isEmpty) {
        await tester.tap(find.text('CANCEL'));
      } else {
        await tester.tap(cancelFinder);
      }
      await tester.pumpAndSettle();

      // Tap on Payment Due Date
      await tester.ensureVisible(find.byType(TextField).at(5));
      await tester.tap(find.byType(TextField).at(5));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
