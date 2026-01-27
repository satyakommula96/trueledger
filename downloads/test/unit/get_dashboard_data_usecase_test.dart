import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetDashboardDataUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetDashboardDataUseCase(mockRepository);
  });

  group('GetDashboardDataUseCase', () {
    test('should return DashboardData when all repository calls succeed',
        () async {
      // Arrange
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 200,
        totalVariable: 300,
        totalSubscriptions: 50,
        totalInvestments: 100,
        netWorth: 5000,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );
      final categorySpending = [
        {'category': 'Food', 'total': 50}
      ];
      final budgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 100, spent: 50)
      ];
      final savingGoals = <SavingGoal>[];
      final trendData = [
        {'month': '2026-01', 'total': 100}
      ];
      final upcomingBills = [
        {'title': 'Netflix', 'amount': 200}
      ];

      when(() => mockRepository.getMonthlySummary())
          .thenAnswer((_) async => summary);
      when(() => mockRepository.getCategorySpending())
          .thenAnswer((_) async => categorySpending);
      when(() => mockRepository.getBudgets()).thenAnswer((_) async => budgets);
      when(() => mockRepository.getSavingGoals())
          .thenAnswer((_) async => savingGoals);
      when(() => mockRepository.getSpendingTrend())
          .thenAnswer((_) async => trendData);
      when(() => mockRepository.getUpcomingBills())
          .thenAnswer((_) async => upcomingBills);

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;
      expect(data.summary, summary);
      expect(data.budgets, budgets);
      expect(data.trendData, trendData);
    });

    test('should return Failure when any repository call fails', () async {
      // Arrange
      when(() => mockRepository.getMonthlySummary())
          .thenThrow(Exception('DB Error'));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<DatabaseFailure>());
    });
  });
}
