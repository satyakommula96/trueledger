import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  group('categoriesProvider', () {
    late MockFinancialRepository mockRepository;

    setUp(() {
      mockRepository = MockFinancialRepository();
    });

    test('should fetch categories from repository', () async {
      final categories = [
        TransactionCategory(id: 1, name: 'Food', type: 'Variable'),
        TransactionCategory(id: 2, name: 'Transport', type: 'Variable'),
      ];

      when(() => mockRepository.getCategories('Variable'))
          .thenAnswer((_) async => categories);

      final container = ProviderContainer(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final result =
          await container.read(categoriesProvider('Variable').future);

      expect(result, categories);
      verify(() => mockRepository.getCategories('Variable')).called(1);
    });
    group('categoriesProvider family', () {
      test('should fetch different categories for different types', () async {
        final variableCategories = [
          TransactionCategory(id: 1, name: 'Food', type: 'Variable'),
        ];
        final incomeCategories = [
          TransactionCategory(id: 2, name: 'Salary', type: 'Income'),
        ];

        when(() => mockRepository.getCategories('Variable'))
            .thenAnswer((_) async => variableCategories);
        when(() => mockRepository.getCategories('Income'))
            .thenAnswer((_) async => incomeCategories);

        final container = ProviderContainer(
          overrides: [
            financialRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final varResult =
            await container.read(categoriesProvider('Variable').future);
        final incResult =
            await container.read(categoriesProvider('Income').future);

        expect(varResult, variableCategories);
        expect(incResult, incomeCategories);
      });
    });
  });
}
