import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/get_annual_reflection_usecase.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetAnnualReflectionUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetAnnualReflectionUseCase(mockRepository);

    // Register fallback for DateTime if needed by mocktail
    registerFallbackValue(DateTime.now());
  });

  group('GetAnnualReflectionUseCase', () {
    const testYear = 2026;

    test('should return AnnualReflectionData with correct calculations',
        () async {
      // Arrange
      final List<Map<String, dynamic>> currentYearCats = [
        {'category': 'Food', 'total': 12000},
        {'category': 'Rent', 'total': 24000},
      ];
      final List<Map<String, dynamic>> previousYearCats = [
        {'category': 'Food', 'total': 10000},
        {'category': 'Rent', 'total': 24000},
        {'category': 'Travel', 'total': 5000},
      ];
      final monthlyHistory = [
        {'month': '2026-01', 'expenses': 3000},
        {'month': '2026-02', 'expenses': 4000}, // Max month
        {'month': '2026-03', 'expenses': 3000},
      ];

      when(() => mockRepository.getCategorySpendingForRange(any(), any()))
          .thenAnswer((invocation) async {
        final start = invocation.positionalArguments[0] as DateTime;
        if (start.year == testYear) {
          return currentYearCats;
        } else {
          return previousYearCats;
        }
      });

      when(() => mockRepository.getMonthlyHistory(testYear))
          .thenAnswer((_) async => monthlyHistory);

      // Act
      final result = await useCase.call(testYear);

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;

      expect(data.year, testYear);
      expect(data.totalSpendCurrentYear, 36000); // 12000 + 24000
      expect(data.totalSpendPreviousYear, 39000); // 10000 + 24000 + 5000

      // Category stability checks
      final foodStability =
          data.categoryStability.firstWhere((e) => e.category == 'Food');
      expect(foodStability.variance, 20.0); // (12000-10000)/10000 * 100

      final rentStability =
          data.categoryStability.firstWhere((e) => e.category == 'Rent');
      expect(rentStability.variance, 0.0);
      expect(rentStability.isStable, isTrue);

      final travelStability =
          data.categoryStability.firstWhere((e) => e.category == 'Travel');
      expect(travelStability.currentYearTotal, 0);
      expect(travelStability.variance, -100.0);

      expect(data.mostExpensiveMonth, 2);
      expect(data.avgMonthlySpend, 3333); // (3000+4000+3000) / 3 = 3333.33...
    });

    test('should return Failure when repository call fails', () async {
      // Arrange
      when(() => mockRepository.getCategorySpendingForRange(any(), any()))
          .thenThrow(Exception('DB Error'));

      // Act
      final result = await useCase.call(testYear);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<DatabaseFailure>());
    });

    test('should handle empty data gracefully', () async {
      // Arrange
      when(() => mockRepository.getCategorySpendingForRange(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getMonthlyHistory(any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testYear);

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;
      expect(data.totalSpendCurrentYear, 0);
      expect(data.categoryStability, isEmpty);
      expect(data.avgMonthlySpend, 0);
    });
    test('should handle null or non-int values from repository', () async {
      // Arrange
      final List<Map<String, dynamic>> currentYearCats = [
        {'category': 'Food', 'total': 12000.50}, // double
        {'category': 'Rent', 'total': null}, // null
      ];
      final List<Map<String, dynamic>> previousYearCats = [
        {'category': 'Food', 'total': 10000},
      ];
      final monthlyHistory = [
        {'month': '2026-01', 'expenses': 3000},
        {'month': '2026-02', 'expenses': null}, // null expenses
      ];

      when(() => mockRepository.getCategorySpendingForRange(any(), any()))
          .thenAnswer((invocation) async {
        final start = invocation.positionalArguments[0] as DateTime;
        if (start.year == testYear) {
          return currentYearCats;
        } else {
          return previousYearCats;
        }
      });

      when(() => mockRepository.getMonthlyHistory(testYear))
          .thenAnswer((_) async => monthlyHistory);

      // Act
      final result = await useCase.call(testYear);

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;
      expect(data.totalSpendCurrentYear, 12000); // 12000.5 -> 12000, null -> 0

      // Current implementation: if (total > 0) totalForAvg += total; monthsWithData++;
      // So month 01 (3000) counts, month 02 (null -> 0) does NOT count toward monthsWithData.
      expect(data.avgMonthlySpend, 3000);
    });
  });
}
