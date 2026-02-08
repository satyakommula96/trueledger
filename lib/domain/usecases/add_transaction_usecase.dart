import 'package:flutter/foundation.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/services/personalization_service.dart';
import 'usecase_base.dart';

class AddTransactionParams {
  final String type;
  final double amount;
  final String category;
  final String note;
  final String date;

  final String? merchant;
  final String? paymentMethod;

  AddTransactionParams({
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    this.merchant,
    this.paymentMethod,
  });
}

enum NotificationType { budgetWarning, budgetExceeded }

class NotificationIntent {
  final NotificationType type;
  final String category;
  final double percentage;

  NotificationIntent({
    required this.type,
    required this.category,
    required this.percentage,
  });
}

class AddTransactionResult {
  final bool cancelDailyReminder;
  final NotificationIntent? budgetWarning;

  AddTransactionResult({
    this.cancelDailyReminder = false,
    this.budgetWarning,
  });
}

class AddTransactionUseCase
    extends UseCase<AddTransactionResult, AddTransactionParams> {
  final IFinancialRepository repository;
  final PersonalizationService? personalizationService;

  AddTransactionUseCase(this.repository, [this.personalizationService]);

  @override
  Future<Result<AddTransactionResult>> call(AddTransactionParams params) async {
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

      // 2b. Personalization logic
      await personalizationService?.recordUsage(
        category: params.category,
        paymentMethod: params.paymentMethod,
        merchant: params.merchant,
        amount: params.amount,
        note: params.note,
      );

      bool shouldCancelDaily = false;
      NotificationIntent? budgetWarning;

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
          final spent = categoryBudget.spent;
          final limit = categoryBudget.monthlyLimit;
          final percent = (spent / limit) * 100;

          if (percent >= 100) {
            budgetWarning = NotificationIntent(
              type: NotificationType.budgetExceeded,
              category: params.category,
              percentage: percent,
            );
          } else if (percent >= 85) {
            budgetWarning = NotificationIntent(
              type: NotificationType.budgetWarning,
              category: params.category,
              percentage: percent,
            );
          }
        }
      } catch (e, stack) {
        debugPrint(
            "Error in secondary transaction logic (notifications/budget): $e");
        if (kDebugMode) {
          debugPrint(stack.toString());
          throw Exception("Secondary transaction logic failed: $e\n$stack");
        }
      }

      return Success(AddTransactionResult(
        cancelDailyReminder: shouldCancelDaily,
        budgetWarning: budgetWarning,
      ));
    } catch (e) {
      // 4. Error Mapping
      return Failure(
          DatabaseFailure("Failed to add transaction: ${e.toString()}"));
    }
  }
}
