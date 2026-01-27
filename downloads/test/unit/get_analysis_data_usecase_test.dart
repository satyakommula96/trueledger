import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/get_analysis_data_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetAnalysisDataUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetAnalysisDataUseCase(mockRepository);
  });

  group('GetAnalysisDataUseCase', () {
    test('should return AnalysisData when all repository calls are successful',
        () async {
      // Arrange
      final budgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 100, spent: 50)
      ];
      final trendData = [
        {'month': '2026-01', 'total': 100}
      ];
      final categoryData = [
        {'category': 'Food', 'total': 50}
      ];

      when(() => mockRepository.getBudgets()).thenAnswer((_) async => budgets);
      when(() => mockRepository.getSpendingTrend())
          .thenAnswer((_) async => trendData);
      when(() => mockRepository.getCategorySpending())
          .thenAnswer((_) async => categoryData);

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;
      expect(data.budgets, budgets);
      expect(data.trendData, trendData);
      expect(data.categoryData, categoryData);
    });

    test('should return Failure when any repository call fails', () async {
      // Arrange
      when(() => mockRepository.getBudgets()).thenThrow(Exception('DB Error'));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<DatabaseFailure>());
    });
  });
}
