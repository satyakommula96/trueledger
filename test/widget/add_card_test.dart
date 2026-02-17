import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import '../helpers/test_wrapper.dart';

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
    return wrapWidget(
      const AddCreditCardScreen(),
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
  }

  group('AddCreditCardScreen', () {
    testWidgets('should add credit card successfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepository.addCreditCard(
              any(), any(), any(), any(), any(), any(), any()))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter data using index as labelText is now a separate Text widget
      await tester.enterText(find.byType(TextField).at(0), 'Test Bank');
      await tester.enterText(find.byType(TextField).at(1), '100000');
      await tester.enterText(find.byType(TextField).at(2), '5000');
      await tester.enterText(find.byType(TextField).at(3), '5000');
      await tester.enterText(find.byType(TextField).at(4), '500');

      await tester.pumpAndSettle();

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
            5000,
          )).called(1);
    });

    testWidgets('should show error if current balance exceeds limit',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test Bank');
      await tester.enterText(find.byType(TextField).at(1), '5000');
      await tester.enterText(find.byType(TextField).at(2), '0');
      await tester.enterText(find.byType(TextField).at(3), '10000');

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('ADD CARD'));
      await tester.tap(find.text('ADD CARD'));
      await tester.pumpAndSettle();

      expect(find.text('Current balance cannot exceed credit limit'),
          findsOneWidget);
      verifyNever(() => mockRepository.addCreditCard(
          any(), any(), any(), any(), any(), any(), any()));
    });

    testWidgets('should show date pickers', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap on Statement Date
      await tester.tap(find.byType(TextField).at(5));
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
      await tester.ensureVisible(find.byType(TextField).at(6));
      await tester.tap(find.byType(TextField).at(6));
      await tester.pumpAndSettle();
      expect(find.text('SELECT DUE DAY'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
