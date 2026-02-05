import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/data/repositories/daily_digest_store.dart';
import 'package:trueledger/data/repositories/financial_repository_impl.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

final financialRepositoryProvider = Provider<IFinancialRepository>((ref) {
  return FinancialRepositoryImpl();
});

final dailyDigestStoreProvider = Provider<DailyDigestStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyDigestStore(prefs);
});
