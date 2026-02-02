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

class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockAddTransactionUseCase mockUseCase;
  late MockNotificationService mockNotificationService;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockUseCase = MockAddTransactionUseCase();
    mockNotificationService = MockNotificationService();
    mockRepository = MockFinancialRepository();

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
            ]);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(mockUseCase),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        financialRepositoryProvider.overrideWithValue(mockRepository),
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
  });
}
