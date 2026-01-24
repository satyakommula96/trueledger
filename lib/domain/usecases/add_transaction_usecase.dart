import 'package:truecash/core/error/failure.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

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

  AddTransactionUseCase(this.repository);

  @override
  Future<Result<void>> call(AddTransactionParams params) async {
    // 1. Validation Logic (Blocking Issue #1)
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
      return const Success(null);
    } catch (e) {
      // 3. Error Mapping (Blocking Issue #2)
      return Failure(
          DatabaseFailure("Failed to add transaction: ${e.toString()}"));
    }
  }
}
