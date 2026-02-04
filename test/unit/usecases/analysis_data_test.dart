import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/usecases/get_analysis_data_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetAnalysisDataUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetAnalysisDataUseCase(mockRepository);
  });

  final tBudgets = [
    Budget(id: 1, category: 'Food', monthlyLimit: 1000, isStable: true),
  ];
  final tTrendData = [
    {'month': '2024-01', 'total': 500}
  ];
  final tCategoryData = [
    {'category': 'Food', 'total': 300}
  ];

  test('should get analysis data from repository', () async {
    // arrange
    when(() => mockRepository.getBudgets()).thenAnswer((_) async => tBudgets);
    when(() => mockRepository.getSpendingTrend())
        .thenAnswer((_) async => tTrendData);
    when(() => mockRepository.getCategorySpending())
        .thenAnswer((_) async => tCategoryData);

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result.isSuccess, true);
    final data = result.getOrThrow;
    expect(data.budgets, tBudgets);
    expect(data.trendData, tTrendData);
    expect(data.categoryData, tCategoryData);
    verify(() => mockRepository.getBudgets()).called(1);
    verify(() => mockRepository.getSpendingTrend()).called(1);
    verify(() => mockRepository.getCategorySpending()).called(1);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getBudgets()).thenThrow(Exception('DB Error'));

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result.isFailure, true);
    verify(() => mockRepository.getBudgets()).called(1);
  });
}
