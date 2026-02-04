import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late GetWeeklyReflectionUseCase useCase;
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
    useCase = GetWeeklyReflectionUseCase(mockRepository);

    // Register fallback for DateTime if needed by mocktail,
    // but here we pass specific instances in when()
  });

  test('should return correct reflection data', () async {
    // arrange
    final now = DateTime.now();
    final thisMondayOffset = now.weekday - 1;
    final thisWeekStart =
        DateTime(now.year, now.month, now.day - thisMondayOffset);

    final tTransactions = [
      LedgerItem(
          id: 1,
          date: now.toIso8601String(),
          amount: 100,
          label: 'Food',
          type: 'Variable',
          note: ''),
      LedgerItem(
          id: 2,
          date: now.toIso8601String(),
          amount: 3000,
          label: 'Shopping',
          type: 'Variable',
          note: ''),
    ];

    final tBudgets = [
      Budget(id: 1, category: 'Food', monthlyLimit: 30000), // Daily limit 1000
    ];

    final tThisWeekCats = [
      {'category': 'Food', 'total': 100},
      {'category': 'Shopping', 'total': 3000},
    ];

    final tLastWeekCats = [
      {'category': 'Food', 'total': 200},
      {'category': 'Shopping', 'total': 1000},
    ];

    when(() => mockRepository.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => tTransactions);
    when(() => mockRepository.getBudgets()).thenAnswer((_) async => tBudgets);
    when(() => mockRepository.getCategorySpendingForRange(any(), any()))
        .thenAnswer((invocation) async {
      final start = invocation.positionalArguments[0] as DateTime;
      if (start.isBefore(thisWeekStart)) {
        return tLastWeekCats;
      }
      return tThisWeekCats;
    });

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result.isSuccess, true,
        reason: result.isFailure ? result.failureOrThrow.message : null);
    final data = result.getOrThrow;

    // Total this week: 100 + 3000 = 3100
    // Total last week: 200 + 1000 = 1200
    expect(data.totalThisWeek, 3100);
    expect(data.totalLastWeek, 1200);

    // Days under budget:
    // Monday: 3100 (spent) vs 1000 (budget) -> Over
    // Other days: 0 (spent) vs 1000 (budget) -> Under
    // The count depends on the current day of the week.

    // Largest increase: Shopping (3000 - 1000 = 2000 increase)
    expect(data.largestCategoryIncrease?['category'], 'Shopping');
    expect(data.largestCategoryIncrease?['increaseAmount'], 2000);
  });

  test('should handle new category and larger subsequent increase', () async {
    // This test covers the "orElse" path (new category)
    // AND the "diff > significantIncrease" path (multiple increases)

    final now = DateTime.now();
    final thisMondayOffset = now.weekday - 1;
    final thisWeekStart =
        DateTime(now.year, now.month, now.day - thisMondayOffset);

    // This week: NewCat (500), BigSpender (2000)
    final tThisWeekCats = [
      {'category': 'SmallIncrease', 'total': 110}, // +10 over last week
      {'category': 'NewCategory', 'total': 500}, // New, +500 increase
      {'category': 'BigSpender', 'total': 2000}, // +1000 over last week
    ];

    // Last week: SmallIncrease (100), BigSpender (1000)
    // NewCategory is MISSING from last week -> triggers orElse
    final tLastWeekCats = [
      {'category': 'SmallIncrease', 'total': 100},
      {'category': 'BigSpender', 'total': 1000},
    ];

    when(() => mockRepository.getTransactionsForRange(any(), any()))
        .thenAnswer((_) async => []); // No tx needed for this logic
    when(() => mockRepository.getBudgets()).thenAnswer((_) async => []);
    when(() => mockRepository.getCategorySpendingForRange(any(), any()))
        .thenAnswer((invocation) async {
      final start = invocation.positionalArguments[0] as DateTime;
      if (start.isBefore(thisWeekStart)) {
        return tLastWeekCats;
      }
      return tThisWeekCats;
    });

    final result = await useCase(NoParams());
    final data = result.getOrThrow;

    // BigSpender (increase 1000) > NewCategory (increase 500) > SmallIncrease (increase 10)
    // Should verify that BigSpender is chosen, confirming the loop correctly updates the max
    expect(data.largestCategoryIncrease?['category'], 'BigSpender');
    expect(data.largestCategoryIncrease?['increaseAmount'], 1000);
    expect(data.largestCategoryIncrease?['isNew'], false);
  });

  test('should return Failure on repository exception', () async {
    when(() => mockRepository.getTransactionsForRange(any(), any()))
        .thenThrow(Exception('DB Error'));

    final result = await useCase(NoParams());

    expect(result.isFailure, true);
    expect(result.failureOrThrow.message, contains('DB Error'));
  });
}
