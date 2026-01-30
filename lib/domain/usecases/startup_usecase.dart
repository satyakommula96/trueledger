import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class StartupUseCase extends UseCase<void, NoParams> {
  final IFinancialRepository repository;
  final NotificationService notificationService;

  StartupUseCase(this.repository, this.notificationService);

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      // 1. Initialize Database (including migrations)
      await AppDatabase.db;

      // 2. Initialize Notifications
      await notificationService.init();
      final granted = await notificationService.requestPermissions();
      if (granted) {
        await notificationService.scheduleDailyReminder();
      }

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
