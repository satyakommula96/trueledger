import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/quick_add_bottom_sheet.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/services/personalization_service.dart';

class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockPersonalizationService extends Mock
    implements PersonalizationService {}

void main() {
  late MockAddTransactionUseCase mockUseCase;
  late MockNotificationService mockNotificationService;
  late MockFinancialRepository mockRepository;
  late MockPersonalizationService mockPersonalizationService;

  setUp(() {
    mockUseCase = MockAddTransactionUseCase();
    mockNotificationService = MockNotificationService();
    mockRepository = MockFinancialRepository();
    mockPersonalizationService = MockPersonalizationService();

    registerFallbackValue(AddTransactionParams(
      type: 'Variable',
      amount: 0,
      category: '',
      note: '',
      date: '',
    ));

    // Mock category fetching
    when(() => mockRepository.getCategories('Variable'))
        .thenAnswer((_) async => [
              TransactionCategory(id: 1, name: 'Food', type: 'Variable'),
              TransactionCategory(id: 2, name: 'General', type: 'Variable'),
              TransactionCategory(id: 3, name: 'Transport', type: 'Variable'),
            ]);

    // Mock PersonalizationService
    when(() => mockPersonalizationService.getLastUsed())
        .thenReturn({'category': 'Food', 'paymentMethod': 'Cash'});
    when(() => mockPersonalizationService.getSettings())
        .thenReturn(PersonalizationSettings());
    when(() => mockPersonalizationService.getPresets()).thenReturn([]);
    when(() => mockPersonalizationService.getSuggestedCategoryForTime(any()))
        .thenReturn(null);
    when(() => mockPersonalizationService.findShortcutSuggestion())
        .thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(mockUseCase),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        financialRepositoryProvider.overrideWithValue(mockRepository),
        personalizationServiceProvider
            .overrideWithValue(mockPersonalizationService),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: QuickAddBottomSheet(),
        ),
      ),
    );
  }

  group('QuickAddBottomSheet', () {
    testWidgets('should add transaction successfully and cancel daily reminder',
        (tester) async {
      when(() => mockUseCase.call(any())).thenAnswer((_) async => Success(
            AddTransactionResult(
              cancelDailyReminder: true,
            ),
          ));

      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter amount
      await tester.enterText(find.byType(TextField).first, '100');

      // Select category (Food)
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('SAVE EXPENSE'));
      await tester.pumpAndSettle();

      verify(() => mockUseCase.call(any())).called(1);
      verify(() => mockNotificationService
          .cancelNotification(NotificationService.dailyReminderId)).called(1);
    });

    testWidgets('should show budget warning if returned from use case',
        (tester) async {
      when(() => mockUseCase.call(any())).thenAnswer((_) async => Success(
            AddTransactionResult(
              cancelDailyReminder: false,
              budgetWarning: NotificationIntent(
                category: 'Food',
                percentage: 90,
                type: NotificationType.budgetWarning,
              ),
            ),
          ));

      when(() => mockNotificationService.showNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, '100');
      await tester.tap(find.text('SAVE EXPENSE'));
      await tester.pumpAndSettle();

      verify(() => mockNotificationService.showNotification(
            id: any(named: 'id'),
            title: any(named: 'title', that: contains('Budget Warning: Food')),
            body: any(named: 'body', that: contains('reached 90%')),
          )).called(1);
    });

    testWidgets('should show budget exceeded if returned from use case',
        (tester) async {
      when(() => mockUseCase.call(any())).thenAnswer((_) async => Success(
            AddTransactionResult(
              cancelDailyReminder: false,
              budgetWarning: NotificationIntent(
                category: 'Food',
                percentage: 100,
                type: NotificationType.budgetExceeded,
              ),
            ),
          ));

      when(() => mockNotificationService.showNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, '100');
      await tester.tap(find.text('SAVE EXPENSE'));
      await tester.pumpAndSettle();

      verify(() => mockNotificationService.showNotification(
            id: any(named: 'id'),
            title: any(named: 'title', that: contains('Budget Exceeded: Food')),
            body: any(named: 'body', that: contains('spent 100%')),
          )).called(1);
    });

    testWidgets('should show error message if use case fails', (tester) async {
      when(() => mockUseCase.call(any()))
          .thenAnswer((_) async => Failure(DatabaseFailure('Test Error')));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, '100');
      await tester.tap(find.text('SAVE EXPENSE'));
      await tester.pumpAndSettle();

      expect(find.text('Test Error'), findsOneWidget);
    });

    testWidgets('should show validation error if amount is invalid',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).first, '0');
      await tester.tap(find.text('SAVE EXPENSE'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid amount'), findsOneWidget);
      verifyNever(() => mockUseCase.call(any()));
    });

    testWidgets('should pre-fill category based on last-used', (tester) async {
      when(() => mockPersonalizationService.getLastUsed()).thenReturn({
        'category': 'Transport',
        'paymentMethod': 'Credit Card',
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Transport'), findsWidgets);
      expect(find.textContaining('Suggested: Transport & Credit Card'),
          findsOneWidget);
    });

    testWidgets('should show and use presets', (tester) async {
      when(() => mockPersonalizationService.getPresets()).thenReturn([
        QuickAddPreset(id: '1', title: 'Lunch', amount: 300, category: 'Food'),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Lunch · ₹300'), findsOneWidget);
      await tester.tap(find.text('Lunch · ₹300'));
      await tester
          .pumpAndSettle(const Duration(seconds: 1)); // Wait for animation

      expect(_amountController(tester).text, '300.0');
    });
  });
}

TextEditingController _amountController(WidgetTester tester) {
  return (tester.widget(find.byType(TextField).first) as TextField).controller!;
}
