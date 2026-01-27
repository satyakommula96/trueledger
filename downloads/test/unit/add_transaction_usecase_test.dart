import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late AddTransactionUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = AddTransactionUseCase(mockRepository);

    // Register fallback for Mocktail any()
    registerFallbackValue('Variable');
    registerFallbackValue(100);
  });

  group('AddTransactionUseCase', () {
    final validParams = AddTransactionParams(
      type: 'Variable',
      amount: 100,
      category: 'Food',
      note: 'Dinner',
      date: '2026-01-23',
    );

    test('should return Success when repository call is successful', () async {
      // Arrange
      when(() => mockRepository.addEntry(any(), any(), any(), any(), any()))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(validParams);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.addEntry(
            validParams.type,
            validParams.amount,
            validParams.category,
            validParams.note,
            validParams.date,
          )).called(1);
    });

    test('should return Failure when amount is <= 0', () async {
      // Arrange
      final params = AddTransactionParams(
        type: 'Variable',
        amount: 0,
        category: 'Food',
        note: 'Dinner',
        date: '2026-01-23',
      );

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<ValidationFailure>());
      verifyNever(
          () => mockRepository.addEntry(any(), any(), any(), any(), any()));
    });

    test('should return Failure when category is empty', () async {
      // Arrange
      final params = AddTransactionParams(
        type: 'Variable',
        amount: 100,
        category: '',
        note: 'Dinner',
        date: '2026-01-23',
      );

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<ValidationFailure>());
    });

    test('should return Failure when database error occurs', () async {
      // Arrange
      when(() => mockRepository.addEntry(any(), any(), any(), any(), any()))
          .thenThrow(Exception('DB Error'));

      // Act
      final result = await useCase.call(validParams);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<DatabaseFailure>());
    });
  });
}
