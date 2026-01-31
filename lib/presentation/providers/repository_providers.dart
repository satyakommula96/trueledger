import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/data/repositories/financial_repository_impl.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

final financialRepositoryProvider = Provider<IFinancialRepository>((ref) {
  return FinancialRepositoryImpl();
});
