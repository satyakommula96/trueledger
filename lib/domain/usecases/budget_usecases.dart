import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class AddBudgetParams {
  final String category;
  final int monthlyLimit;

  AddBudgetParams({required this.category, required this.monthlyLimit});
}

class AddBudgetUseCase extends UseCase<void, AddBudgetParams> {
  final IFinancialRepository repository;

  AddBudgetUseCase(this.repository);

  @override
  Future<Result<void>> call(AddBudgetParams params) async {
    if (params.monthlyLimit < 0) {
      return Failure(ValidationFailure("Budget limit cannot be negative"));
    }
    if (params.category.isEmpty) {
      return Failure(ValidationFailure("Category cannot be empty"));
    }

    try {
      await repository.addBudget(params.category, params.monthlyLimit);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure("Failed to add budget: ${e.toString()}"));
    }
  }
}

class UpdateBudgetParams {
  final int id;
  final int monthlyLimit;

  UpdateBudgetParams({required this.id, required this.monthlyLimit});
}

class UpdateBudgetUseCase extends UseCase<void, UpdateBudgetParams> {
  final IFinancialRepository repository;

  UpdateBudgetUseCase(this.repository);

  @override
  Future<Result<void>> call(UpdateBudgetParams params) async {
    if (params.monthlyLimit < 0) {
      return Failure(ValidationFailure("Budget limit cannot be negative"));
    }

    try {
      await repository.updateBudget(params.id, params.monthlyLimit);
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to update budget: ${e.toString()}"));
    }
  }
}

class DeleteBudgetUseCase extends UseCase<void, int> {
  final IFinancialRepository repository;

  DeleteBudgetUseCase(this.repository);

  @override
  Future<Result<void>> call(int id) async {
    try {
      await repository.deleteItem('budgets', id);
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to delete budget: ${e.toString()}"));
    }
  }
}
