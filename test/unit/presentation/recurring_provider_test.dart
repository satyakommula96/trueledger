import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/recurring_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  group('RecurringNotifier', () {
    late MockFinancialRepository mockRepository;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockRepository = MockFinancialRepository();
      mockNotificationService = MockNotificationService();
    });

    test('build fetches recurring transactions', () async {
      final transactions = [
        RecurringTransaction(
          id: 1,
          name: 'Netflix',
          amount: 15.0,
          category: 'Entertainment',
          type: 'SUBSCRIPTION',
          frequency: 'MONTHLY',
          dayOfMonth: 15,
        ),
      ];

      when(() => mockRepository.getRecurringTransactions())
          .thenAnswer((_) async => transactions);

      final container = ProviderContainer(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
      );

      final result = await container.read(recurringProvider.future);

      expect(result, transactions);
      verify(() => mockRepository.getRecurringTransactions()).called(1);
    });

    test('add creates transaction and schedules notification', () async {
      when(() => mockRepository.addRecurringTransaction(
            name: any(named: 'name'),
            amount: any(named: 'amount'),
            category: any(named: 'category'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
            dayOfMonth: any(named: 'dayOfMonth'),
            dayOfWeek: any(named: 'dayOfWeek'),
          )).thenAnswer((_) async {});

      when(() => mockNotificationService.scheduleRecurringReminder(
            any(),
            any(),
            any(),
            dayOfMonth: any(named: 'dayOfMonth'),
            dayOfWeek: any(named: 'dayOfWeek'),
          )).thenAnswer((_) async {});

      when(() => mockRepository.getRecurringTransactions())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
      );

      final notifier = container.read(recurringProvider.notifier);
      await notifier.add(
        name: 'Netflix',
        amount: 15.0,
        category: 'Entertainment',
        type: 'SUBSCRIPTION',
        frequency: 'MONTHLY',
        dayOfMonth: 15,
      );

      verify(() => mockRepository.addRecurringTransaction(
            name: 'Netflix',
            amount: 15.0,
            category: 'Entertainment',
            type: 'SUBSCRIPTION',
            frequency: 'MONTHLY',
            dayOfMonth: 15,
          )).called(1);

      verify(() => mockNotificationService.scheduleRecurringReminder(
            'Netflix',
            'MONTHLY',
            15.0,
            dayOfMonth: 15,
          )).called(1);

      verify(() => mockRepository.getRecurringTransactions()).called(2);
    });

    test('updateTransaction updates transaction and reschedules notification',
        () async {
      when(() => mockRepository.updateRecurringTransaction(
            id: any(named: 'id'),
            name: any(named: 'name'),
            amount: any(named: 'amount'),
            category: any(named: 'category'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
            dayOfMonth: any(named: 'dayOfMonth'),
            dayOfWeek: any(named: 'dayOfWeek'),
          )).thenAnswer((_) async {});

      when(() => mockNotificationService.scheduleRecurringReminder(
            any(),
            any(),
            any(),
            dayOfMonth: any(named: 'dayOfMonth'),
            dayOfWeek: any(named: 'dayOfWeek'),
          )).thenAnswer((_) async {});

      when(() => mockRepository.getRecurringTransactions())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
      );

      final notifier = container.read(recurringProvider.notifier);
      await notifier.updateTransaction(
        id: 1,
        name: 'Netflix Premium',
        amount: 20.0,
        category: 'Entertainment',
        type: 'SUBSCRIPTION',
        frequency: 'MONTHLY',
        dayOfMonth: 15,
      );

      verify(() => mockRepository.updateRecurringTransaction(
            id: 1,
            name: 'Netflix Premium',
            amount: 20.0,
            category: 'Entertainment',
            type: 'SUBSCRIPTION',
            frequency: 'MONTHLY',
            dayOfMonth: 15,
          )).called(1);

      verify(() => mockNotificationService.scheduleRecurringReminder(
            'Netflix Premium',
            'MONTHLY',
            20.0,
            dayOfMonth: 15,
          )).called(1);

      verify(() => mockRepository.getRecurringTransactions()).called(2);
    });

    test('delete removes transaction', () async {
      when(() => mockRepository.deleteItem(any(), any()))
          .thenAnswer((_) async {});

      when(() => mockRepository.getRecurringTransactions())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
      );

      final notifier = container.read(recurringProvider.notifier);
      await notifier.delete(1);

      verify(() => mockRepository.deleteItem('recurring_transactions', 1))
          .called(1);
      verify(() => mockRepository.getRecurringTransactions()).called(2);
    });
  });
}
