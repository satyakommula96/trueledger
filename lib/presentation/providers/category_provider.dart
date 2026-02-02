import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

final categoriesProvider =
    FutureProvider.family<List<TransactionCategory>, String>((ref, type) async {
  final repo = ref.watch(financialRepositoryProvider);
  return repo.getCategories(type);
});
