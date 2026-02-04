import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepository;

  setUp(() {
    mockRepository = MockFinancialRepository();
  });

  test('analysisProvider should load data successfully', () async {
    when(() => mockRepository.getBudgets()).thenAnswer((_) async => []);
    when(() => mockRepository.getSpendingTrend()).thenAnswer((_) async => []);
    when(() => mockRepository.getCategorySpending())
        .thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    final data = await container.read(analysisProvider.future);
    expect(data.budgets, isEmpty);
  });
}
