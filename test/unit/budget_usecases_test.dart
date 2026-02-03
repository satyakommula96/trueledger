import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/budget_usecases.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
  });

  group('UpdateBudgetUseCase', () {
    late UpdateBudgetUseCase useCase;

    setUp(() {
      useCase = UpdateBudgetUseCase(mockRepository);
    });

    test('should return Success when repository call is successful', () async {
      when(() => mockRepository.updateBudget(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepository.markBudgetAsReviewed(any()))
          .thenAnswer((_) async {});

      final result =
          await useCase.call(UpdateBudgetParams(id: 1, monthlyLimit: 500));

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.updateBudget(1, 500)).called(1);
      verify(() => mockRepository.markBudgetAsReviewed(1)).called(1);
    });

    test('should return Failure when limit is negative', () async {
      final result =
          await useCase.call(UpdateBudgetParams(id: 1, monthlyLimit: -1));

      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<ValidationFailure>());
    });
  });

  group('DeleteBudgetUseCase', () {
    late DeleteBudgetUseCase useCase;

    setUp(() {
      useCase = DeleteBudgetUseCase(mockRepository);
    });

    test('should return Success when repository call is successful', () async {
      when(() => mockRepository.deleteItem(any(), any()))
          .thenAnswer((_) async {});

      final result = await useCase.call(1);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.deleteItem('budgets', 1)).called(1);
    });
  });

  group('MarkBudgetAsReviewedUseCase', () {
    late MarkBudgetAsReviewedUseCase useCase;

    setUp(() {
      useCase = MarkBudgetAsReviewedUseCase(mockRepository);
    });

    test('should return Success when repository call is successful', () async {
      when(() => mockRepository.markBudgetAsReviewed(any()))
          .thenAnswer((_) async {});

      final result = await useCase.call(1);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.markBudgetAsReviewed(1)).called(1);
    });

    test('should return Failure when repository call fails', () async {
      when(() => mockRepository.markBudgetAsReviewed(any()))
          .thenThrow(Exception("DB Error"));

      final result = await useCase.call(1);

      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow.message, contains("DB Error"));
    });
  });
}
