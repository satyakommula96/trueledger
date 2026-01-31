import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late AddTransactionUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = AddTransactionUseCase(mockRepository);

    when(() => mockRepository.getBudgets()).thenAnswer((_) async => []);

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
      // Optional: Check if result data is correct structure
      expect((result as Success<AddTransactionResult>).value,
          isA<AddTransactionResult>());

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
    test('should return budgetWarning when limit is reached', () async {
      // Arrange
      final budget =
          Budget(id: 1, category: 'Food', monthlyLimit: 1000, spent: 900);
      when(() => mockRepository.getBudgets()).thenAnswer((_) async => [budget]);
      when(() => mockRepository.addEntry(any(), any(), any(), any(), any()))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(validParams);

      // Assert
      final data = (result as Success<AddTransactionResult>).value;
      expect(data.budgetWarning, isNotNull);
      expect(data.budgetWarning!.type, NotificationType.budgetWarning);
      expect(data.budgetWarning!.category, 'Food');
    });
  });
}
