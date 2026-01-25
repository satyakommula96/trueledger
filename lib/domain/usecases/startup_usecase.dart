import 'package:truecash/core/error/failure.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/data/datasources/database.dart';
import 'package:truecash/core/utils/currency_formatter.dart';
import 'package:truecash/core/services/notification_service.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class StartupUseCase extends UseCase<void, NoParams> {
  final IFinancialRepository repository;

  StartupUseCase(this.repository);

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      // 1. Initialize Database (including migrations)
      await AppDatabase.db;

      // 2. Initialize Notifications
      await NotificationService().init();

      // 3. Load Currency Preference
      await CurrencyFormatter.load();

      // 4. Check for recurring transactions
      await repository.checkAndProcessRecurring();

      return const Success(null);
    } catch (e) {
      if (e is AppFailure) return Failure(e);
      return Failure(
          UnexpectedFailure("Critical startup failure: ${e.toString()}"));
    }
  }
}
