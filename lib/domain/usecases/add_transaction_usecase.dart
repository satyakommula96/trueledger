import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';
import 'package:flutter/foundation.dart';

class AddTransactionParams {
  final String type;
  final int amount;
  final String category;
  final String note;
  final String date;

  AddTransactionParams({
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });
}

class NotificationRequest {
  final int id;
  final String title;
  final String body;

  NotificationRequest({
    required this.id,
    required this.title,
    required this.body,
  });
}

class TransactionResult {
  final bool cancelDailyReminder;
  final List<NotificationRequest> notifications;

  TransactionResult({
    this.cancelDailyReminder = false,
    this.notifications = const [],
  });
}

class AddTransactionUseCase
    extends UseCase<TransactionResult, AddTransactionParams> {
  final IFinancialRepository repository;

  AddTransactionUseCase(this.repository);

  @override
  Future<Result<TransactionResult>> call(AddTransactionParams params) async {
    // 1. Validation Logic
    if (params.amount <= 0) {
      return Failure(ValidationFailure("Amount must be greater than zero"));
    }
    if (params.category.isEmpty) {
      return Failure(ValidationFailure("Category cannot be empty"));
    }
    if (params.date.isEmpty) {
      return Failure(ValidationFailure("Date must be provided"));
    }

    try {
      // 2. Repository Delegation
      await repository.addEntry(
        params.type,
        params.amount,
        params.category,
        params.note,
        params.date,
      );

      bool shouldCancelDaily = false;
      final List<NotificationRequest> notificationEvents = [];

      // 3. Smart Notifications Logic (Pure Domain Logic)
      try {
        final entryDate = DateTime.parse(params.date);
        final now = DateTime.now();

        // 3a. Check if Daily Reminder should be cancelled
        if (entryDate.year == now.year &&
            entryDate.month == now.month &&
            entryDate.day == now.day) {
          shouldCancelDaily = true;
        }

        // 3b. Budget Proximity Warning
        final budgets = await repository.getBudgets();
        final categoryBudget = budgets.cast<Budget?>().firstWhere(
              (b) => b?.category == params.category,
              orElse: () => null,
            );

        if (categoryBudget != null) {
          final spent = categoryBudget
              .spent; // Note: Repository should have returned updated spent amount if possible, or we assume it's close enough.
          // Ideally, addEntry should return the new state, or we fetch it.
          // Since we just added an entry, the 'spent' in `getBudgets` relies on the DB state.
          // If `addEntry` is awaited, `getBudgets` should reflect the new total.

          final limit = categoryBudget.monthlyLimit;
          final percent = (spent / limit) * 100;

          if (percent >= 100) {
            notificationEvents.add(NotificationRequest(
              id: params.category.hashCode,
              title: 'Budget Exceeded: ${params.category}',
              body: 'You have spent 100% of your ${params.category} budget.',
            ));
          } else if (percent >= 85) {
            notificationEvents.add(NotificationRequest(
              id: params.category.hashCode,
              title: 'Budget Warning: ${params.category}',
              body:
                  'You have reached ${percent.round()}% of your ${params.category} budget.',
            ));
          }
        }
      } catch (e) {
        // Log the error but do not fail the transaction.
        // In a real app, send to Crashlytics.
        debugPrint("Error calculating notification events: $e");
      }

      return Success(TransactionResult(
        cancelDailyReminder: shouldCancelDaily,
        notifications: notificationEvents,
      ));
    } catch (e) {
      // 4. Error Mapping
      return Failure(
          DatabaseFailure("Failed to add transaction: ${e.toString()}"));
    }
  }
}
