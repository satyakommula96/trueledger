import 'package:truecash/core/error/failure.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

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
