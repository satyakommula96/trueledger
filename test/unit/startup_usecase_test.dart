import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockAutoBackupUseCase extends Mock implements AutoBackupUseCase {}

void main() {
  late StartupUseCase useCase;
  late MockFinancialRepository mockRepository;
  late MockAutoBackupUseCase mockAutoBackupUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockAutoBackupUseCase = MockAutoBackupUseCase();
    useCase = StartupUseCase(mockRepository, mockAutoBackupUseCase);

    when(() => mockRepository.getTodaySpend()).thenAnswer((_) async => 0);
    when(() => mockRepository.checkAndProcessRecurring())
        .thenAnswer((_) async {});
    when(() => mockAutoBackupUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));
  });

  group('StartupUseCase', () {
    test('should return Failure when checkAndProcessRecurring throws',
        () async {
      // Arrange - Mock the repository method that the use case calls
      when(() => mockRepository.checkAndProcessRecurring())
          .thenThrow(Exception('Recurring check failed'));

      // Act
      final result = await useCase.call(NoParams());

      // Assert - Should fail because of the exception
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<UnexpectedFailure>());
    });
  });
}
