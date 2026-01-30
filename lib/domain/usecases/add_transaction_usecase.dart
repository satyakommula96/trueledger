import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/services/notification_service.dart';
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

class AddTransactionUseCase extends UseCase<void, AddTransactionParams> {
  final IFinancialRepository repository;
  final NotificationService notificationService;

  AddTransactionUseCase(this.repository, this.notificationService);

  @override
  Future<Result<void>> call(AddTransactionParams params) async {
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

      // 3. Smart Notifications
      try {
        final entryDate = DateTime.parse(params.date);
        final now = DateTime.now();

        // 3a. Cancel Daily Reminder if it's for today
        if (entryDate.year == now.year &&
            entryDate.month == now.month &&
            entryDate.day == now.day) {
          await notificationService
              .cancelNotification(NotificationService.dailyReminderId);
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
            await notificationService.showNotification(
              id: params.category.hashCode,
              title: 'Budget Exceeded: ${params.category}',
              body: 'You have spent 100% of your ${params.category} budget.',
            );
          } else if (percent >= 85) {
            await notificationService.showNotification(
              id: params.category.hashCode,
              title: 'Budget Warning: ${params.category}',
              body:
                  'You have reached ${percent.round()}% of your ${params.category} budget.',
            );
          }
        }
      } catch (e) {
        // Log but don't fail transaction if notification logic fails
        debugPrint("Smart notification logic failed: $e");
      }

      return const Success(null);
    } catch (e) {
      // 4. Error Mapping
      return Failure(
          DatabaseFailure("Failed to add transaction: ${e.toString()}"));
    }
  }
}
