import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetMonthlySummaryUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetMonthlySummaryUseCase(mockRepository);
  });

  group('GetMonthlySummaryUseCase', () {
    test('should return MonthlySummary when repository call is successful',
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
      when(() => mockRepository.getMonthlySummary())
          .thenAnswer((_) async => summary);

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, summary);
    });

    test('should return Failure when repository call fails', () async {
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
