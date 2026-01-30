import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/services/notification_service.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late StartupUseCase useCase;
  late MockFinancialRepository mockRepository;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockNotificationService = MockNotificationService();
    useCase = StartupUseCase(mockRepository, mockNotificationService);

    // Stub notifications
    when(() => mockNotificationService.init()).thenAnswer((_) async {});
    when(() => mockNotificationService.requestPermissions())
        .thenAnswer((_) async => true);
    when(() => mockNotificationService.scheduleDailyReminder())
        .thenAnswer((_) async {});
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
