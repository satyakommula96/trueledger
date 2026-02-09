import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

final recurringProvider =
    AsyncNotifierProvider<RecurringNotifier, List<RecurringTransaction>>(
  RecurringNotifier.new,
);

class RecurringNotifier extends AsyncNotifier<List<RecurringTransaction>> {
  @override
  FutureOr<List<RecurringTransaction>> build() async {
    return _fetch();
  }

  Future<List<RecurringTransaction>> _fetch() async {
    final repo = ref.read(financialRepositoryProvider);
    return await repo.getRecurringTransactions();
  }

  Future<void> add({
    required String name,
    required double amount,
    required String category,
    required String type,
    required String frequency,
    int? dayOfMonth,
    int? dayOfWeek,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financialRepositoryProvider);
      await repo.addRecurringTransaction(
        name: name,
        amount: amount,
        category: category,
        type: type,
        frequency: frequency,
        dayOfMonth: dayOfMonth,
        dayOfWeek: dayOfWeek,
      );
      return _fetch();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financialRepositoryProvider);
      await repo.deleteItem('recurring_transactions', id);
      return _fetch();
    });
  }
}
